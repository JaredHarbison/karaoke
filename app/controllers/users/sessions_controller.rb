class Users::SessionsController < Devise::SessionsController
  before_action :reject_honeypot, only: :create

  private

  def reject_honeypot
    head :unprocessable_entity if params[:website].present?
  end
end
