class Student < ApplicationRecord
  belongs_to :course

  validates :course, presence: true
  validates :first_name, :middle_name, :last_name, :id_number, presence: true
  validates :email, presence: true, uniqueness: true

  def full_name
    "#{first_name} #{middle_name} #{last_name}"
  end

  def to_h
    {
      id: id,
      course_id: course_id,
      first_name: first_name,
      middle_name: middle_name,
      last_name: last_name,
      full_name: full_name,
      email: email,
      id_number: id_number
    }
  end

  def to_s
    full_name
  end

  has_many :authors, as: :person, dependent: :destroy
end
