class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :except => [:new, :create]  

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    user_class = string_to_user_class(params[:user][:user_kind])
    @user = user_class.new(params[:user])
    # Eto e'importante pa'que al @user se lo trate como lo que e' en su esencia,
    # ya sea ContabilidadUser, RecursosHumanosUser, o lo que fuere que sea.
    # En cambio, sino, el home_url_for_user lo toma como User y redirecciona a donde se le canta.
    if @user.save!
      flash[:notice] = "Account registered!"
      redirect_to root_url
    else
      render :action => :new
    end
  end

  def show
    @user = @current_user
  end

  def edit
    @user = @current_user
  end

  def update
    @user = @current_user
    if @user.update_attributes(params[:user])
      #flash[:notice] = "Account updated!"
      redirect_to root_url
    else
      render :action => :edit
    end
  end

  private
    def string_to_user_class(string)
      user_class = string_to_class(string)
      user_class if user_class and user_class.base_class == User
    end
end
