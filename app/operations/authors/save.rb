module Authors
  class Save < Validator
    VALID_PERSON_TYPES = %w[Student Faculty].freeze

    attr_reader :payload, :author

    def initialize(publication:, person_type:, person_id:, is_primary: false)
      super()

      @publication = publication
      @person_type = person_type
      @person_id = person_id
      @is_primary = ActiveModel::Type::Boolean.new.cast(is_primary)

      @payload = {
        person_type: [],
        person_id: []
      }
    end

    def execute!
      validate!

      return unless valid?

      @author ||= @publication.authors.build
      author.person = @person
      author.is_primary = @is_primary

      if author.valid?
        author.save!
      else
        merge_publication_errors
      end
    end

    private

    def validate!
      validate_person_type!
      validate_person_id!
      validate_person!
      validate_duplicate_author!
      count_errors!
    end

    def validate_person_type!
      if @person_type.blank?
        @payload[:person_type] << "required"
      elsif !VALID_PERSON_TYPES.include?(@person_type)
        @payload[:person_type] << "invalid"
      end
    end

    def validate_person_id!
      @payload[:person_id] << "required" if @person_id.blank?
    end

    def validate_person!
      return unless @payload[:person_type].empty? && @payload[:person_id].empty?

      klass = @person_type.safe_constantize

      if klass.blank?
        @payload[:person_type] << "invalid"
        return
      end

      @person = klass.find_by_id(@person_id)

      @payload[:person_id] << "invalid" if @person.blank?
    end

    def validate_duplicate_author!
      return if @person.blank?

      if @publication.authors.exists?(person_type: @person_type, person_id: @person_id)
        @payload[:person_id] << "already added"
      end
    end

    def merge_publication_errors
      author.errors.each do |error|
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
