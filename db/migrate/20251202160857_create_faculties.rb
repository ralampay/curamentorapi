class CreateFaculties < ActiveRecord::Migration[8.1]
  def change
    create_table :faculties, id: :uuid do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :middle_name
      t.string :id_number, null: false

      t.timestamps
    end
  end
end
