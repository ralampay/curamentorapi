class Author < ApplicationRecord
  belongs_to :publication
  belongs_to :person, polymorphic: true

  validates :person, presence: true
  validates :publication, presence: true

  def to_h
    {
      id: id,
      person_id: person_id,
      person_type: person_type,
      publication_id: publication_id,
      is_primary: is_primary
    }
  end
end
