class Admin
  class AdminsController < ApplicationController
    before_action :authenticate_admin!
    layout 'admin'

    def edit
      authorize :admin, :edit?

      @update_admin = UpdateAdmin.new(nil)
    end

    def update
      authorize :admin, :update?

      @update_admin = UpdateAdmin.new(email_params[:email])

      success = @update_admin.call

      if success
        redirect_to admin_admins_path,
                    notice: 'Admin was successfully elevated to super admin.'
      else
        render :edit
      end
    end

    private

    def email_params
      params.require(:update_admin).permit(:email)
    end
  end
end
