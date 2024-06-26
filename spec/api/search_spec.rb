require 'rails_helper'

describe "GET 'search'" do
  context 'with valid keyword only' do
    before :all do
      @loc = create(:location)
      @nearby = create(:nearby_loc)
      @loc.update(updated_at: 1.day.ago)
      @nearby.update(updated_at: 1.hour.ago)
    end

    before :each do
      get api_search_index_url(keyword: 'jobs', per_page: 1, subdomain: api_subdomain)
    end

    after(:all) do
      Organization.find_each(&:destroy)
    end

    it 'returns a successful status code' do
      expect(response).to be_successful
    end

    it 'is json' do
      expect(response.media_type).to eq('application/json')
    end

    it 'returns locations' do
      expect(json.first.keys).to include('coordinates')
    end

    it 'is a paginated resource' do
      get api_search_index_url(
        keyword: 'jobs', per_page: 1, page: 2, subdomain: api_subdomain
      )
      expect(json.length).to eq(1)
    end

    it 'returns an X-Total-Count header' do
      expect(response.status).to eq(200)
      expect(json.length).to eq(1)
      expect(headers['X-Total-Count']).to eq '2'
    end

    it 'includes kind' do
      expect(json.first['kind']).to eq 'Human Services'
    end

    it 'sorts by updated_at when results have same full text search rank' do
      expect(json.first['name']).to eq @nearby.name
    end
  end

  describe 'specs that depend on :farmers_market_loc factory' do
    before(:all) do
      create(:farmers_market_loc)
    end

    after(:all) do
      Organization.find_each(&:destroy)
    end

    context 'with radius too small but within range' do
      it 'returns the farmers market name' do
        get api_search_index_url(
          location: 'la honda, ca', radius: 0.05, subdomain: api_subdomain
        )
        expect(json.first['name']).to eq('Belmont Farmers Market')
      end
    end

    context 'with radius greater than 50' do
      it 'uses a radius of 50' do
        get api_search_index_url(
          location: 'san gregorio, ca', radius: 100, subdomain: api_subdomain
        )
        expect(json.first['name']).to eq('Belmont Farmers Market')
      end
    end

    context 'with radius not within range' do
      it 'returns an empty response array' do
        get api_search_index_url(
          location: 'pescadero, ca', radius: 5, subdomain: api_subdomain
        )
        expect(json).to eq([])
      end
    end

    context 'with invalid zip' do
      it 'returns no results' do
        get api_search_index_url(location: '00000', subdomain: api_subdomain)
        expect(json.length).to eq 0
      end
    end

    context 'with invalid location' do
      it 'returns no results' do
        get api_search_index_url(location: '94403ab', subdomain: api_subdomain)
        expect(json.length).to eq 0
      end
    end
  end

  describe 'specs that depend on :location factory' do
    before(:all) do
      create(:location)
    end

    after(:all) do
      Organization.find_each(&:destroy)
    end

    context 'with invalid radius' do
      before :each do
        get api_search_index_url(location: '94403', radius: 'ads', subdomain: api_subdomain)
      end

      it 'returns a 400 status code' do
        expect(response.status).to eq(400)
      end

      it 'is json' do
        expect(response.media_type).to eq('application/json')
      end

      it 'includes an error description' do
        expect(json['description']).to eq('Radius must be a Float between 0.1 and 50.')
      end
    end

    context 'with invalid lat_lng parameter' do
      before :each do
        get api_search_index_url(lat_lng: '37.6856578-122.4138119', subdomain: api_subdomain)
      end

      it 'returns a 400 status code' do
        expect(response.status).to eq 400
      end

      it 'includes an error description' do
        expect(json['description']).
          to eq 'lat_lng must be a comma-delimited lat,long pair of floats.'
      end
    end

    context 'with invalid (non-numeric) lat_lng parameter' do
      before :each do
        get api_search_index_url(lat_lng: 'Apple,Pear', subdomain: api_subdomain)
      end

      it 'returns a 400 status code' do
        expect(response.status).to eq 400
      end

      it 'includes an error description' do
        expect(json['description']).
          to eq 'lat_lng must be a comma-delimited lat,long pair of floats.'
      end
    end

    context 'with plural version of keyword' do
      it "finds the plural occurrence in location's name field" do
        get api_search_index_url(keyword: 'services', subdomain: api_subdomain)
        expect(json.first['name']).to eq('VRS Services')
      end

      it "finds the plural occurrence in location's description field" do
        get api_search_index_url(keyword: 'jobs', subdomain: api_subdomain)
        expect(json.first['description']).to eq('Provides jobs training')
      end
    end

    context 'with singular version of keyword' do
      it "finds the plural occurrence in location's name field" do
        get api_search_index_url(keyword: 'service', subdomain: api_subdomain)
        expect(json.first['name']).to eq('VRS Services')
      end

      it "finds the plural occurrence in location's description field" do
        get api_search_index_url(keyword: 'job', subdomain: api_subdomain)
        expect(json.first['description']).to eq('Provides jobs training')
      end
    end
  end

  describe 'specs that depend on :location and :nearby_loc' do
    before(:all) do
      create(:location)
      create(:nearby_loc)
    end

    after(:all) do
      Organization.find_each(&:destroy)
    end

    context 'when keyword only matches one location' do
      it 'only returns 1 result' do
        get api_search_index_url(keyword: 'library', subdomain: api_subdomain)
        expect(json.length).to eq(1)
      end
    end

    context "when keyword doesn't match anything" do
      it 'returns no results' do
        get api_search_index_url(keyword: 'blahab', subdomain: api_subdomain)
        expect(json.length).to eq(0)
      end
    end

    context 'with keyword and location parameters' do
      it 'only returns locations matching both parameters' do
        get api_search_index_url(
          keyword: 'books', location: 'Burlingame', subdomain: api_subdomain
        )
        expect(headers['X-Total-Count']).to eq '1'
        expect(json.first['name']).to eq('Library')
      end
    end

    context 'when keyword parameter has multiple words' do
      it 'only returns locations matching all words' do
        get api_search_index_url(keyword: 'library books jobs', subdomain: api_subdomain)
        expect(headers['X-Total-Count']).to eq '1'
        expect(json.first['name']).to eq('Library')
      end
    end
  end

  context 'lat_lng search' do
    it 'returns one result' do
      create(:location)
      create(:farmers_market_loc)
      get api_search_index_url(lat_lng: '37.583939,-122.3715745', subdomain: api_subdomain)
      expect(json.length).to eq 1
    end
  end

  context 'with singular version of keyword' do
    it 'finds the plural occurrence in organization name field' do
      create(:nearby_loc)
      get api_search_index_url(keyword: 'food stamp', subdomain: api_subdomain)
      expect(json.first['organization']['name']).to eq('Food Stamps')
    end

    it "finds the plural occurrence in service's keywords field" do
      create_service
      get api_search_index_url(keyword: 'pantry', subdomain: api_subdomain)
      expect(json.first['name']).to eq('VRS Services')
    end
  end

  context 'with plural version of keyword' do
    it 'finds the plural occurrence in organization name field' do
      create(:nearby_loc)
      get api_search_index_url(keyword: 'food stamps', subdomain: api_subdomain)
      expect(json.first['organization']['name']).to eq('Food Stamps')
    end

    it "finds the plural occurrence in service's keywords field" do
      create_service
      get api_search_index_url(keyword: 'emergencies', subdomain: api_subdomain)
      expect(json.first['name']).to eq('VRS Services')
    end
  end

  context 'when keyword matches category name' do
    before(:each) do
      create(:far_loc)
      create(:loc_with_nil_fields)
      cat = create(:category)
      create_service
      @service.category_ids = [cat.id]
      @service.save!
    end

    it 'boosts location whose services category name matches the query' do
      get api_search_index_url(keyword: 'food', subdomain: api_subdomain)
      expect(headers['X-Total-Count']).to eq '3'
      expect(json.first['name']).to eq 'VRS Services'
    end
  end

  context 'with org_name parameter' do
    before(:each) do
      create(:nearby_loc)
      create(:location)
      create(:soup_kitchen)
    end

    it 'returns results when org_name only contains one word that matches' do
      get api_search_index_url(org_name: 'stamps', subdomain: api_subdomain)
      expect(headers['X-Total-Count']).to eq '1'
      expect(json.first['name']).to eq('Library')
    end

    it 'only returns locations whose org name matches all terms' do
      get api_search_index_url(org_name: 'Food+Pantry', subdomain: api_subdomain)
      expect(headers['X-Total-Count']).to eq '1'
      expect(json.first['name']).to eq('Soup Kitchen')
    end

    it 'allows searching for both org_name and location' do
      get api_search_index_url(
        org_name: 'stamps',
        location: '1236 Broadway, Burlingame, CA 94010', subdomain: api_subdomain
      )
      expect(headers['X-Total-Count']).to eq '1'
      expect(json.first['name']).to eq('Library')
    end

    it 'allows searching for blank org_name and location' do
      get api_search_index_url(org_name: '', location: '', subdomain: api_subdomain)
      expect(response.status).to eq 200
      expect(json.length).to eq(3)
    end
  end

  context 'when email parameter contains custom domain' do
    it "finds domain name when url contains 'www'" do
      create(:location, website: 'http://www.smchsa.org')
      create(:nearby_loc, email: 'info@cfa.org')
      get "#{api_search_index_url(subdomain: api_subdomain)}?email=foo@smchsa.org"
      expect(headers['X-Total-Count']).to eq '1'
    end

    it 'finds naked domain name' do
      create(:location, website: 'http://smchsa.com')
      create(:nearby_loc, email: 'hello@cfa.com')
      get "#{api_search_index_url(subdomain: api_subdomain)}?email=foo@smchsa.com"
      expect(headers['X-Total-Count']).to eq '1'
    end

    it 'finds long domain name in both url and email' do
      create(:location, website: 'http://smchsa.org')
      create(:nearby_loc, email: 'info@smchsa.org')
      get "#{api_search_index_url(subdomain: api_subdomain)}?email=foo@smchsa.org"
      expect(headers['X-Total-Count']).to eq '2'
    end

    it 'finds domain name when URL contains path' do
      create(:location, website: 'http://www.smchealth.org/mcah')
      create(:nearby_loc, email: 'org@mcah.org')
      get "#{api_search_index_url(subdomain: api_subdomain)}?email=foo@smchealth.org"
      expect(headers['X-Total-Count']).to eq '1'
    end

    it 'finds domain name when URL contains multiple paths' do
      create(:location, website: 'http://www.smchsa.org/portal/site/planning')
      create(:nearby_loc, email: 'sanmateo@ca.us')
      get "#{api_search_index_url(subdomain: api_subdomain)}?email=foo@smchsa.org"
      expect(headers['X-Total-Count']).to eq '1'
    end

    it 'finds domain name when URL contains a dash' do
      create(:location, website: 'http://www.bar-connect.ca.gov')
      create(:nearby_loc, email: 'gov@childsup-connect.gov')
      get "#{api_search_index_url(subdomain: api_subdomain)}?email=foo@bar-connect.ca.gov"
      expect(headers['X-Total-Count']).to eq '1'
    end

    it 'finds domain name when URL contains a number' do
      create(:location, website: 'http://www.prenatalto3.org')
      create(:nearby_loc, email: 'info@rwc2020.org')
      get "#{api_search_index_url(subdomain: api_subdomain)}?email=foo@prenatalto3.org"
      expect(headers['X-Total-Count']).to eq '1'
    end

    it 'returns locations where either email or admins fields match' do
      create(:location, email: 'moncef@smcgov.org')
      create(:location_with_admin)
      get api_search_index_url(email: 'moncef@smcgov.org', subdomain: api_subdomain)
      expect(headers['X-Total-Count']).to eq '2'
    end

    it 'does not return locations if email prefix is the only match' do
      create(:location, email: 'moncef@smcgov.org')
      create(:location_with_admin)
      get api_search_index_url(email: 'moncef@gmail.com', subdomain: api_subdomain)
      expect(headers['X-Total-Count']).to eq '0'
    end
  end

  context 'when email parameter contains generic domain' do
    it "doesn't return results for gmail domain" do
      create(:location, email: 'info@gmail.com')
      get "#{api_search_index_url(subdomain: api_subdomain)}?email=foo@gmail.com"
      expect(headers['X-Total-Count']).to eq '0'
    end

    it "doesn't return results for aol domain" do
      create(:location, email: 'info@aol.com')
      get "#{api_search_index_url(subdomain: api_subdomain)}?email=foo@aol.com"
      expect(headers['X-Total-Count']).to eq '0'
    end

    it "doesn't return results for hotmail domain" do
      create(:location, email: 'info@hotmail.com')
      get "#{api_search_index_url(subdomain: api_subdomain)}?email=foo@hotmail.com"
      expect(headers['X-Total-Count']).to eq '0'
    end

    it "doesn't return results for yahoo domain" do
      create(:location, email: 'info@yahoo.com')
      get "#{api_search_index_url(subdomain: api_subdomain)}?email=foo@yahoo.com"
      expect(headers['X-Total-Count']).to eq '0'
    end

    it "doesn't return results for sbcglobal domain" do
      create(:location, email: 'info@sbcglobal.net')
      get "#{api_search_index_url(subdomain: api_subdomain)}?email=foo@sbcglobal.net"
      expect(headers['X-Total-Count']).to eq '0'
    end

    it 'does not return locations if domain is the only match' do
      create(:location, email: 'moncef@gmail.com', admin_emails: ['moncef@gmail.com'])
      get api_search_index_url(email: 'foo@gmail.com', subdomain: api_subdomain)
      expect(headers['X-Total-Count']).to eq '0'
    end

    it 'returns results if admin email matches parameter' do
      create(:location, admin_emails: ['info@sbcglobal.net'])
      get "#{api_search_index_url(subdomain: api_subdomain)}?email=info@sbcglobal.net"
      expect(headers['X-Total-Count']).to eq '1'
    end

    it 'returns results if email matches parameter' do
      create(:location, email: 'info@sbcglobal.net')
      get "#{api_search_index_url(subdomain: api_subdomain)}?email=info@sbcglobal.net"
      expect(headers['X-Total-Count']).to eq '1'
    end
  end

  context 'when email parameter only contains generic domain name' do
    it "doesn't return results" do
      create(:location, email: 'info@gmail.com')
      get api_search_index_url(email: 'gmail.com', subdomain: api_subdomain)
      expect(headers['X-Total-Count']).to eq '0'
    end
  end

  describe 'sorting search results' do
    context 'sort when only location is present' do
      it 'sorts by distance by default' do
        create(:location)
        create(:nearby_loc)
        get api_search_index_url(
          location: '1236 Broadway, Burlingame, CA 94010', subdomain: api_subdomain
        )
        expect(json.first['name']).to eq('VRS Services')
      end
    end
  end

  context 'when location has missing fields' do
    it 'includes attributes with nil or empty values' do
      create(:loc_with_nil_fields)
      get api_search_index_url(keyword: 'belmont', subdomain: api_subdomain)
      keys = json.first.keys
      %w[phones address].each do |key|
        expect(keys).to include(key)
      end
    end
  end

  # SMC-specific search parameters
  context 'with kind parameter' do
    before(:each) do
      create(:location)
      create(:nearby_loc)
      create(:farmers_market_loc)
    end

    it 'finds farmers markets' do
      get "/api/search?kind[]=farmers'%20markets"
      expect(json.length).to eq 1
      expect(json.first['name']).to eq 'Belmont Farmers Market'
    end

    it 'finds human services' do
      get '/api/search?kind[]=Human%20services'
      expect(json.length).to eq 1
      expect(json.first['name']).to eq 'Library'
    end

    it 'finds other' do
      get '/api/search?kind[]=other'
      expect(json.length).to eq 1
      expect(json.first['name']).to eq 'VRS Services'
    end

    it 'allows multiple kinds' do
      get '/api/search?kind[]=Other&kind[]=human%20Services'
      expect(headers['X-Total-Count']).to eq '2'
    end

    it 'allows single kind' do
      get '/api/search?kind=human%20Services'
      expect(headers['X-Total-Count']).to eq '1'
    end

    it 'allows sorting by kind (default order is asc)' do
      get '/api/search?kind[]=Other&kind[]=human%20services&' \
          'kind[]=farmers_markets&sort=kind'
      expect(headers['X-Total-Count']).to eq '3'
      expect(json.first['name']).to eq 'Belmont Farmers Market'
      expect(json[1]['name']).to eq 'Library'
      expect(json[2]['name']).to eq 'VRS Services'
    end

    it 'allows sorting by kind and ordering desc' do
      get '/api/search?kind[]=Other&kind[]=human%20services&' \
          'kind[]=farmers_markets&sort=kind&order=desc'
      expect(headers['X-Total-Count']).to eq '3'
      expect(json.first['name']).to eq 'VRS Services'
      expect(json[1]['name']).to eq 'Library'
      expect(json[2]['name']).to eq 'Belmont Farmers Market'
    end
  end

  context 'with service_area parameter' do
    before(:each) do
      loc1 = create(:location)
      loc2 = create(:nearby_loc)

      loc1.services.create!(attributes_for(:service).
        merge(service_areas: %w[Belmont Atherton]))

      loc2.services.create!(attributes_for(:service).
        merge(service_areas: %w[Alaska Arizona]))
    end

    it 'only returns locations with SMC service areas when param = smc' do
      get '/api/search?service_area=smc'
      expect(headers['X-Total-Count']).to eq '1'
      expect(json.first['name']).to eq 'VRS Services'
    end

    it 'allows searching for specific service areas' do
      get '/api/search?service_area=Arizona'
      expect(headers['X-Total-Count']).to eq '1'
      expect(json.first['name']).to eq 'Library'
    end
  end

  context 'with market_match parameter' do
    before(:each) do
      create(:farmers_market_loc)
      create(:location,
             kind: :farmers_markets,
             market_match: false, name: 'Not Participating')
    end

    it "only returns farmers' markets who participate in Market Match" do
      get '/api/search?market_match=1'
      expect(headers['X-Total-Count']).to eq '1'
      expect(json.first['name']).to eq 'Belmont Farmers Market'
    end

    it "only returns markets who don't participate in Market Match" do
      get '/api/search?market_match=0'
      expect(headers['X-Total-Count']).to eq '1'
      expect(json.first['name']).to eq 'Not Participating'
    end
  end

  context 'with payment parameter' do
    before(:each) do
      create(:farmers_market_loc)
      create(:location,
             kind: :farmers_markets,
             name: 'No SFMNP', payments: ['Credit'])
    end

    it "only returns farmers' markets who accept SFMNP" do
      get '/api/search?payment=SFMNP'
      expect(headers['X-Total-Count']).to eq '1'
      expect(json.first['name']).to eq 'Belmont Farmers Market'
    end
  end

  context 'with product parameter' do
    before(:each) do
      create(:farmers_market_loc)
      create(:location,
             kind: :farmers_markets,
             name: 'No Cheese', products: ['Baked Goods'])
    end

    it "only returns farmers' markets who sell Baked Goods" do
      get '/api/search?product=baked%20goods'
      expect(headers['X-Total-Count']).to eq '1'
      expect(json.first['name']).to eq 'No Cheese'
    end

    it 'finds a match when query is capitalized' do
      get '/api/search?product=Baked%20Goods'
      expect(headers['X-Total-Count']).to eq '1'
      expect(json.first['name']).to eq 'No Cheese'
    end
  end

  describe 'sorting search results' do
    context 'general keyword search' do
      it 'boosts entries with importance = 2 (human services)' do
        create(:nearby_loc)
        create(:location)

        get '/api/search?keyword=jobs'

        expect(headers['X-Total-Count']).to eq '2'
        expect(json[0]['name']).to eq 'Library'
      end

      it 'boosts entries with importance = 3 (SMC HSA locations)' do
        create(:farmers_market_loc)
        create(:nearby_loc)
        create(:location)

        get '/api/search?keyword=jobs'

        expect(headers['X-Total-Count']).to eq '3'
        expect(json[0]['name']).to eq 'Belmont Farmers Market'
        expect(json[1]['name']).to eq 'Library'
      end
    end
  end
end
