require 'pathname'
class PremadeCss
  attr_reader :filepath
  def initialize filepath
    @filepath = filepath
  end

  def filename
    Pathname.new(filepath).basename
  end

  def path
    "/stylesheets/custom/#{filename}"
  end
end
