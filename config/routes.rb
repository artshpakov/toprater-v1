AlternativesPower::Application.routes.draw do

  scope "/(:locale)", locale: /en|ru/ do
    get "" => 'index#index'
    resources :alternatives, only: [:index, :show] do
      collection do
        get :count
      end
    end
    resources :properties, only: [:index]
    resources :criteria, only: [:index, :show]
  end

  root 'index#index'

end
