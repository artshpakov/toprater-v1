AlternativesPower::Application.routes.draw do

  scope "/(:locale)", locale: /en|ru/ do
    root to: 'index#index'

    scope ":realm", realm: /#{ Realm.pluck(:name).join '|' }/ do
      root to: 'index#index', as: :realm
      resources :alternatives, only: %i(index show)
    end

    resources :properties, only: :index
    resources :criteria, only: :index
  end

  resources :search, only: [:index]

end
