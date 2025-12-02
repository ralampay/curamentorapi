class Course < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true

  has_many :students

  def to_s
    name
  end

  def to_h
    {
      id: id,
      name: name,
      code: code
    }
  end
end
