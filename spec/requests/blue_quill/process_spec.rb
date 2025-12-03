require "rails_helper"

Rails.describe "BlueQuill", type: :request do
  let(:api_url) { "/blue_quill/process" }
  let(:chat_api_url) { "/blue_quill/chat" }
  let(:embedding_model) { "blue-quill-embedding-model" }
  let(:llm_model) { "blue-quill-llm" }
  let(:embedding_vectors) { [0.1, 0.2, 0.3] }
  let(:query) { "something to vectorize" }
  let(:embedding_double) do
    instance_double(
      RubyLLM::Embedding,
      vectors: embedding_vectors,
      model: "test-model",
      input_tokens: 7
    )
  end

  before do
    allow(RubyLLM::Embedding).to receive(:embed).and_return(embedding_double)
  end

  around do |example|
    original_embedding = ENV["OPENAI_EMBEDDING_MODEL"]
    original_llm = ENV["OPENAI_LLM_MODEL"]
    ENV["OPENAI_EMBEDDING_MODEL"] = embedding_model
    ENV["OPENAI_LLM_MODEL"] = llm_model

    example.run

    ENV["OPENAI_EMBEDDING_MODEL"] = original_embedding
    ENV["OPENAI_LLM_MODEL"] = original_llm
  end

  describe "POST /blue_quill/process" do
    it "returns an embedding" do
      post api_url, params: { query: query }

      expect(response).to have_http_status(:ok)
      expect(RubyLLM::Embedding).to have_received(:embed).with(query, model: embedding_model)

      expect(JSON.parse(response.body)).to include(
        "embedding" => embedding_vectors,
        "model" => "test-model",
        "input_tokens" => 7
      )
    end

    it "returns bad request when query is missing" do
      post api_url

      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)).to include("error" => a_string_including("param is missing"))
    end
  end

  describe "POST /blue_quill/chat" do
    let(:chat_message) { instance_double(RubyLLM::Message, content: "contextual reply") }
    let(:chat_double) { instance_double(RubyLLM::Chat) }
    let(:vector_record) do
      double(
        "PublicationVector",
        chunk_text: "Chunk text",
        chunk_index: 1,
        metadata: { "source" => "doc", "authors" => ["Jane Doe"] },
        publication_id: 1,
        similarity: 0.1
      )
    end
    let(:publication) { double("Publication", downloadable_files: ["https://example.com/file.pdf"]) }
    let(:author_person) do
      instance_double(
        Faculty,
        full_name: "Jane Doe",
        id_number: "JD123"
      )
    end
    let(:author_record) do
      double("Author", publication_id: 1, person: author_person)
    end
    let(:author_relation) { double("relation") }
    let(:vector_relation) { double("relation", includes: [vector_record]) }

    before do
      allow(RubyLLM::Chat).to receive(:new).and_return(chat_double)
      allow(chat_double).to receive(:with_instructions).and_return(chat_double)
      allow(chat_double).to receive(:ask).and_return(chat_message)
      allow(PublicationVector).to receive(:closest_to).and_return(vector_relation)
      allow(vector_record).to receive(:publication).and_return(publication)
      allow(Author).to receive(:includes).with(:person).and_return(author_relation)
      allow(author_relation).to receive(:where).and_return([author_record])
    end

    it "builds a context payload and replies with the LLM answer" do
      post chat_api_url, params: { query: query, top_k: 2 }

      expect(PublicationVector).to have_received(:closest_to).with(vector: embedding_vectors, limit: 2)
      expect(RubyLLM::Chat).to have_received(:new).with(model: llm_model)
      expect(chat_double).to have_received(:with_instructions).with(a_string_including("Use the provided context", "I don't know"))
      expect(chat_double).to have_received(:ask).with(a_string_including("Context", "Chunk text"))

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to include(
        "answer" => "contextual reply",
        "model" => llm_model,
        "query" => query
      )
      expect(body["context"]).to be_an(Array)
      expect(body["context"].first).to include(
        "chunk_text" => "Chunk text",
        "metadata" => { "authors" => ["Jane Doe"], "source" => "doc" }
      )
      expect(body["authors"].first).to include(
        "name" => "Jane Doe",
        "id_number" => "JD123",
        "publication_id" => 1
      )
      expect(body["files"]).to eq(["https://example.com/file.pdf"])
      expect(Author).to have_received(:includes).with(:person)
    end

    it "returns bad request when query is missing" do
      post chat_api_url

      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)).to include("error" => a_string_including("param is missing"))
    end
  end
end
