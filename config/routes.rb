AlternativesPower::Application.routes.draw do

  get "properties/index"
  root 'index#index'

  resources :alternatives, only: [:index, :show]

  resources :properties, only: [:index]

  resources :criteria, only: [:index, :show]

end
