module System
  class PostPublicationSqsPayload
    attr_reader :publication, :command

    def initialize(publication:)
      @publication = publication
    end

    def execute!
      @command ||= ::System::SendSqsPayload.new(payload: build)
      @command.execute!

      @command
    end

    private

    def build
      {
        publication_id: publication.id,
        title: publication.title,
        date_published: publication.date_published,
        file_attached: publication.file.attached?,
        key: publication.file.attached? ? publication.file.blob.key : nil
      }
    end
  end
end
