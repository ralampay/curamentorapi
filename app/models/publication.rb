class Publication < ApplicationRecord
  has_one_attached :file
  has_many :authors, dependent: :destroy

  validates :title, presence: true
  validates :date_published, presence: true

  validate :file_type_and_size

  def to_h
    {
      id: id,
      title: title,
      date_published: date_published,
      file_attached: file.attached?,
      file_name: file.attached? ? file.filename.to_s : nil
    }
  end

  private

  def file_type_and_size
    return unless file.attached?

    unless file.content_type == 'application/pdf'
      errors.add(:file, 'must be a PDF')
    end

    if file.blob.byte_size > 10.megabytes
      errors.add(:file, 'is too big (maximum is 10 MB)')
    end
  end
end
