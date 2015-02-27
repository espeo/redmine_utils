class Espeo::QueryCollection
  include Enumerable

  attr_reader :query, :paginator, :entries

  delegate :each, to: :entries

  # @param attributes Hash
  # @param attributes[:query]     Query (required)
  # @param attributes[:paginator] Redmine::Pagination::Paginator (required)
  # @param attributes[:entries]   Array[ActiveRecord::Base] (required)
  def initialize(attributes)
    @query = attributes[:query]
    @paginator = attributes[:paginator]
    @entries = attributes[:entries]
  end

  def total_count
    paginator.item_count
  end
end
