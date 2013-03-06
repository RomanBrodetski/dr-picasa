DrPicasa::Application.routes.draw do
  get 'login' => "auth#login"
  get 'callback' => "auth#callback"

  root :to => "albums#index", :as => 'albums'
  get ':id' => "albums#show", :as => 'album'
  get ':photo_id/comments' => "albums#comments"
  post ':photo_id/comments' => "albums#comment"
end
