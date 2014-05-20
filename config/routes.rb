AlternativesPower::Application.routes.draw do

  scope "/(:locale)", locale: /en|ru/ do
    root to: 'index#index'

    scope ":realm", realm: /#{ Realm.pluck(:name).join '|' }/ do
      root to: 'index#index', as: :realm
      resources :alternatives, only: %i(index show) do
        member { get :midlevel }
      end
    end

    resources :properties, only: :index
    resources :criteria, only: :index
  end

  resources :search, only: [:index]

  resources :invites, only: :create

  get 'stats' => 'stats#index'

end
