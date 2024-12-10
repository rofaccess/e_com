require "api/api_constraints"
require "sidekiq/web"
require "sidekiq/cron/web"

App::Application.routes.draw do
  resources :reports, only: :index

  namespace :api, defaults: {format: 'json'} do
    scope module: :v1, constraints: ApiConstraints.new(version: 1) do
      resources :reports, only: :index
    end
    scope module: :v2, constraints: ApiConstraints.new(version: 2, default: true) do
      resources :reports, only: :index do
        collection do
          get :most_purchased_products_by_each_category
          get :best_selling_products_by_each_category
          get :sale_orders
          get :sale_orders_quantity
        end
      end

      get '/users/authorization_token', to: 'users#authorization_token'
    end
  end

  resources :sale_orders, only: [:create, :index]

  devise_for :users

  resources :home, only: :index

  resources :products

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'home#index'

  # Cuando un usuario no está logueado, sidekiq trata de acceder a una ruta por defecto que no existe
  # Cuando se hace petición a esa ruta, se redirecciona a la ruta válida para inicio de sesión
  get '/sidekiq/users/sign_in', to: redirect('/users/sign_in')

  authenticate :user, ->(user) { user.is_admin? } do
    mount Sidekiq::Web, at: "/sidekiq", as: :sidekiq
    # El as: :sidekiq es para usar la ruta sidekiq_path en el navbar
  end

  # Redirigir a los usuarios no administradores que intenten acceder a Sidekiq. by ChatGPT
  get '/sidekiq', to: redirect('/'), constraints: ->(req) { req.env['warden'].user.present? && !req.env['warden'].user.is_admin? }

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
