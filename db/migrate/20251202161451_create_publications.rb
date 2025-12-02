class CreatePublications < ActiveRecord::Migration[8.1]
  def change
    create_table :publications, id: :uuid do |t|
      t.string :title, null: false
      t.date :date_published, null: false

      t.timestamps
    end
  end
end
