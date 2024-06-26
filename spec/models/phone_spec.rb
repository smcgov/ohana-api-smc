require 'rails_helper'

describe Phone do
  subject { build(:phone) }

  it { is_expected.to belong_to(:location).optional.touch(true).inverse_of(:phones) }
  it { is_expected.to belong_to(:contact).optional.touch(true).inverse_of(:phones) }
  it { is_expected.to belong_to(:service).optional.touch(true).inverse_of(:phones) }
  it { is_expected.to belong_to(:organization).optional }

  it do
    is_expected.to validate_presence_of(:number).
      with_message("can't be blank for Phone")
  end

  it { is_expected.to allow_value('703-555-1212', '800.123.4567', '711').for(:number) }

  it do
    is_expected.not_to allow_value('703-').for(:number).
      with_message('703- is not a valid US phone or fax number')
  end

  it { is_expected.to validate_numericality_of(:extension) }

  describe 'auto_strip_attributes' do
    it 'strips extra whitespace before validation' do
      phone = build(:phone_with_extra_whitespace)
      phone.valid?
      expect(phone.country_prefix).to eq('33')
      expect(phone.department).to eq('Information')
      expect(phone.number).to eq('650 851-1210')
      expect(phone.extension).to eq('2000')
      expect(phone.vanity_number).to eq('800-FLY-AWAY')
    end
  end

  describe 'parent presence validation' do
    it 'has at least one parent' do
      phone = build(:phone)
      expect(phone).to_not be_valid
      expect(phone.errors.messages[:base][0]).to include 'is missing a parent'
    end
  end

  describe 'number_type' do
    it 'allows a specific set of values' do
      valid_number_types = %w[fax hotline sms tty voice]
      location = build(:location)
      valid_number_types.each do |number_type|
        phone = build(:phone, location:, number_type:)
        expect(phone).to be_valid
      end
    end

    it 'converts invalid values to nil' do
      invalid_number_types = %w[emergency mobile landline]
      location = build(:location)
      invalid_number_types.each do |number_type|
        phone = build(:phone, location:, number_type:)
        expect(phone.number_type).to be_nil
      end
    end
  end
end
