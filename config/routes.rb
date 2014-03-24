AlternativesPower::Application.routes.draw do

  root 'index#index'

  resources :alternatives, only: [:index, :show] do
    collection do
      get :count
    end
  end

  resources :properties, only: [:index]

  resources :criteria, only: [:index, :show]

end
