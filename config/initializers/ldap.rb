begin
  LDAP_CONFIG = YAML.load_file(File.join(Rails.root, "config", "ldap.yml"))[Rails.env]
  required_keys = [:host, :port, :base, :uid_name, :user_group, :admin_user, :admin_pass]
  missing = []
  required_keys.each do |key|
      missing << key unless LDAP_CONFIG[key].blank?
  end
  unless missing.empty?
    raise ArgumentError.new(missing.join(",") + " MUST be provided")
  else
    ldap = Ldap.new
    unless ldap.valid_connection?
      raise ArgumentError.new("Service account invalid")
    end
  end
end