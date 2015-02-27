require_dependency 'query'

# Wrapper on QueryColumn class.
#
# New features:
# 1. options[:column_value_helper] [Symbol] (optional)
class Espeo::QueryColumn < QueryColumn
  attr_accessor :column_value_helper

  def initialize(name, options={})
    super(name, options)
    @column_value_helper = options.delete(:column_value_helper)
  end
end
