class StudentsController < AuthenticatedController
  include ApiHelpers
  before_action :authorize_active!

  before_action :load_resource!, only: [:show, :update, :delete]

  def index
    students = Student.order("last_name ASC")
    students = filter_students(students)
    students = students.page(params[:page]).per(params[:per_page] || ITEMS_PER_PAGE)

    records = students.map { |student| student.to_h }

    render json: {
      records: records,
      total_pages: students.total_pages,
      current_page: students.current_page,
      next_page: students.next_page,
      prev_page: students.prev_page
    }
  end

  def show
    render json: @student.to_h
  end

  def create
    cmd = ::Students::Save.new(
      course_id: params[:course_id],
      first_name: params[:first_name],
      middle_name: params[:middle_name],
      last_name: params[:last_name],
      id_number: params[:id_number],
      email: params[:email]
    )

    cmd.execute!

    if cmd.valid?
      render json: cmd.student.to_h
    else
      render json: cmd.payload, status: :unprocessable_content
    end
  end

  def update
    cmd = ::Students::Save.new(
      student: @student,
      course_id: params[:course_id],
      first_name: params[:first_name],
      middle_name: params[:middle_name],
      last_name: params[:last_name],
      id_number: params[:id_number],
      email: params[:email]
    )

    cmd.execute!

    if cmd.valid?
      render json: cmd.student.to_h
    else
      render json: cmd.payload, status: :unprocessable_content
    end
  end

  def delete
    @student.destroy!

    render json: { message: "ok" }
  end

  private

  def load_resource!
    @student = Student.find_by_id(params[:id])

    if @student.blank?
      render json: { message: 'not found' }, status: :not_found
    end
  end

  def filter_students(scope)
    return scope if params[:q].blank?

    term = "%#{params[:q]}%"
    scope.where("first_name ILIKE ? OR middle_name ILIKE ? OR last_name ILIKE ?", term, term, term)
  end
end
