class PublicationVector < ApplicationRecord
  belongs_to :publication

  validates :key, presence: true, uniqueness: true
  validates :publication, presence: true
  validates :vector, presence: true
end
