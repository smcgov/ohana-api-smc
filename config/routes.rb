require 'api_constraints'
require 'subdomain_constraints'

Rails.application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.
  # See how all your routes lay out with 'rake routes'.
  # Read more about routing: http://guides.rubyonrails.org/routing.html

  devise_for :users, controllers: { registrations: 'user/registrations' }
  devise_for(
    :admins, path: ENV['ADMIN_PATH'] || '/', controllers: { registrations: 'admin/registrations' }
  )

  constraints(SubdomainConstraints.new(subdomain: ENV.fetch('ADMIN_SUBDOMAIN', nil))) do
    namespace :admin, path: ENV.fetch('ADMIN_PATH', nil) do
      root to: 'dashboard#index', as: :dashboard

      resources :locations, except: :show do
        resources :services, except: %i[show index] do
          resources :contacts, except: %i[show index], controller: 'service_contacts'
        end
        resources :contacts, except: %i[show index]
      end

      resources :organizations, except: :show do
        resources :contacts, except: %i[show index], controller: 'organization_contacts'
      end
      resources :programs, except: :show
      # Because the data was imported long before new Open Referral rules
      # were defined, some data is currently invalid. For example, most services
      # don't have names or descriptions. Until the data is updated, the
      # link to Services in the admin dashboard and navigation bar should be
      # removed.
      # resources :services, only: :index

      namespace :csv, defaults: { format: 'csv' } do
        get 'addresses'
        get 'contacts'
        get 'holiday_schedules'
        get 'locations'
        get 'mail_addresses'
        get 'organizations'
        get 'phones'
        get 'programs'
        get 'regular_schedules'
        get 'services'
      end

      get 'admins', to: 'admins#edit'
      post 'admins', to: 'admins#update'
      get 'locations/:location_id/services/:id', to: 'services#edit'
      get 'locations/:location_id/services/:service_id/contacts/:id', to: 'service_contacts#edit'
      get 'locations/:location_id/contacts/:id', to: 'contacts#edit'
      get 'locations/:id', to: 'locations#edit'
      get 'organizations/:id', to: 'organizations#edit'
      get 'organizations/:organization_id/contacts/:id', to: 'organization_contacts#edit'
      get 'programs/:id', to: 'programs#edit'
    end
  end

  resources :api_applications, except: :show
  get 'api_applications/:id' => 'api_applications#edit'

  constraints(SubdomainConstraints.new(subdomain: ENV.fetch('API_SUBDOMAIN', nil))) do
    namespace :api, path: ENV.fetch('API_PATH', nil), defaults: { format: 'json' } do
      scope module: :v1, constraints: ApiConstraints.new(version: 1) do
        get '/' => 'root#index'
        get '.well-known/status' => 'status#check_status'

        resources :organizations do
          resources :locations, only: :create
        end
        get 'organizations/:organization_id/locations',
            to: 'organizations#locations', as: :org_locations

        resources :locations do
          resources :address, except: %i[index show]
          resources :mail_address, except: %i[index show]
          resources :contacts, except: [:show] do
            resources :phones,
                      except: %i[show index],
                      path: '/phones', controller: 'contact_phones'
          end
          resources :phones, except: [:show], path: '/phones', controller: 'location_phones'
          resources :services
        end

        resources :search, only: :index

        resources :categories, only: :index

        put 'services/:service_id/categories',
            to: 'services#update_categories', as: :service_categories
        get 'categories/:taxonomy_id/children', to: 'categories#children', as: :category_children
        get 'locations/:location_id/nearby', to: 'search#nearby', as: :location_nearby

        match '*unmatched_route' => 'errors#raise_not_found!',
              via: %i[get delete patch post put]

        # CORS support
        match '*unmatched_route' => 'cors#render_204', via: [:options]
      end
    end
  end

  root to: 'home#index'
end
