require 'rails_helper'

feature 'Make an admin a super admin' do
  background do
    login_super_admin
    visit('/admin/admins')
  end

  scenario 'when admin does not exist' do
    fill_in 'Email', with: 'foo@bar.com'
    click_button I18n.t('admin.buttons.save_changes')

    expect(current_path).to eq admin_admins_path
    error_message = 'This email is not yet registered. Please ask them to create an account.'
    expect(page).to have_content error_message
    expect(page).to_not have_content 'not confirmed yet'
  end

  scenario 'when admin exists but is not confirmed' do
    admin = create(:unconfirmed_admin)
    unconfirmed_email = admin.email
    fill_in 'Email', with: unconfirmed_email
    click_button I18n.t('admin.buttons.save_changes')

    expect(current_path).to eq admin_admins_path
    error_message = 'This email is registered but not yet confirmed. Please ' \
                    'ask them to click on the link in their confirmation email.'
    expect(page).to have_content error_message
    expect(page).to_not have_content 'not yet registered'
    expect(admin.reload.super_admin).to be_falsey
  end

  scenario 'when admin exists and is confirmed' do
    admin = create(:admin_with_generic_email)
    confirmed_email = admin.email
    fill_in 'Email', with: confirmed_email
    click_button I18n.t('admin.buttons.save_changes')

    expect(current_path).to eq admin_admins_path
    success_message = 'Admin was successfully elevated to super admin.'
    expect(page).to have_content success_message
    expect(admin.reload.super_admin).to be_truthy
  end
end
