Rails.application.routes.draw do
  resources :comments
  default_url_options :host => ENV['DEFAULT_URL_OPTIONS']
  root to: 'application#index'
  resources :posts
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
