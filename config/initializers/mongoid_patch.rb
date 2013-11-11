# Allows "rake db:mongoid:create_indexes" to work
require 'rails/mongoid'

module DetermineModelPatch
  def self.included(base)
    class << base
      alias original_determine_model determine_model

      def determine_model(file)
        return nil unless file =~ /app\/models\/(.*).rb$/

        model_path = $1.split('/')
        begin
          parts = model_path.map { |path| path.camelize }
          name = parts.join("::")
          klass = name.constantize
        rescue NameError, LoadError
          klass = parts.last.constantize rescue nil
        end
        klass if klass && klass.ancestors.include?(::Mongoid::Document)
      end
    end
  end
end

Rails::Mongoid.__send__(:include, DetermineModelPatch)
