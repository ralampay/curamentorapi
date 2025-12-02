module Publications
  class Save < Validator
    attr_reader :payload, :publication

    def initialize(publication: nil, title:, date_published:, file: nil)
      super()

      @publication = publication
      @title = title
      @date_published = date_published
      @file = file

      @payload = {
        title: [],
        date_published: [],
        file: []
      }
    end

    def execute!
      validate!

      return unless valid?

      @publication ||= Publication.new
      @publication.title = @title if @title.present?
      @publication.date_published = @date_published if @date_published.present?
      attach_file! if @file.present?

      unless @publication.valid?
        merge_publication_errors
        return
      end

      @publication.save!
    end

    private

    def validate!
      if @publication.blank?
        validate_new_record!
      else
        validate_existing_record!
      end
    end

    def validate_new_record!
      @payload[:title] << "required" if @title.blank?
      @payload[:date_published] << "required" if @date_published.blank?

      count_errors!
    end

    def validate_existing_record!
      if @title.present? && @title.strip.empty?
        @payload[:title] << "required"
      end

      if @date_published.present? && @date_published.to_s.strip.empty?
        @payload[:date_published] << "required"
      end

      count_errors!
    end

    def attach_file!
      @publication.file.attach(@file)
    end

    def merge_publication_errors
      @publication.errors.each do |error|
        key = error.attribute
        key = key.to_sym if key.respond_to?(:to_sym)
        message = error.message
        @payload[key] ||= []
        @payload[key] << message unless @payload[key].include?(message)
      end

      count_errors!
    end
  end
end
