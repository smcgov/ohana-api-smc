require 'rails_helper'

describe 'POST /locations/:location_id/contacts' do
  before(:all) do
    @loc = create(:location)
  end

  before(:each) do
    @contact_attributes = { name: 'Moncef', title: 'Consultant' }
  end

  after(:all) do
    Organization.find_each(&:destroy)
  end

  it 'creates a contact with valid attributes' do
    post(
      api_location_contacts_url(@loc, subdomain: api_subdomain),
      @contact_attributes
    )
    expect(response.status).to eq(201)
    expect(json['name']).to eq(@contact_attributes[:name])
  end

  it "doesn't create a contact with invalid attributes" do
    post(
      api_location_contacts_url(@loc, subdomain: api_subdomain),
      email: 'belmont'
    )
    expect(response.status).to eq(422)
    expect(json['errors'].first['email']).to eq(['belmont is not a valid email'])
  end

  it "doesn't allow creating a contact without a valid token" do
    post(
      api_location_contacts_url(@loc, subdomain: api_subdomain),
      @contact_attributes,
      'HTTP_X_API_TOKEN' => 'invalid_token'
    )
    expect(response.status).to eq(401)
    expect(json['message']).
      to eq('This action requires a valid X-API-Token header.')
  end

  it 'creates a second contact for the specified location' do
    @loc.contacts.create!(@contact_attributes)
    post(
      api_location_contacts_url(@loc, subdomain: api_subdomain),
      name: 'foo', title: 'cfo'
    )
    get api_location_url(@loc, subdomain: api_subdomain)
    expect(json['contacts'].length).to eq 2
    expect(json['contacts'][1]['name']).to eq 'foo'
  end
end
