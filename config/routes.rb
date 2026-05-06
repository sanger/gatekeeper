# frozen_string_literal: true

Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'pages#index'

  get 'health' => 'health#show', as: :health

  resources :lots, only: %i[create show new], constraints: { id: /[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}/ } do
    collection do
      get :search
    end
    resources :qcables, only: [:create] do
      post 'upload', on: :collection
    end
  end

  # post 'lots/upload', to: 'lots#upload'

  resources :batches, only: [:show] do
    collection do
      get :search
    end
  end

  resources :robots, only: [] do
    collection do
      get :search
    end
  end

  resources :users, only: [] do
    collection do
      get :search
    end
  end

  resources :plates, only: [:show]
  resources :tubes,  only: [:show]
  resources :submissions,  only: [:create]
  resources :barcode_labels, only: [:create]
end
