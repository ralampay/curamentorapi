module Students
  class Save < Validator
    attr_reader :payload, :student

    def initialize(student: nil, course_id:, first_name:, middle_name:, last_name:, id_number:, email:)
      super()

      @student = student
      @course_id = course_id
      @first_name = first_name
      @middle_name = middle_name
      @last_name = last_name
      @id_number = id_number
      @email = email

      @payload = {
        course_id: [],
        first_name: [],
        middle_name: [],
        last_name: [],
        id_number: [],
        email: []
      }
    end

    def execute!
      validate_new_record! if @student.blank?
      validate_existing_record! if @student.present?

      if valid?
        @student ||= Student.new
        @student.course_id = @course_id if @course_id.present?
        @student.first_name = @first_name if @first_name.present?
        @student.middle_name = @middle_name if @middle_name.present?
        @student.last_name = @last_name if @last_name.present?
        @student.id_number = @id_number if @id_number.present?
        @student.email = @email if @email.present?
        @student.save!
      end
    end

    private

    def validate_new_record!
      if @course_id.blank?
        @payload[:course_id] << "required"
      elsif Course.find_by_id(@course_id).blank?
        @payload[:course_id] << "invalid"
      end

      if @first_name.blank?
        @payload[:first_name] << "required"
      end

      if @middle_name.blank?
        @payload[:middle_name] << "required"
      end

      if @last_name.blank?
        @payload[:last_name] << "required"
      end

      if @id_number.blank?
        @payload[:id_number] << "required"
      end

      if @email.blank?
        @payload[:email] << "required"
      elsif Student.find_by_email(@email).present?
        @payload[:email] << "already taken"
      end

      count_errors!
    end

    def validate_existing_record!
      if @course_id.present? && Course.find_by_id(@course_id).blank?
        @payload[:course_id] << "invalid"
      end

      if @email.present? && Student.where.not(id: @student.id).find_by_email(@email).present?
        @payload[:email] << "already taken"
      end

      count_errors!
    end
  end
end
