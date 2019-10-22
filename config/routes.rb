Rails.application.routes.draw do
  root to: 'pages#index'
  post 'helloWorld', to: "pages#helloWorld"
  get 'helloWorld', to: "pages#helloWorld"
end

