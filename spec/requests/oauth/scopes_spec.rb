require File.expand_path(File.dirname(__FILE__) + '/../acceptance_helper')

feature 'Authorization with scopes' do

  let!(:application) { FactoryGirl.create :application }
  let!(:user)        { FactoryGirl.create :user }

  let!(:authorization_params) {{
    grant_type: 'password',
    username:   'alice@example.com',
    password:   'password',
  }}

  %w(resources resources.read devices devices.read types types.read locations locations.read).each do |scope| 

    describe "with valid scope #{scope}" do

      before { authorization_params[:scope] = scope }

      describe 'when sends an authorization request' do

        before do
          page.driver.browser.authorize application.uid, application.secret
          page.driver.post '/oauth/token', authorization_params
        end

        let(:token)    { Doorkeeper::AccessToken.last }
        subject(:json) { Hashie::Mash.new JSON.parse(page.source) }

        its(:access_token)  { should_not be_nil }
      end
    end
  end

  %w(not-valid).each do |scope| 

    describe "with not valid scope #{scope}" do

      before { authorization_params[:scope] = scope }

      describe 'when sends an authorization request' do

        before do
          page.driver.browser.authorize application.uid, application.secret
          page.driver.post '/oauth/token', authorization_params
        end

        let(:token)    { Doorkeeper::AccessToken.last }
        subject(:json) { Hashie::Mash.new JSON.parse(page.source) }

        its(:error) { should == 'invalid_scope' }
        its(:error_description) { should match 'The requested scope is invalid, unknown, or malformed' }
      end
    end
  end
end