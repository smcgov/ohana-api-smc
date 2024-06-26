require 'rails_helper'

describe Location do
  subject { build(:location) }

  it { is_expected.to be_valid }

  # Associations
  it { is_expected.to belong_to(:organization).required }
  it { is_expected.to have_one(:address).dependent(:destroy) }
  it { is_expected.to have_many(:contacts).dependent(:destroy) }
  it { is_expected.to have_one(:mail_address).dependent(:destroy).inverse_of(:location) }
  it { is_expected.to have_many(:phones).dependent(:destroy).inverse_of(:location) }
  it { is_expected.to have_many(:services).dependent(:destroy) }
  it { is_expected.to have_many(:regular_schedules).dependent(:destroy).inverse_of(:location) }
  it { is_expected.to have_many(:holiday_schedules).dependent(:destroy).inverse_of(:location) }

  it { is_expected.to accept_nested_attributes_for(:address).allow_destroy(true) }
  it { is_expected.to accept_nested_attributes_for(:mail_address).allow_destroy(true) }
  it { is_expected.to accept_nested_attributes_for(:phones).allow_destroy(true) }
  it { is_expected.to accept_nested_attributes_for(:regular_schedules).allow_destroy(true) }
  it { is_expected.to accept_nested_attributes_for(:holiday_schedules).allow_destroy(true) }

  it { is_expected.to validate_presence_of(:name).with_message("can't be blank for Location") }
  it { is_expected.to validate_presence_of(:kind).with_message("can't be blank for Location") }
  it do
    is_expected.to validate_presence_of(:description).with_message("can't be blank for Location")
  end

  # Validations
  it { is_expected.to allow_value('http://monfresh.com').for(:website) }

  it do
    is_expected.not_to allow_value('http://').
      for(:website).
      with_message('http:// is not a valid URL')
  end

  it { is_expected.not_to allow_value('http:///codeforamerica.org').for(:website) }
  it { is_expected.not_to allow_value('http://codeforamericaorg').for(:website) }
  it { is_expected.not_to allow_value('www.codeforamerica.org').for(:website) }

  it { is_expected.to allow_value('moncef@blah.com').for(:email) }

  it do
    is_expected.not_to allow_value('moncef@blahcom').
      for(:email).
      with_message('moncef@blahcom is not a valid email')
  end

  it { is_expected.not_to allow_value('moncef.blahcom').for(:email) }
  it { is_expected.not_to allow_value(' foo @bar.com').for(:email) }

  it { is_expected.to allow_value(%w[moncef@blah.com]).for(:admin_emails) }

  it do
    is_expected.not_to allow_value(%w[moncef@blahcom]).
      for(:admin_emails).
      with_message('moncef@blahcom is not a valid email')
  end

  it { is_expected.not_to allow_value(%w[moncef.blahcom]).for(:admin_emails) }
  it { is_expected.not_to allow_value([' foo @bar.com']).for(:admin_emails) }

  describe 'invalidations' do
    context 'non-virtual and without an address' do
      subject { build(:location, address: nil) }
      it { is_expected.not_to be_valid }
    end
  end

  describe 'auto_strip_attributes' do
    it 'strips extra whitespace before validation' do
      loc = build(:loc_with_extra_whitespace)
      loc.valid?
      expect(loc.description).to eq('Provides job training')
      expect(loc.name).to eq('VRS Services')
      expect(loc.short_desc).to eq('Provides job training.')
      expect(loc.transportation).to eq('BART stop 1 block away.')
      expect(loc.website).to eq('http://samaritanhouse.com')
      expect(loc.admin_emails).to eq(['foo@bar.com'])
      expect(loc.email).to eq('bar@foo.com')
      expect(loc.languages).to eq(%w[English Vietnamese])
    end
  end

  # Instance methods
  it { is_expected.to respond_to(:address_street) }
  describe '#address_street' do
    it 'returns address.address_1' do
      expect(subject.address_street).to eq(subject.address.address_1)
    end
  end

  it { is_expected.to respond_to(:mail_address_city) }
  describe '#mail_address_city' do
    it 'returns mail_address.city' do
      loc = build(:mail_address).location
      expect(loc.mail_address_city).to eq(loc.mail_address.city)
    end
  end

  it { is_expected.to respond_to(:full_physical_address) }
  describe '#full_physical_address' do
    it 'joins all address elements into one string' do
      combined = "#{subject.address.address_1}, " \
                 "#{subject.address.city}, #{subject.address.state_province} " \
                 "#{subject.address.postal_code}"

      expect(subject.full_physical_address).to eq(combined)
    end
  end

  describe 'slug candidates' do
    before(:each) { @loc = create(:location) }

    context 'when address is present and name is already taken' do
      it 'creates a new slug based on address street' do
        new_loc = create(:nearby_loc)
        new_loc.update!(name: 'VRS Services')
        expect(new_loc.reload.slug).to eq('vrs-services-250-myrtle-road')
      end
    end

    context 'when mail_address is present and name is taken' do
      it 'creates a new slug based on mail_address city' do
        new_loc = create(:mail_address).location
        new_loc.update!(name: 'VRS Services')
        expect(new_loc.reload.slug).to eq('vrs-services-belmont')
      end
    end

    context 'when name is not taken' do
      it 'creates a new slug based on name' do
        new_loc = create(:no_address)
        expect(new_loc.reload.slug).to eq('no-address')
      end
    end

    context 'when name is not updated' do
      it "doesn't update slug" do
        @loc.update!(description: 'new description')
        expect(@loc.reload.slug).to eq('vrs-services')
      end
    end

    context "without a description but is a Farmers' Market" do
      subject { build(:farmers_market_loc, description: nil) }
      it { should be_valid }
    end
  end

  describe 'geolocation methods' do
    before(:each) { @loc = create(:location) }

    it "doesn't geocode when address hasn't changed" do
      @loc.name = 'new name'
      expect(@loc).not_to receive(:geocode)
      @loc.save!
    end

    it "doesn't geocode when location is new and has coordinates" do
      loc = build(:location_with_admin)
      expect(loc).not_to receive(:geocode)
      loc.save!
    end

    it "doesn't geocode when location is virtual and has coordinates" do
      loc = build(:location_with_admin, virtual: true)
      expect(loc).not_to receive(:geocode)
      loc.save!
    end

    it "doesn't geocode when location has coordinates but no address" do
      loc = build(:no_address, latitude: 37.5808591, longitude: -122.343072)
      expect(loc).not_to receive(:geocode)
      loc.save!
    end

    it "doesn't geocode when location has neither address nor coordinates" do
      org = create(:nearby_org)
      loc = Location.new(
        name: 'foo',
        description: 'bar',
        virtual: true,
        kind: :other
      )
      loc.organization_id = org.id
      expect(loc).not_to receive(:geocode)
      loc.save!
    end

    it 'geocodes when address has changed' do
      address = {
        address_1: '1 davis drive', city: 'belmont', state_province: 'CA',
        postal_code: '94002', country: 'US'
      }
      coords = [@loc.longitude, @loc.latitude]

      @loc.update!(address_attributes: address)
      expect(@loc.reload.latitude).to_not eq(coords.second)
    end

    it 'does not geocode when address is added to location with coords' do
      loc = create(:no_address, latitude: 37.5808591, longitude: -122.343072)

      expect(loc).to_not receive(:geocode)

      loc.update!(address_attributes: attributes_for(:address))
    end

    it 'geocodes when address is added to virtual location that did not have one' do
      loc = create(:no_address)
      expect(loc.latitude).to be_nil

      loc.update!(address_attributes: attributes_for(:address))

      expect(loc.reload.latitude).to be_present
    end

    it 'geocodes when location is new, has an address, but no coordinates' do
      org = create(:nearby_org)
      loc = Location.new(
        name: 'foo',
        description: 'bar',
        address_attributes: attributes_for(:address)
      )
      loc.organization_id = org.id

      expect(loc).to receive(:geocode)

      loc.save
    end
  end

  describe 'native Postgres array columns' do
    it 'is not valid when the value is not an array' do
      org = build_stubbed(:nearby_org)
      loc = Location.new(
        name: 'foo',
        description: 'bar',
        address_attributes: attributes_for(:address),
        languages: 'Spanish',
        organization_id: org.id,
        kind: :arts
      )

      expect(loc).to_not be_valid
    end

    it 'is valid when the value is an array' do
      org = create(:nearby_org)
      loc = Location.new(
        name: 'foo',
        description: 'bar',
        address_attributes: attributes_for(:address),
        languages: %w[French],
        kind: :arts
      )
      loc.organization_id = org.id

      expect(loc).to be_valid
    end
  end

  describe 'accessibility' do
    it 'allows a specific set of values' do
      valid_accessibilities = %i[cd deaf_interpreter disabled_parking elevator ramp restroom
                                 tape_braille tty wheelchair wheelchair_van]
      valid_accessibilities.each do |accessibility|
        location = build(:location, accessibility: [accessibility])
        expect(location).to be_valid
      end
    end

    it 'allows multiple valid values' do
      valid_accessibilities = %i[deaf_interpreter disabled_parking]
      location = build(:location, accessibility: valid_accessibilities)
      expect(location).to be_valid
    end

    it 'converts invalid values to nil' do
      invalid_accessibilities = %w[open closed]
      location = build(:location)
      invalid_accessibilities.each do |accessibility|
        location = build(:location, accessibility: [accessibility])
        expect(location).not_to be_valid
      end
    end
  end
end
