module Api
  module V1
    class RootController < ApplicationController
      def index
        json_for_root_endpoint = {
          organizations_url: "#{api_organizations_url}{?page,per_page}",
          organization_url: "#{api_organizations_url}/{organization}",
          organization_locations_url: "#{api_url}/organizations/{organization}" \
                                      "/locations{?page,per_page}",
          locations_url: "#{api_locations_url}{?page,per_page}",
          location_url: "#{api_locations_url}/{location}",
          location_search_url: "#{api_search_index_url}{?category,email," \
                               "keyword,language,lat_lng,location,market_match,payment,product," \
                               "org_name,radius,service_area,status,page,per_page}"
        }
        render json: json_for_root_endpoint, status: :ok
      end
    end
  end
end
