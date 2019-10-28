Rails.application.routes.draw do
  root to: 'pages#index'
  post 'helloWorld', to: "pages#hello_world"
  get 'helloWorld', to: "pages#hello_world"
end

