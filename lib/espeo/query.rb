require_dependency 'query'

# Wrapper on Query class.
#
# New features:
# 1. #initialize has support for additional `attributes`:
#    - :sortable [Boolean] - turn off sorting ability for all columns for this query
class Espeo::Query < Query
  attr_reader :sortable

  def initialize(attributes=nil, *args)
    @sortable = attributes.has_key?(:sortable) ? !!attributes.delete(:sortable) : true

    super attributes
    self.filters ||= {}
  end
end
