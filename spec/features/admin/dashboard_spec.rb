require 'rails_helper'

feature 'Admin Home page' do
  context 'when not signed in' do
    before :each do
      visit '/admin'
    end

    it 'sets the current path to the admin sign in page' do
      expect(current_path).to eq(new_admin_session_path)
    end

    it 'includes a link to the sign up page' do
      within '#main' do
        expect(page).to have_link I18n.t('navigation.sign_up'), href: new_admin_registration_path
      end
    end

    it 'does not include a link to the Home page in the navigation' do
      within '.navbar' do
        expect(page).not_to have_link 'Home', href: root_path
      end
    end

    it 'does not include a link to Your locations in the navigation' do
      within '.navbar' do
        expect(page).
          not_to have_link I18n.t('admin.navigation.locations'), href: admin_locations_path
      end
    end

    it 'uses the admin layout' do
      within '.navbar' do
        expect(page).
          to have_content I18n.t('titles.admin', brand: I18n.t('titles.brand'))
      end
    end
  end

  context 'when signed in' do
    before :each do
      login_admin
      visit '/admin'
    end

    it 'greets the admin by their name' do
      expect(page).to have_content 'Welcome back, Org Admin!'
    end

    it 'includes a link to organizations in the body' do
      within '.content' do
        expect(page).
          to have_link I18n.t('admin.buttons.organizations'), href: admin_organizations_path
      end
    end

    it 'includes a link to locations in the body' do
      within '.content' do
        expect(page).
          to have_link I18n.t('admin.buttons.locations'), href: admin_locations_path
      end
    end

    it 'does not include a link to services in the body' do
      within '.content' do
        expect(page).to_not have_link 'Services'
      end
    end

    it 'includes a link to programs in the body' do
      within '.content' do
        expect(page).
          to have_link I18n.t('admin.buttons.programs'), href: admin_programs_path
      end
    end

    it 'does not include a link to the sign up page in the navigation' do
      within '.navbar' do
        expect(page).not_to have_link I18n.t('navigation.sign_up')
      end
    end

    it 'does not include a link to the sign in page in the navigation' do
      within '.navbar' do
        expect(page).not_to have_link I18n.t('navigation.sign_in')
      end
    end

    it 'includes a link to sign out in the navigation' do
      within '.navbar' do
        expect(page).
          to have_link I18n.t('navigation.sign_out'), href: destroy_admin_session_path
      end
    end

    it 'includes a link to the Edit Account page in the navigation' do
      within '.navbar' do
        expect(page).
          to have_link I18n.t('navigation.edit_account'), href: edit_admin_registration_path
      end
    end

    it 'displays the name of the logged in admin in the navigation' do
      within '.navbar' do
        expect(page).to have_content "Hi, #{@admin.name}"
      end
    end

    it 'includes a link to locations in the navigation' do
      within '.navbar' do
        expect(page).to have_link I18n.t('admin.buttons.locations'), href: admin_locations_path
      end
    end

    it 'includes a link to organizations in the navigation' do
      within '.navbar' do
        expect(page).
          to have_link I18n.t('admin.buttons.organizations'), href: admin_organizations_path
      end
    end

    it 'does not include a link to services in the navigation' do
      within '.navbar' do
        expect(page).to_not have_link 'Services'
      end
    end

    it 'does not display a link to add a new organization' do
      expect(page).
        not_to have_link I18n.t('admin.buttons.add_organization'), href: new_admin_organization_path
    end

    it 'does not display a link to add a new location' do
      expect(page).
        to_not have_link I18n.t('admin.buttons.add_location'), href: new_admin_location_path
    end

    it 'does not display a link to add a new program' do
      expect(page).
        to_not have_link I18n.t('admin.buttons.add_program'), href: new_admin_program_path
    end

    it 'does not display a link to update admin to super admin' do
      expect(page).
        to_not have_link I18n.t('admin.buttons.update_admin'), href: admin_admins_path
    end

    it 'does not display a link to download CSV' do
      expect(page).to_not have_content 'CSV Downloads'
      expect(page).
        to_not have_link(
          t('admin.buttons.download_locations'),
          href: admin_csv_locations_url
        )
    end
  end

  context 'when signed in as super admin and no orgs exist' do
    before :each do
      login_super_admin
      visit '/admin'
    end

    it 'displays a link to add a new organization' do
      expect(page).
        to have_link I18n.t('admin.buttons.add_organization'), href: new_admin_organization_path
    end

    it 'does not display a link to add a new location' do
      expect(page).
        to_not have_link I18n.t('admin.buttons.add_location'), href: new_admin_location_path
    end

    it 'does not display a link to add a new program' do
      expect(page).
        to_not have_link I18n.t('admin.buttons.add_program'), href: new_admin_program_path
    end
  end

  context 'when signed in as super admin and orgs exist' do
    before :each do
      create(:organization)
      login_super_admin
      visit '/admin'
    end

    it 'displays a link to add a new location' do
      expect(page).to have_link I18n.t('admin.buttons.add_location'), href: new_admin_location_path
    end

    it 'displays a link to add a new program' do
      expect(page).to have_link I18n.t('admin.buttons.add_program'), href: new_admin_program_path
    end

    it 'displays link to download all tables as CSV files' do
      expect(page).to have_content 'CSV Downloads'

      tables = %w[addresses contacts holiday_schedules locations mail_addresses
                  organizations phones programs regular_schedules services]
      tables.each do |table|
        expect(page).
          to have_link t("admin.buttons.download_#{table}"), href: send(:"admin_csv_#{table}_url")
      end
    end

    it 'displays a link to update admin to super admin' do
      expect(page).
        to have_link I18n.t('admin.buttons.update_admin'), href: admin_admins_path
    end
  end

  context 'when signed in as special guest and orgs exist' do
    before :each do
      create(:organization)
      admin = create(:location_admin)
      login_as_admin(admin)
      visit '/admin'
    end

    it 'displays link to download all tables as CSV files' do
      expect(page).to have_content 'CSV Downloads'

      tables = %w[addresses contacts holiday_schedules locations mail_addresses
                  organizations phones programs regular_schedules services]
      tables.each do |table|
        expect(page).
          to have_link t("admin.buttons.download_#{table}"), href: send(:"admin_csv_#{table}_url")
      end
    end
  end

  describe 'Ohana API version' do
    let(:version) { File.read('VERSION').chomp }
    let(:prefix) { 'https://github.com/codeforamerica/ohana-api/blob/master/' }

    context 'super admin' do
      it 'displays Ohana API version number' do
        login_super_admin
        visit '/admin'

        expect(page).to have_link "v#{version}", href: "#{prefix}CHANGELOG.md"
      end
    end

    context 'regular admin' do
      it 'does not display Ohana API version number' do
        login_admin
        visit '/admin'

        expect(page).to_not have_link "v#{version}", href: "#{prefix}CHANGELOG.md"
      end
    end
  end
end
