
module PicasaAuth
  def oauth_client
    client = OAuth2::Client.new(Rails.application.config.client_id, Rails.application.config.client_secret,
      :site => 'https://accounts.google.com',
      :authorize_url => "/o/oauth2/auth",
      :token_url => "/o/oauth2/token")
  end

  def refresh_token token
    client = OAuth2::AccessToken.new(oauth_client, token[:access_token], token)
    client = client.refresh!
    token.merge!(
      :access_token => client.token,
      :refresh_token => client.refresh_token
    )
  end
end
