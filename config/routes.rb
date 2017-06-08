Rails.application.routes.draw do
  get 'main/index'
  post 'main/table'
  post 'main/delete'

  root 'main#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end