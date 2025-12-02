class FacultiesController < AuthenticatedController
  include ApiHelpers
  before_action :authorize_active!

  before_action :load_resource!, only: [:show, :update, :delete]

  def index
    faculties = Faculty.order("last_name ASC")
    faculties = faculties.page(params[:page]).per(params[:per_page] || ITEMS_PER_PAGE)

    records = faculties.map { |faculty| faculty.to_h }

    render json: {
      records: records,
      total_pages: faculties.total_pages,
      current_page: faculties.current_page,
      next_page: faculties.next_page,
      prev_page: faculties.prev_page
    }
  end

  def show
    render json: @faculty.to_h
  end

  def create
    cmd = ::Faculties::Save.new(
      first_name: params[:first_name],
      middle_name: params[:middle_name],
      last_name: params[:last_name],
      id_number: params[:id_number]
    )

    cmd.execute!

    if cmd.valid?
      render json: cmd.faculty.to_h
    else
      render json: cmd.payload, status: :unprocessable_content
    end
  end

  def update
    cmd = ::Faculties::Save.new(
      faculty: @faculty,
      first_name: params[:first_name],
      middle_name: params[:middle_name],
      last_name: params[:last_name],
      id_number: params[:id_number]
    )

    cmd.execute!

    if cmd.valid?
      render json: cmd.faculty.to_h
    else
      render json: cmd.payload, status: :unprocessable_content
    end
  end

  def delete
    @faculty.destroy!

    render json: { message: "ok" }
  end

  private

  def load_resource!
    @faculty = Faculty.find_by_id(params[:id])

    if @faculty.blank?
      render json: { message: 'not found' }, status: :not_found
    end
  end
end
