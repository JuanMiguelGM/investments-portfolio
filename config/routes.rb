# frozen_string_literal: true

Rails.application.routes.draw do
  root "dashboard#index"

  resources :funds, only: %i[index show]
  resources :policies, only: %i[show], param: :slug
  resources :holdings, only: %i[edit update]
  resources :contributions, only: %i[new create]

  namespace :admin do
    resource :import, only: :create
    resource :prices, only: :create
    resources :nav_entries, only: %i[new create]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
