class SessionsController < Devise::SessionsController

  def new
    super
  end

  def create
    super
  end

  # DELETE /resource/sign_out
  def destroy
    #l = Logger.new(STDOUT)
    #l.info("Logout id:#{current_user.id} email:#{current_user.email}")
    super
  end


end
