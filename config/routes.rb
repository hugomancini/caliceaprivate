Rails.application.routes.draw do
  root to: 'pages#index'
  post 'checkout_pro', to: "pages#checkout_pro"
end

