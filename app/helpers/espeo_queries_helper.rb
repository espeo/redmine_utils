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

  def espeo_column_header(column)
    column.sortable ? sort_header_tag(column.name.to_s, :caption => column.caption,
                                                        :default_order => column.default_order) :
                      content_tag('th', h(column.caption))
  end

  def espeo_column_content(column, issue)
    value = column.value(issue)
    if value.is_a?(Array)
      value.collect {|v| column_value(column, issue, v)}.compact.join(', ').html_safe
    else
      column_value(column, issue, value)
    end
  end

  def espeo_column_value(column, issue, value)
    if column.respond_to?(:column_value_helper)
      helper_method = column.column_value_helper
      return send(helper_method, value) unless helper_method.nil?
    end

    case column.name
    when :id
      link_to value, issue_path(issue)
    when :subject
      link_to value, issue_path(issue)
    when :description
      issue.description? ? content_tag('div', textilizable(issue, :description), :class => "wiki") : ''
    when :done_ratio
      progress_bar(value, :width => '80px')
    when :relations
      other = value.other_issue(issue)
      content_tag('span',
        (l(value.label_for(issue)) + " " + link_to_issue(other, :subject => false, :tracker => false)).html_safe,
        :class => value.css_classes_for(issue))
    else
      format_object(value)
    end
  end

end
