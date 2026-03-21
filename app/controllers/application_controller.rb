class ApplicationController < ActionController::API
  include Authenticatable
  include ActionController::MimeResponds
end
