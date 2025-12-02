class Faculty < ApplicationRecord
  validates :first_name, :last_name, :id_number, presence: true
  validates :id_number, uniqueness: true

  def full_name
    [first_name, middle_name, last_name].compact.join(' ')
  end

  def to_h
    {
      id: id,
      first_name: first_name,
      middle_name: middle_name,
      last_name: last_name,
      full_name: full_name,
      id_number: id_number
    }
  end

  def to_s
    full_name
  end

  has_many :authors, as: :person, dependent: :destroy
end
