class Publication < ApplicationRecord
  has_one_attached :file
  has_many :authors, dependent: :destroy

  after_destroy_commit :purge_attached_file

  validates :title, presence: true
  validates :date_published, presence: true

  validate :file_type_and_size

  def to_h
    {
      id: id,
      title: title,
      date_published: date_published,
      file_attached: file.attached?,
      file_name: file.attached? ? file.filename.to_s : nil,
      file_url: file_url
    }
  end

  def downloadable_files
    return [] unless file.attached?

    [file_url]
  end

  def purge_attached_file
    file.purge_later if file.attached?
  end

  private

  def default_host
    ENV.fetch('APP_HOST') { 'http://localhost:3000' }
  end

  def file_type_and_size
    return unless file.attached?

    unless file.content_type == 'application/pdf'
      errors.add(:file, 'must be a PDF')
    end

    if file.blob.byte_size > 10.megabytes
      errors.add(:file, 'is too big (maximum is 10 MB)')
    end
  end

  def file_url
    return unless file.attached?

    Rails.application.routes.url_helpers.rails_blob_url(
      file,
      host: default_host
    )
  end
end
