module YamlErbLoader
  def self.load_from_config(filename)
    require 'erb'

    YAML::load(ERB.new(IO.read(filename)).result)
  end
end
