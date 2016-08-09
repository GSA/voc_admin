Rails.application.config.middleware.use OmniAuth::Builder do
  provider :saml,
    issuer:             ENV.fetch('SAML_APP_NAME'),
    idp_sso_target_url: ENV.fetch('SAML_CERT'),
    idp_cert:           ENV.fetch('SSO_TARGET_URL')
end
