class Admin::UsersController < ApplicationController
  def index
    @users = User.limit(5)
  end
end
