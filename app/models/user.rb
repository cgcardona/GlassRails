require "google/api_client"
require "rest_client"
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:google_oauth2]

  has_many :google_oauths

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name
  # attr_accessible :title, :body

  def self.find_for_google_oauth2(access_token, signed_in_resource=nil)

    data = access_token.info

     #   puts data.inspect
    user = User.where(:email => data["email"]).first

    unless user
      user = User.create(
        first_name: data["first_name"],
        last_name: data["last_name"],
        email: data["email"],
        password: Devise.friendly_token[0,20]
      )
      user.google_oauths.create(
        access_token:  access_token.credentials.token,
        refresh_token: access_token.credentials.refresh_token,
        token_expires_at: Time.at(access_token.credentials.expires_at)
      )
    end
    user
  end

  def self.get_client(user)
    client = Google::APIClient.new
    client.authorization.scope = 'https://www.googleapis.com/auth/calendar'
    client.authorization.access_token = User.get_current_token(user)
    client
  end

  def self.get_current_token(user)
    google_oauth = user.google_oauths.first
    if (google_oauth.access_token.nil? || (google_oauth.token_expires_at.nil? || google_oauth.token_expires_at < Time.now))
      data = {
        :client_id => ENV["GOOGLE_KEY"],
        :client_secret => ENV["GOOGLE_SECRET"],
        :refresh_token => google_oauth.refresh_token,
        :grant_type => "refresh_token"
      }
      @response = ActiveSupport::JSON.decode(RestClient.post "https://accounts.google.com/o/oauth2/token", data)
      puts @response.to_json
      if @response["access_token"].present?
        google_oauth.access_token = @response["access_token"]
        google_oauth.token_expires_at = Time.at(Time.now.to_i + @response["expires_in"])
      end
      google_oauth.save
    end
    google_oauth.access_token
  end

end
