class CreateCourses < ActiveRecord::Migration[8.1]
  def change
    create_table :courses, id: :uuid do |t|
      t.string :name, null: false
      t.string :code, null: false

      t.timestamps
    end
  end
end
