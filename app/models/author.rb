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
      .merge(person_attributes)
  end

  private

  def person_attributes
    return {} unless person

    {
      person_first_name: person.first_name,
      person_last_name: person.last_name,
      person_id_number: person.id_number
    }
  end
end
