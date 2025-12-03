class PublicationVector < ApplicationRecord
  belongs_to :publication

  validates :key, presence: true
  validates :publication, presence: true
  validates :vector, presence: true

  DEFAULT_TOP_K = 4

  def self.closest_to(vector:, limit: DEFAULT_TOP_K)
    normalized = normalized_vector(vector)
    literal = quote_vector_literal(normalized)
    distance_sql = "#{table_name}.vector <=> #{literal}::vector"

    select("#{table_name}.*, #{distance_sql} AS similarity")
      .order(Arel.sql("similarity"))
      .limit(limit)
  end

  def self.normalized_vector(vector)
    values =
      if vector.respond_to?(:to_a)
        vector.to_a
      else
        Array(vector)
      end

    normalized = values.flatten.compact
    raise ArgumentError, "Vector cannot be blank" if normalized.empty?

    normalized.map { |value| Float(value) }
  end

  def self.quote_vector_literal(normalized_vector)
    ActiveRecord::Base.connection.quote("[#{normalized_vector.join(",")}]")
  end
end
