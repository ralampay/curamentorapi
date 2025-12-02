module Courses
  class Save < Validator
    attr_reader :payload, :course

    def initialize(course: nil, name:, code:)
      super()

      @course = course
      @name = name
      @code = code

      @payload = {
        name: [],
        code: []
      }
    end

    def execute!
      validate!

      if valid?
        @course ||= Course.new
        @course.name = @name if @name.present?
        @course.code = @code if @code.present?
        @course.save!
      end
    end

    private

    def validate!
      if @course.blank?
        if @name.blank?
          @payload[:name] << "required"
        elsif Course.find_by_name(@name).present?
          @payload[:name] << "already taken"
        end

        if @code.blank?
          @payload[:code] << "required"
        elsif Course.find_by_code(@code).present?
          @payload[:code] << "already taken"
        end
      else
        if @name.present? && Course.where.not(id: @course.id).find_by_name(@name).present?
          @payload[:name] << "already taken"
        end

        if @code.present? && Course.where.not(id: @course.id).find_by_code(@code).present?
          @payload[:code] << "already taken"
        end
      end

      count_errors!
    end
  end
end
