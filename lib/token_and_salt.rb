module TokenAndSalt
  protected

  # Token with given salt
  def token_with_salt(salt)
    Digest::SHA256.hexdigest(CommentToolApp::Application.config.secret_token + salt)
  end

  # Token and salt used to access by require_token
  def token_and_salt
    today_string = Time.now.to_date.to_s
    return token_with_salt(today_string), today_string
  end
end
