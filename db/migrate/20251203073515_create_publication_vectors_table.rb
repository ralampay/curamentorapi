class CreatePublicationVectorsTable < ActiveRecord::Migration[8.1]
  def change
    enable_extension "vector" unless extension_enabled?("vector")

    create_table :publication_vectors, id: :uuid do |t|
      t.string :key, null: false
      t.references :publication, null: false, foreign_key: true, type: :uuid
      t.jsonb :metadata, null: false, default: {}
      t.column :vector, :vector, limit: 1536, null: false

      t.timestamps
    end

    add_index :publication_vectors, :key
  end
end
