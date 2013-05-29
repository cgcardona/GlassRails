class GoogleOauth < ActiveRecord::Base
  attr_accessible :access_token, :refresh_token, :token_expires_at, :user_id
end
