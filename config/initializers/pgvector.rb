require "pgvector"

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Type.register(:vector, Pgvector::Type) rescue nil
end
