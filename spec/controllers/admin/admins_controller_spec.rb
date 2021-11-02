require 'rails_helper'

describe Admin::AdminsController do
  describe 'GET edit' do
    it 'denies access if not a super admin' do
      log_in_as_admin(:admin)

      get :edit

      expect(response).to redirect_to admin_dashboard_url
      expect(flash[:error]).to eq(I18n.t('admin.not_authorized'))
    end

    it 'denies access if not signed in' do
      get :edit

      expect(response).to redirect_to new_admin_session_path
      expect(flash[:alert]).to eq(I18n.t('devise.failure.unauthenticated'))
    end

    it 'allows access if signed in as a super admin' do
      log_in_as_admin(:super_admin)

      get :edit

      expect(response.status).to eq 200
    end
  end

  describe 'POST update' do
    it 'denies access if not a super admin' do
      log_in_as_admin(:admin)

      post :update

      expect(response).to redirect_to admin_dashboard_url
      expect(flash[:error]).to eq(I18n.t('admin.not_authorized'))
    end

    it 'denies access if not signed in' do
      post :update

      expect(response).to redirect_to new_admin_session_path
      expect(flash[:alert]).to eq(I18n.t('devise.failure.unauthenticated'))
    end

    it 'allows access if signed in as a super admin' do
      log_in_as_admin(:super_admin)

      post :update, params: {
        update_admin: { email: 'foo@bar.com' }
      }

      expect(response.status).to eq 200
    end
  end
end
