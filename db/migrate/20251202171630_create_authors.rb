class CreateAuthors < ActiveRecord::Migration[8.1]
  def change
    create_table :authors, id: :uuid do |t|
      t.uuid :person_id, null: false
      t.string :person_type, null: false
      t.references :publication, null: false, foreign_key: true, type: :uuid
      t.boolean :is_primary, default: false

      t.timestamps
    end

    add_index :authors, [:person_type, :person_id]
  end
end
