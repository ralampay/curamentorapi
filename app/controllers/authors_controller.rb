class AuthorsController < AuthenticatedController
  include ApiHelpers
  before_action :authorize_active!
  before_action :load_publication!
  before_action :load_author!, only: [:delete]

  def create
    cmd = ::Authors::Save.new(
      publication: @publication,
      person_type: params[:person_type],
      person_id: params[:person_id],
      is_primary: params[:is_primary]
    )

    cmd.execute!

    if cmd.valid?
      render json: cmd.author.to_h
    else
      render json: cmd.payload, status: :unprocessable_content
    end
  end

  def delete
    @author.destroy!

    render json: { message: "ok" }
  end

  def index
    render json: @publication.authors.map { |author| author.to_h }
  end

  private

  def load_publication!
    @publication = Publication.find_by_id(params[:publication_id])

    if @publication.blank?
      render json: { message: 'not found' }, status: :not_found
    end
  end

  def load_author!
    return if @publication.blank?

    @author = @publication.authors.find_by_id(params[:id])

    if @author.blank?
      render json: { message: 'not found' }, status: :not_found
    end
  end
end
