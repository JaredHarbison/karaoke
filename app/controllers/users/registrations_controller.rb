class Users::RegistrationsController < Devise::RegistrationsController
  before_action :reject_honeypot, only: :create
  before_action :configure_permitted_parameters

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[first_name last_name])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[first_name last_name])
  end

  def reject_honeypot
    head :unprocessable_entity if params[:website].present?
  end
end
