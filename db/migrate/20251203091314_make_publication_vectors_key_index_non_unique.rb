class MakePublicationVectorsKeyIndexNonUnique < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    remove_index :publication_vectors, :key if index_exists?(:publication_vectors, :key)
    add_index :publication_vectors, :key, algorithm: :concurrently
  end
end
