# encoding: utf-8
module RDStation
  class Authentication
    include HTTParty

    def initialize(client_id, client_secret)
      @client_id = client_id
      @client_secret = client_secret
    end

    #
    # param redirect_url
    #  URL that the user will be redirected
    #  after confirming application authorization
    #
    def auth_url(redirect_url)
      "https://api.rd.services/auth/dialog?client_id=#{@client_id}&redirect_url=#{redirect_url}"
    end

    # Public: Get the credentials from RD Station API
    #
    # code  - The code String sent by RDStation after the user confirms authorization.
    #
    # Examples
    #
    #   authenticate("123")
    #   # => { 'access_token' => '54321', 'expires_in' => 86_400, 'refresh_token' => 'refresh' }
    #
    # Returns the credentials Hash.
    # Raises RDStation::Error::ExpiredCodeGrant if the code has expired
    # Raises RDStation::Error::InvalidCredentials if the client_id, client_secret
    # or code is invalid.
    def authenticate(code)
      request = post_to_auth_endpoint(code: code)
      return JSON.parse(request.body) unless request['error_type']
      raise RDStation::Errors.by_type(request)
    end

    #
    # param refresh_token
    #   parameter sent by RDStation after authenticate
    #
    def update_access_token(refresh_token)
      post_to_auth_endpoint({ :refresh_token => refresh_token })
    end

    private

    def auth_token_url
      "https://api.rd.services/auth/token"
    end

    def post_to_auth_endpoint(params)
      default_body = { :client_id => @client_id, :client_secret => @client_secret }

      self.class.post(
        auth_token_url,
        headers: { 'Accept-Encoding' => 'identity' },
        body: default_body.merge(params).to_json
      )
    end
  end
end