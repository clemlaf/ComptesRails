Rails.application.routes.draw do
  get 'main/index'
  get 'main', to: 'main#index'
  post 'main/table'
  post 'main/delete'
  post 'update', to: 'main#table'
  get 'param/index'
  get 'param', to: 'param#index'
  post 'param/update'
  post 'param/delete'

  root 'main#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
