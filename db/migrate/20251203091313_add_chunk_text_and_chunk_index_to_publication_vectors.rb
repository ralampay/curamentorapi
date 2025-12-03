class AddChunkTextAndChunkIndexToPublicationVectors < ActiveRecord::Migration[8.1]
  def change
    add_column :publication_vectors, :chunk_index, :integer
    add_column :publication_vectors, :chunk_text, :text
  end
end
