require "pgvector"

ActiveSupport.on_load(:active_record_postgresqladapter) do
  adapter = ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
  adapter::NATIVE_DATABASE_TYPES[:vector] ||= { name: "vector" }

  ActiveRecord::ConnectionAdapters::PostgreSQL::Column.prepend(Module.new do
    def type
      super || (sql_type == "vector" ? :vector : nil)
    end
  end)

  ActiveRecord::ConnectionAdapters::PostgreSQL::ColumnMethods.module_eval do
    def vector(*names, **options)
      names.each { |name| column(name, :vector, **options) }
    end
  end
end
