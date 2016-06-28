begin
  require 'yaml_erb_loader'

  LDAP_CONFIG = YamlErbLoader.load_from_config(File.join(Rails.root, "config", "ldap.yml"))[Rails.env]
  required_keys = [:host, :port, :base, :uid_name, :user_group, :admin_user, :admin_pass]
  missing = []
  required_keys.each do |key|
      missing << key unless LDAP_CONFIG[key].blank?
  end
  unless missing.empty?
    raise ArgumentError.new(missing.join(",") + " MUST be provided")
  else
    ldap = Ldap.new("testing","testing") #username and pass won't get checked here
    unless ldap.valid_connection?
      raise ArgumentError.new("Service account invalid")
    end
  end
end
