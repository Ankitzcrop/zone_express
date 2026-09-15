class Admin::UsersController < ApplicationController
  def index
    @users = User.order(created_at: :desc)

    if params[:search].present?
      search = "%#{params[:search]}%"

      @users = @users.where(
        "name LIKE :search OR email LIKE :search OR phone_number LIKE :search",
        search: search
      )
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to admin_users_path, notice: "User created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_params)
      redirect_to admin_users_path, notice: "User updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy

    redirect_to admin_users_path, notice: "User deleted successfully."
  end

  private

  def user_params
    params.require(:user).permit(
      :name,
      :email,
      :phone_number,
      :country_code,
      :gender,
      :date_of_birth,
      :emergency_contact,
      :role,
      :password,
      :password_confirmation
    )
  end
end
