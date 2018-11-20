class Admin
  class DashboardController < ApplicationController
    layout 'admin'

    def index
      redirect_to new_admin_session_url unless admin_signed_in?
      @orgs = policy_scope(Organization) if current_admin
      @csv_access = csv_policy.authorized_to_download_csv_files?
    end

    private

    def csv_policy
      Admin::CsvPolicy.new(admin: current_admin)
    end
  end
end
