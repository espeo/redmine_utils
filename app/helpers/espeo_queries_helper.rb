module EspeoQueriesHelper

  # @param query_class Query
  # @param attributes                 Hash (optional)
  # @param attributes[:params]        Hash (optional)
  # @param attributes[:sort_criteria] Array[['id', 'desc'], 'other_column', 'asc']] (optional)
  # @param attributes[:name]          ... passed directly to Query#new constructor
  #
  # @return Espeo::QueryCollection
  def espeo_create_query_collection(query_class, attributes = {})
    params = attributes.delete(:params) || self.params
    default_sort_criteria = attributes.delete(:sort_criteria) || [['id', 'desc']]
    attributes[:name] ||= '_'
    query = query_class.build_from_params(params, attributes)

    sort_init(query.sort_criteria.empty? ? default_sort_criteria : query.sort_criteria)
    sort_update(query.sortable_columns)
    scope = query.results_scope(:order => sort_clause)

    paginator = Redmine::Pagination::Paginator.new scope.count, ((params[:per_page].to_i if params[:per_page]) || per_page_option), params[:page]
    entries = scope.offset(paginator.offset).limit(paginator.per_page).all

    Espeo::QueryCollection.new(query: query, paginator: paginator, entries: entries)
  end

  def espeo_column_header(column, query)
    (column.sortable && query.sortable) ? sort_header_tag(column.name.to_s, :caption => column.caption,
                                                        :default_order => column.default_order) :
                      content_tag('th', h(column.caption))
  end

  def espeo_column_content(column, entry)
    value = column.value_object(entry)
    if value.is_a?(Array)
      value.collect {|v| espeo_column_value(column, entry, v)}.compact.join(', ').html_safe
    else
      espeo_column_value(column, entry, value)
    end
  end

  def espeo_column_value(column, entry, value)
    return send(column.column_value_helper, value) if column.column_value_helper

    case column.name
    when :id
      link_to value, entry
    when :subject, :title
      link_to value, entry
    when :description
      entry.description? ? content_tag('div', textilizable(entry, :description), :class => "wiki") : ''
    when :done_ratio
      progress_bar(value, :width => '80px')
    when :relations
      other = value.other_issue(entry)
      content_tag('span',
        (l(value.label_for(entry)) + " " + link_to_issue(other, :subject => false, :tracker => false)).html_safe,
        :class => value.css_classes_for(entry))
    else
      format_object(value)
    end
  end

end
