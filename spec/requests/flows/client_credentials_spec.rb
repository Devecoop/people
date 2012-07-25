require File.expand_path(File.dirname(__FILE__) + '/../acceptance_helper')

feature 'client credentials flow' do

  before { cleanup }

  let!(:application) { FactoryGirl.create :application }
  let!(:user)        { FactoryGirl.create :user }

  let!(:authorization_params) {{
    grant_type: 'client_credentials',
    scope:      'public write',
  }}

  describe 'when sends an authorization request' do

    before do
      page.driver.browser.authorize application.uid, application.secret
      page.driver.post '/oauth/token', authorization_params
    end

    it 'returns valid json' do
      expect { JSON.parse(page.source) }.to_not raise_error
    end

    describe 'when returns the acces token representation' do

      let(:token)     { Doorkeeper::AccessToken.last }
      subject(:json)  { Hashie::Mash.new JSON.parse(page.source) }

      its(:access_token)  { should == token.token }
      its(:expires_in)    { should == 7200 }
      its(:token_type)    { should == 'bearer' }
      its(:refresh_token) { should == token.refresh_token }
    end
  end
end
