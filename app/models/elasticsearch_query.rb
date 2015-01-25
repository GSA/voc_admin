class ElasticsearchQuery
  attr_accessor :index, :document_type, :options, :search_definition

  def initialize(index, document_type=nil, options={})
    @index = index
    @document_type = document_type
    @options = options || {}
    @search_definition = {
      query: {},
      filter: {},
      sort: {}
    }
  end

  def search(query=nil, options={})

  end
end
