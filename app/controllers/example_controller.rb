class ExampleController < ApplicationController
  before_filter :authenticate_user!
  def index
    client = User.get_client(current_user)
    oauth2 = client.discovered_api( "oauth2", "v2" )
    result = client.execute(
      :api_method => oauth2.userinfo.get)
    @name = result.data.name

    render :index
  end
end
