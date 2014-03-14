AlternativesPower::Application.routes.draw do

  root 'index#index'

  resources 'criteria', only: %i(index show)

end
