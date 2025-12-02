module Faculties
  class Save < Validator
    attr_reader :payload, :faculty

    def initialize(faculty: nil, first_name:, middle_name:, last_name:, id_number:)
      super()

      @faculty = faculty
      @first_name = first_name
      @middle_name = middle_name
      @last_name = last_name
      @id_number = id_number

      @payload = {
        first_name: [],
        last_name: [],
        id_number: []
      }
    end

    def execute!
      validate_new_record! if @faculty.blank?
      validate_existing_record! if @faculty.present?

      if valid?
        @faculty ||= Faculty.new
        @faculty.first_name = @first_name if @first_name.present?
        @faculty.middle_name = @middle_name if @middle_name.present?
        @faculty.last_name = @last_name if @last_name.present?
        @faculty.id_number = @id_number if @id_number.present?
        @faculty.save!
      end
    end

    private

    def validate_new_record!
      if @first_name.blank?
        @payload[:first_name] << "required"
      end

      if @last_name.blank?
        @payload[:last_name] << "required"
      end

      if @id_number.blank?
        @payload[:id_number] << "required"
      elsif Faculty.find_by_id_number(@id_number).present?
        @payload[:id_number] << "already taken"
      end

      count_errors!
    end

    def validate_existing_record!
      if @id_number.present? && Faculty.where.not(id: @faculty.id).find_by_id_number(@id_number).present?
        @payload[:id_number] << "already taken"
      end

      count_errors!
    end
  end
end
