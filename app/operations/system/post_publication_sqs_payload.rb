module System
  class PostPublicationPayload
    attr_reader :publication

    def initialize(publication:)
      @publication = publication
    end

    def build
      {
        publication_id: publication.id,
        title: publication.title,
        date_published: publication.date_published,
        file_attached: publication.file.attached?
      }
    end
  end
end
