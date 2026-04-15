class Admin::SessionsController < ApplicationController
  layout false

  def new
  end

  def create
    user = User.find_by(phone_number: params[:phone_number], role: 0) # admin role

    if user
      redirect_to admin_dashboard_path, notice: "Login successful"
    else
      flash[:alert] = "Invalid credentials"
      render :new
    end
  end
end
