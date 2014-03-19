Gatekeeper::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'pages#index'

  resources :lots, :only => [:create, :show, :new], :constraints => {:id => /[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}/} do
    collection do
      get :search
    end
    resources :qcables, :only => [:create]
  end

  # We can't use the standard CRUD setup, as the user doesn't have the uuid
  # to hand. Instead we pass a barcode to the controller.
  resource :asset, :only => [:destroy] do
  end

  resources :stamps, :only => [:new,:create] do
    collection do
      post :validation
    end
  end

  resources :robots, :only=>[] do
    collection do
      get :search
    end
  end

  resources :qc_assets, :only => [:new,:create] do
    collection do
      get :search
    end
  end

  resources :plates, :only=> [:show]
  resources :tubes,  :only=> [:show]
  resources :submissions,  :only=> [:create]
  resources :barcode_labels,  :only=> [:create]

end
