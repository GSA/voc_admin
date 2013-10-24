class AuthlogicRackAdapter < Authlogic::ControllerAdapters::RackAdapter
  def cookie_domain
    APP_CONFIG["host"]
  end
end
