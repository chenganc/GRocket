class UsersController < ApplicationController

  attr_accessor :remember_token, :activation_token, :reset_token

  before_action :set_user, only: [:show, :edit, :update, :destroy]

  before_action :logged_in_user, only: [:show, :index, :edit, :update]

  before_action :correct_user,   only: [:show, :edit, :update]

  before_action :admin_user,     only: [:destroy]

  #before_create :create_activation_digest

  # GET /users
  # GET /users.json
  def index
    @users = User.paginate(page: params[:page])
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])
    @posts = @user.posts.paginate(page: params[:page])
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    render 'new'
    @user = User.find(params[:id])

  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_path
    else
      render 'new'
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    #respond_to do |format|
     @user = User.find(params[:id])
      if @user.update_attributes(user_params)
        # Handle a successful update.
        flash[:info] = "User was successfully updated."
        redirect_to edit_user_path
        #format.html { redirect_to @user, notice: 'User was successfully updated.' }
        #format.json { render :show, status: :ok, location: @user }
      else
        flash[:error] = "Update was unsuccessful."
        render 'edit'
        #format.html { render :edit }
        #format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    #end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    User.find(params[:id]).destroy
    flash[:info] = "User deleted"
    redirect_to users_path
  end

  def feed
    Posts.where("user_id = ?", id)
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:email, :firstName, :lastName, :password, :password_confirmation)
    end

    def logged_in_user
      unless logged_in?
        store_location
        #format.html { redirect_to login_url, notice: 'Please log in.' }
        flash[:error] = "Please log in."
        redirect_to login_path
      end
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless (@user == (current_user) || current_user.admin?)
    end

    #def create_activation_digest
      # Create the token and digest.
    #  self.activation_token  = User.new_token
    #  self.activation_digest = User.digest(activation_token)
    #end

    # Confirms an admin user.
    def admin_user
      redirect_to(root_path) unless current_user && current_user.admin?
    end

end
