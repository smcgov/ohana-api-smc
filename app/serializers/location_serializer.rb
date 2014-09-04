class LocationSerializer < ActiveModel::Serializer
  attributes :id, :accessibility, :admin_emails, :coordinates, :description,
             :emails, :hours, :kind, :languages, :latitude, :longitude,
             :market_match, :name, :payments, :products, :short_desc, :slug,
             :transportation, :updated_at, :urls, :url

  has_one :address
  has_many :contacts
  has_many :faxes
  has_one :mail_address
  has_many :phones
  has_many :services
  has_one :organization

  def url
    api_location_url(object)
  end

  def accessibility
    object.accessibility.map(&:text)
  end

  def coordinates
    return [] unless object.longitude.present? && object.latitude.present?
    [object.longitude, object.latitude]
  end

  def kind
    object.kind.text
  end

  def include_payments?
    object.kind == 'farmers_markets'
  end

  def include_products?
    object.kind == 'farmers_markets'
  end

  def include_market_match?
    object.kind == 'farmers_markets'
  end
end
