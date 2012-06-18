# Require this file, or put this in where Rails will auto load it.

# = Usage
#  validates :attribute, :url => true

# Allow nil values
# validates :attribute, :allow_nil => true

# Allow empty values
# validates :attribute, :allow_empty => true

# Pass in a domain to validate a url belongs to a domain (including any sub-domains and pages beneath the domain and sub-domains)
# validates :attribute, :url => {:domain => 'facebook.com'}

class UrlValidator < ActiveModel::EachValidator
  def initialize(options)
    super

    @domain = options[:domain]
    @permissible_schemes = options[:schemes] || %w(http https)
    @error_message = options[:message] || 'is not a valid url'
    @allow_nil = options[:allow_nil]
    @allow_empty = options[:allow_empty]
  end

  def validate_each(record, attribute, value)
    return if @allow_nil && value.nil?
    return if @allow_empty && value.empty?

    if URI::regexp(@permissible_schemes).match(value)
      begin
        uri = URI.parse(value)
        if @domain
          record.errors.add(attribute, 'does not belong to domain', :value => value) unless uri.host == @domain || uri.host.ends_with?(".#{@domain}")
        end
      rescue URI::InvalidURIError
        record.errors.add(attribute, @error_message, :value => value)
      end
    else
      record.errors.add(attribute, @error_message, :value => value)
    end
  end
end