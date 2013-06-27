Ifttt::Application.routes.draw do
  resources :teams
  resources :users

  root :to => 'users#index'
end
