class PublicationsController < AuthenticatedController
  include ApiHelpers
  before_action :authorize_active!

  before_action :load_resource!, only: [:show, :update, :delete, :vectorize]

  def index
    publications = Publication.order("title ASC")
    publications = publications.page(params[:page]).per(params[:per_page] || ITEMS_PER_PAGE)

    records = publications.map { |publication| publication.to_h }

    render json: {
      records: records,
      total_pages: publications.total_pages,
      current_page: publications.current_page,
      next_page: publications.next_page,
      prev_page: publications.prev_page
    }
  end

  def show
    render json: @publication.to_h
  end

  def create
    cmd = ::Publications::Save.new(
      title: params[:title],
      date_published: params[:date_published],
      file: params[:file]
    )

    cmd.execute!

    if cmd.valid?
      render json: cmd.publication.to_h
    else
      render json: cmd.payload, status: :unprocessable_content
    end
  end

  def update
    cmd = ::Publications::Save.new(
      publication: @publication,
      title: params[:title],
      date_published: params[:date_published],
      file: params[:file]
    )

    cmd.execute!

    if cmd.valid?
      render json: cmd.publication.to_h
    else
      render json: cmd.payload, status: :unprocessable_content
    end
  end

  def delete
    @publication.destroy!

    render json: { message: "ok" }
  end

  def vectorize
    payload = ::System::PostPublicationPayload.new(publication: @publication).build
    cmd = ::System::SendSqsPayload.new(payload: payload)

    cmd.execute!

    render json: {
      message: "queued",
      message_id: cmd.message_id
    }
  end

  private

  def load_resource!
    @publication = Publication.find_by_id(params[:id])

    if @publication.blank?
      render json: { message: 'not found' }, status: :not_found
    end
  end
end
