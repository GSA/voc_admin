Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env.development? || ENV['DEBUG_ACCESS'].present?
    provider :developer
  else
    provider :saml,
      issuer:             ENV.fetch('SAML_APP_NAME'),
      idp_sso_target_url: ENV.fetch('SSO_TARGET_URL'),
      idp_cert:           ENV.fetch('SAML_CERT')
  end
end
