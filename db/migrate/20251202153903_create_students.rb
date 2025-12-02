class CreateStudents < ActiveRecord::Migration[8.1]
  def change
    create_table :students, id: :uuid do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :middle_name, null: false
      t.string :email, null: false
      t.string :id_number, null: false
      t.references :course, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
