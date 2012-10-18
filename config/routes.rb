GpsSlider::Application.routes.draw do
  resources :routes do
    resources :points
  end
  resources :procession_floats

  root :to => "routes#index"
  
end
