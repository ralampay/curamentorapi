class BlueQuillController < ApplicationController
  DEFAULT_TOP_K = 4
  CONTEXT_SEPARATOR = "\n\n---\n\n"

  def execute
    embedding = self.class.process(query: params.require(:query))

    render json: {
      embedding: embedding.vectors,
      model: embedding.model,
      input_tokens: embedding.input_tokens
    }, status: :ok
  rescue ActionController::ParameterMissing => e
    render json: { error: e.message }, status: :bad_request
  end

  def chat
    query = params.require(:query)
    top_k = [params.fetch(:top_k, DEFAULT_TOP_K).to_i, 1].max

    embedding = self.class.process(query: query)
    vectors = PublicationVector.closest_to(vector: embedding.vectors, limit: top_k)
                               .includes(publication: { file_attachment: :blob })
    context_text = build_context_text(vectors)
    prompt = build_prompt(query, context_text)
    authors = authors_for_vectors(vectors)
    files = files_for_vectors(vectors)

    response = RubyLLM::Chat.new(model: llm_model)
                              .with_instructions(chat_instructions)
                              .ask(prompt)

    render json: {
      query: query,
      answer: format_answer(response.content, authors),
      model: llm_model,
      context: build_context_payload(vectors),
      authors: authors,
      files: files
    }, status: :ok
  rescue ActionController::ParameterMissing => e
    render json: { error: e.message }, status: :bad_request
  end

  def self.process(query:)
    model = ENV.fetch('OPENAI_EMBEDDING_MODEL')

    RubyLLM::Embedding.embed(query, model: model)
  end

  private

  def llm_model
    ENV.fetch('OPENAI_LLM_MODEL')
  end

  def build_context_text(vectors)
    return "No relevant context was found." if vectors.blank?

    vectors.map do |vector|
      chunk_label = vector.chunk_index.present? ? "Chunk #{vector.chunk_index}" : "Chunk"
      similarity = vector.respond_to?(:similarity) ? vector.similarity : nil
      distance_line = similarity ? " (distance: #{similarity})" : ""
      lines = ["#{chunk_label}#{distance_line}", vector.chunk_text.to_s.strip.presence || "[no text]"]
      lines << "Metadata: #{vector.metadata.to_json}" if vector.metadata.present?
      lines.compact.join("\n")
    end.join(CONTEXT_SEPARATOR)
  end

  def build_context_payload(vectors)
    vectors.map do |vector|
      {
        chunk_text: vector.chunk_text,
        chunk_index: vector.chunk_index,
        similarity: vector.respond_to?(:similarity) ? vector.similarity : nil,
        metadata: vector.metadata
      }.compact
    end
  end

  def chat_instructions
    <<~INSTRUCTIONS
      Use the provided context snippets to answer the question. Only respond if you can back the answer with the context; otherwise reply with "I don't know".
      Format your final answer in Markdown.
    INSTRUCTIONS
  end

  def build_prompt(query, context)
    <<~PROMPT
      You are assisting with answering user questions using publication content. Use the context below before responding.

      Context:
      #{context}

      Question:
      #{query}
    PROMPT
  end

  def format_answer(content, _authors)
    content
  end

  def authors_for_vectors(vectors)
    publication_ids = vectors.map(&:publication_id).compact.uniq
    return [] if publication_ids.blank?

    relation = Author.includes(:person).where(publication_id: publication_ids)

    relation.each_with_object([]) do |author, memo|
      person = author.person
      next unless person

      memo << {
        name: person.respond_to?(:full_name) ? person.full_name : [person.first_name, person.last_name].compact.join(' '),
        id_number: person.respond_to?(:id_number) ? person.id_number : nil,
        person_type: person.class.name,
        publication_id: author.publication_id
      }
    end.uniq { |author| [author[:name], author[:id_number], author[:publication_id]] }
  end

  def files_for_vectors(vectors)
    vectors.map do |vector|
      publication = vector.publication
      next unless publication

      publication.downloadable_files
    end.compact.flatten.uniq
  end
end
