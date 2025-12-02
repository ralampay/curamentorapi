class CoursesController < AuthenticatedController
  include ApiHelpers
  before_action :authorize_active!

  before_action :load_resource!, only: [:show, :update, :delete]

  def index
    courses = Course.order("name ASC")
    courses = courses.page(params[:page]).per(params[:per_page] || ITEMS_PER_PAGE)

    records = courses.map { |course| course.to_h }

    render json: {
      records: records,
      total_pages: courses.total_pages,
      current_page: courses.current_page,
      next_page: courses.next_page,
      prev_page: courses.prev_page
    }
  end

  def show
    render json: @course.to_h
  end

  def create
    cmd = ::Courses::Save.new(
      name: params[:name],
      code: params[:code]
    )

    cmd.execute!

    if cmd.valid?
      render json: cmd.course.to_h
    else
      render json: cmd.payload, status: :unprocessable_content
    end
  end

  def update
    cmd = ::Courses::Save.new(
      course: @course,
      name: params[:name],
      code: params[:code]
    )

    cmd.execute!

    if cmd.valid?
      render json: cmd.course.to_h
    else
      render json: cmd.payload, status: :unprocessable_content
    end
  end

  def delete
    @course.destroy!

    render json: { message: "ok" }
  end

  private

  def load_resource!
    @course = Course.find_by_id(params[:id])

    if @course.blank?
      render json: { message: 'not found' }, status: :not_found
    end
  end
end
