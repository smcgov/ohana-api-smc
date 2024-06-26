require 'exceptions'

class LocationFilter
  class << self
    delegate :call, to: :new
  end

  def initialize(model_class = Location)
    @model_class = model_class
  end

  def call(location, lat_lng, radius)
    return @model_class.all if location.blank? && lat_lng.blank? && radius.blank?

    @model_class.near(coords(location, lat_lng), validated_radius(radius, 5))
  end

  def validated_radius(radius, custom_radius)
    return custom_radius if radius.blank?

    raise Exceptions::InvalidRadius if radius.to_d == 0.0.to_d

    # radius must be between 0.1 miles and 50 miles
    radius.to_f.clamp(0.1, 50)
  end

  private

  def result_for(location)
    Geocoder.search(location, bounds: SETTINGS[:bounds])
  end

  def coords(location, lat_lng)
    if location.present? && result_for(location).present?
      return result_for(location).first.coordinates
    end

    validated_coordinates(lat_lng) if lat_lng.present?
  end

  def validated_coordinates(lat_lng)
    lat, lng = lat_lng.split(',')
    raise Exceptions::InvalidLatLon if invalid_coordinates?(lat, lng)

    [Float(lat), Float(lng)]
  end

  def invalid_coordinates?(latitude, longitude)
    invalid_coordinate?(latitude) || invalid_coordinate?(longitude)
  end

  def invalid_coordinate?(coordinate)
    coordinate.to_d == 0.0.to_d
  end
end
