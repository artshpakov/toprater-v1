AlternativesPower::Application.routes.draw do

  root 'index#index'

  resources :alternatives, only: :show do
    collection { get :rate }
  end

  resources :criteria, only: %i(index show)

end
