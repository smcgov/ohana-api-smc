module Api
  module V1
    class AddressController < ApplicationController
      include TokenValidator
      include CustomErrors

      def create
        location = Location.find(params[:location_id])
        address = location.create_address!(address_params) if location.address.blank?
        render json: address, status: :created
      end

      def update
        location = Location.find(params[:location_id])
        location.update!(address_attributes: address_params.merge!(id: params[:id]))
        render json: location.address, status: :ok
      end

      def destroy
        location = Location.find(params[:location_id])
        address_id = location.address.id
        location.address_attributes = { id: address_id, _destroy: '1' }
        location.save!
        head :no_content
      end

      private

      def address_params
        params.require(:address).permit(:city, :state_province, :address_1,
                                        :address_2, :postal_code, :country)
      end
    end
  end
end
