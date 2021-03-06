require 'spec_helper'
describe Auth0::Api::AuthenticationEndpoints do
  before :all do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Auth0::Api::AuthenticationEndpoints)

    @instance = dummy_instance
  end

  context '.token_with_client_credentials' do
    it { expect(@instance).to respond_to(:token_with_client_credentials) }
    it "is expected to make post request to '/oauth/token'" do
      allow(@instance).to receive(:post).with(
        '/oauth/token', client_id: @instance.client_id, client_secret: nil, grant_type: 'client_credentials',
                        audience: nil
      )
        .and_return('access_token': 'eyJ0eXAiOiJKV1', 'expires_in': 86_400, 'token_type': 'Bearer')
      expect(@instance).to receive(:post).with(
        '/oauth/token', client_id: @instance.client_id, client_secret: nil, grant_type: 'client_credentials',
                        audience: nil
      )
      expect(@instance.token_with_client_credentials).to include(:access_token, :expires_in, :token_type)
    end
  end

  context '.user_tokens_from_code' do
    it { expect(@instance).to respond_to(:user_tokens_from_code) }
    it "is expected to make post request to '/oauth/token'" do
      allow(@instance).to receive(:post).with(
        '/oauth/token', client_id: @instance.client_id, client_secret: nil, grant_type: 'authorization_code',
                        code: 'code', redirect_uri: 'uri'
      )
        .and_return('user_tokens' => 'UserToken')
      expect(@instance).to receive(:post).with(
        '/oauth/token', client_id: @instance.client_id, client_secret: nil, grant_type: 'authorization_code',
                        code: 'code', redirect_uri: 'uri'
      )
      expect(@instance.user_tokens_from_code('code', 'uri')['user_tokens']).to eq 'UserToken'
    end
    it { expect { @instance.user_tokens_from_code('', '') }.to raise_error 'Must supply a valid code' }
    it { expect { @instance.user_tokens_from_code('code', '') }.to raise_error 'Must supply a valid redirect_uri' }
  end

  context '.login_with_default_directory' do
    it { expect(@instance).to respond_to(:login_with_default_directory) }
    it "is expected to make post request to '/oauth/token'" do
      allow(@instance).to receive(:post).with(
        '/oauth/token', grant_type: 'password', username: 'username', password: 'pwd', audience: nil,
                        client_id: @instance.client_id, client_secret: nil, scope: 'openid'
      )
        .and_return('user_tokens' => 'UserToken')
      expect(@instance).to receive(:post).with(
        '/oauth/token', grant_type: 'password', username: 'username', password: 'pwd', audience: nil,
                        client_id: @instance.client_id, client_secret: nil, scope: 'openid'
      )
      expect(@instance.login_with_default_directory('username', 'pwd')['user_tokens']).to eq 'UserToken'
    end
    it { expect { @instance.login_with_default_directory('', '') }.to raise_error 'Must supply a valid username' }
    it { expect { @instance.login_with_default_directory('usr', '') }.to raise_error 'Must supply a valid password' }
  end

  context '.login_with_default_directory_realm' do
    it { expect(@instance).to respond_to(:login_with_default_directory_realm) }
    it "is expected to make post request to '/oauth/token'" do
      allow(@instance).to receive(:post).with(
        '/oauth/token', grant_type: 'http://auth0.com/oauth/grant-type/password-realm',
                        username: 'username',
                        password: 'pwd',
                        audience: nil,
                        client_id: @instance.client_id,
                        client_secret: nil,
                        scope: 'openid',
                        realm: nil
      )
        .and_return('user_tokens' => 'UserToken')
      expect(@instance).to receive(:post).with(
        '/oauth/token', grant_type: 'http://auth0.com/oauth/grant-type/password-realm',
                        username: 'username',
                        password: 'pwd',
                        audience: nil,
                        client_id: @instance.client_id,
                        client_secret: nil,
                        scope: 'openid',
                        realm: nil
      )
      expect(@instance.login_with_default_directory_realm('username', 'pwd')['user_tokens']).to eq 'UserToken'
    end
    it { expect { @instance.login_with_default_directory_realm('', '') }.to raise_error 'Must supply a valid username' }
    it do
      expect { @instance.login_with_default_directory_realm('usr', '') }.to raise_error 'Must supply a valid password'
    end
  end

  context '.refresh_token' do
    it { expect(@instance).to respond_to(:refresh_token) }
    it "is expected to make post request to '/oauth/token'" do
      allow(@instance).to receive(:post).with(
        '/oauth/token', client_id: @instance.client_id, client_secret: nil, grant_type: 'refresh_token',
                        refresh_token: 'refresh_token', scope: 'offline_access')
        .and_return('user_tokens' => 'UserToken')
      expect(@instance).to receive(:post).with(
        '/oauth/token', client_id: @instance.client_id, client_secret: nil, grant_type: 'refresh_token',
                        refresh_token: 'refresh_token', scope: 'offline_access')
      expect(@instance.refresh_token('refresh_token', 'offline_access')['user_tokens']).to eq 'UserToken'
    end
    it { expect { @instance.refresh_token('') }.to raise_error 'Must supply a valid refresh_token' }
  end

  context '.login' do
    it { expect(@instance).to respond_to(:login) }
    it 'is expected to make post to /oauth/ro' do
      expect(@instance).to receive(:post).with(
        '/oauth/ro',
        client_id: @instance.client_id, username: 'test@test.com',
        password: 'password', scope: 'openid', connection: 'Username-Password-Authentication',
        grant_type: 'password', id_token: nil, device: nil
      )
      @instance.login('test@test.com', 'password')
    end
    it { expect { @instance.login('', '') }.to raise_error 'Must supply a valid username' }
    it { expect { @instance.login('username', '') }.to raise_error 'Must supply a valid password' }
  end

  context '.signup' do
    it { expect(@instance).to respond_to(:signup) }
    it 'is expected to make post to /dbconnections/signup' do
      expect(@instance).to receive(:post).with(
        '/dbconnections/signup',
        client_id: @instance.client_id, email: 'test@test.com',
        password: 'password', connection: 'User'
      )
      @instance.signup('test@test.com', 'password', 'User')
    end
    it { expect { @instance.signup('', '') }.to raise_error 'Must supply a valid email' }
    it { expect { @instance.signup('email', '') }.to raise_error 'Must supply a valid password' }
  end

  context '.change_password' do
    it { expect(@instance).to respond_to(:change_password) }
    it 'is expected to make post to /dbconnections/change_password' do
      expect(@instance).to receive(:post).with(
        '/dbconnections/change_password',
        client_id: @instance.client_id, email: 'test@test.com',
        password: 'password', connection: 'User'
      )
      @instance.change_password('test@test.com', 'password', 'User')
    end
    it { expect { @instance.change_password('', '', '') }.to raise_error 'Must supply a valid email' }
  end

  context '.start_passwordless_email_flow' do
    it { expect(@instance).to respond_to(:start_passwordless_email_flow) }
    it 'is expected to make post to /passwordless/start' do
      expect(@instance).to receive(:post).with(
        '/passwordless/start',
        client_id: @instance.client_id,
        connection:  'email',
        email: 'test@test.com',
        send: 'link',
        authParams: {
          scope: 'scope',
          protocol: 'protocol'
        }
      )
      @instance.start_passwordless_email_flow('test@test.com', 'link', scope: 'scope', protocol: 'protocol')
    end
    it { expect { @instance.start_passwordless_email_flow('', '', '') }.to raise_error 'Must supply a valid email' }
  end

  context '.start_passwordless_sms_flow' do
    let(:phone_number) { Faker::PhoneNumber.cell_phone }
    it { expect(@instance).to respond_to(:start_passwordless_sms_flow) }
    it 'is expected to make post to /passwordless/start' do
      expect(@instance).to receive(:post).with(
        '/passwordless/start',
        client_id: @instance.client_id,
        connection: 'sms',
        phone_number: phone_number
      )
      @instance.start_passwordless_sms_flow(phone_number)
    end
    it { expect { @instance.start_passwordless_sms_flow('') }.to raise_error 'Must supply a valid phone number' }
  end

  context '.phone_login' do
    let(:phone_number) { Faker::PhoneNumber.cell_phone }
    let(:code) { Faker::Number.number(10) }
    it { expect(@instance).to respond_to(:phone_login) }
    it 'is expected to make post to /oauth/ro' do
      expect(@instance).to receive(:post).with(
        '/oauth/ro',
        client_id: @instance.client_id, username: phone_number,
        password: code, connection: 'sms',
        scope: 'openid', grant_type: 'password'
      )
      @instance.phone_login(phone_number, code)
    end
    it { expect { @instance.phone_login('', '') }.to raise_error 'Must supply a valid phone number' }
    it { expect { @instance.phone_login('phone', '') }.to raise_error 'Must supply a valid code' }
  end

  context '.saml_metadata' do
    it { expect(@instance).to respond_to(:saml_metadata) }
    it 'is expected to make post to /samlp/metadata/client-id' do
      expect(@instance).to receive(:get).with("/samlp/metadata/#{@instance.client_id}")
      @instance.saml_metadata
    end
  end

  context '.wsfed_metadata' do
    it { expect(@instance).to respond_to(:wsfed_metadata) }
    it 'is expected to make post to /wsfed/FederationMetadata/2007-06/FederationMetadata.xml' do
      expect(@instance).to receive(:get).with('/wsfed/FederationMetadata/2007-06/FederationMetadata.xml')
      @instance.wsfed_metadata
    end
  end

  context '.authorization_url' do
    let(:redirect_uri) { 'http://redirect.com' }
    let(:audience) { 'http://api-url.com' }
    it { expect(@instance).to respond_to(:authorization_url) }
    it 'is expected to return an authorization url' do
      expect(@instance.authorization_url(redirect_uri, audience).to_s).to eq(
        "https://#{@instance.domain}/authorize?audience=#{audience}&client_id=#{@instance.client_id}&"\
        "response_type=code&redirect_uri=#{redirect_uri}"
      )
    end
    let(:additional_parameters) { { additional_parameters: { aparam1: 'test1' } } }
    it 'is expected to return an authorization url with additionalParameters' do
      expect(@instance.authorization_url(redirect_uri, audience, additional_parameters).to_s).to eq(
        "https://#{@instance.domain}/authorize?audience=#{audience}&client_id=#{@instance.client_id}&"\
        "response_type=code&redirect_uri=#{redirect_uri}&aparam1=test1"
      )
    end
    let(:state) { { state: 'state1' } }
    it 'is expected to return an authorization url with additionalParameters' do
      expect(@instance.authorization_url(redirect_uri, audience, state).to_s).to eq(
        "https://#{@instance.domain}/authorize?audience=#{audience}&client_id=#{@instance.client_id}&"\
        "response_type=code&redirect_uri=#{redirect_uri}&state=state1"
      )
    end
    let(:connection) { { connection: 'connection-1' } }
    it 'is expected to return an authorization url with additionalParameters' do
      expect(@instance.authorization_url(redirect_uri, audience, connection).to_s).to eq(
        "https://#{@instance.domain}/authorize?audience=#{audience}&client_id=#{@instance.client_id}&"\
        "response_type=code&connection=connection-1&redirect_uri=#{redirect_uri}"
      )
    end
    it { expect { @instance.authorization_url('', '') }.not_to raise_error 'Must supply a valid redirect_uri' }
  end

  context '.refresh_delegation' do
    it { expect(@instance).to respond_to(:refresh_delegation) }
    it "is expected to make post request to '/delegation'" do
      expect(@instance).to receive(:post).with(
        '/delegation',
        client_id: @instance.client_id,
        grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        refresh_token: 'id_token', target: '', api_type: '', scope: '',
        additional_parameter: 'parameter'
      )
      @instance.refresh_delegation('id_token', '', '', '', additional_parameter: 'parameter')
    end
    it { expect { @instance.refresh_delegation('', '', '', '') }.to raise_error 'Must supply a valid token to refresh' }
  end

  context '.delegation' do
    it { expect(@instance).to respond_to(:delegation) }
    it "is expected to make post request to '/delegation'" do
      expect(@instance).to receive(:post).with(
        '/delegation',
        client_id: @instance.client_id,
        grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        id_token: 'token',
        target: 'target',
        scope: '',
        api_type: 'app'
      )
      @instance.delegation('token', 'target', '')
    end
    it "is expected to make post request to '/delegation'
      with specified api_type" do
      expect(@instance).to receive(:post).with(
        '/delegation',
        client_id: @instance.client_id,
        grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        id_token: 'id_token', target: '', scope: '',
        api_type: 'salesforce_api'
      )
      @instance.delegation('id_token', '', '', 'salesforce_api')
    end
    it 'allows to pass extra parameters' do
      expect(@instance).to receive(:post).with(
        '/delegation',
        client_id: @instance.client_id,
        grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        id_token: 'id_token', target: '', scope: '', api_type: '',
        community_name: 'test-community', community_url: 'test-url'
      )
      @instance.delegation(
        'id_token', '', '', '',
        community_name: 'test-community', community_url: 'test-url'
      )
    end
    it { expect { @instance.delegation('', nil, nil, nil) }.to raise_error 'Must supply a valid id_token' }
  end

  context '.unlink_user' do
    it { expect(@instance).to respond_to(:unlink_user) }
    it 'is expected to make post to /unlink' do
      expect(@instance).to receive(:post).with('/unlink', access_token: 'access-token', user_id: 'user-id')
      @instance.unlink_user('access-token', 'user-id')
    end
    it { expect { @instance.unlink_user('', '') }.to raise_error 'Must supply a valid access_token' }
    it { expect { @instance.unlink_user('token', '') }.to raise_error 'Must supply a valid user_id' }
  end

  context '.user_info' do
    it { expect(@instance).to respond_to(:user_info) }
    it 'is expected to make post to /userinfo' do
      expect(@instance).to receive(:get).with('/userinfo')
      @instance.user_info
    end
  end

  context '.logout_url' do
    let(:return_to) { 'http://returnto.com' }
    it { expect(@instance).to respond_to(:logout_url) }
    it 'is expected to return a logout url' do
      expect(@instance.logout_url(return_to).to_s).to eq(
        "https://#{@instance.domain}/v2/logout?returnTo=#{return_to}"
      )
    end
    let(:federated) { true }
    it 'is expected to return a federated logout url' do
      expect(@instance.logout_url(return_to, federated).to_s).to eq(
        "https://#{@instance.domain}/v2/logout?returnTo=#{return_to}&federated"
      )
    end
  end

  context '.samlp_url' do
    it { expect(@instance).to respond_to(:samlp_url) }
    it 'is expected to get the samlp url' do
      expect(@instance.samlp_url.to_s).to eq(
        "https://#{@instance.domain}/samlp/#{@instance.client_id}?connection=Username-Password-Authentication"
      )
    end
    it 'is expected to get the samlp url with fb connection' do
      expect(@instance.samlp_url('facebook').to_s).to eq(
        "https://#{@instance.domain}/samlp/#{@instance.client_id}?connection=facebook"
      )
    end
  end

  context '.wsfed_url' do
    it { expect(@instance).to respond_to(:wsfed_url) }
    it 'is expected to get the wsfed url' do
      expect(@instance.wsfed_url.to_s).to eq(
        "https://#{@instance.domain}/wsfed/#{@instance.client_id}?whr=Username-Password-Authentication"
      )
    end
    it 'is expected to get the wsfed url with fb connection' do
      expect(@instance.wsfed_url('facebook').to_s).to eq(
        "https://#{@instance.domain}/wsfed/#{@instance.client_id}?whr=facebook"
      )
    end
  end
end
