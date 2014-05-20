class InvitesController < ApplicationController

  skip_before_action :verify_authenticity_token
  skip_before_action :set_locale

  def create
    Invite.find_or_create_by(email: params[:email])
    redirect_to :back
  end

end
