class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def log_out
    reset_session
    flash[:alert] = "You have been logged out!"
    redirect_to '/'
  end

  def login
    render 'users/login'
  end

  def login_user
    # to do: check the password and email with bcrypt to allow user to proceed
    # if isValid, User.new(user_params)
    @user = User.find_by email: params[:email].downcase
    if @user.present?
      puts "@user authentication: "+@user.authenticate(params[:password]).to_s
      if @user && @user.authenticate(params[:password])
        # valid login
        log_in @user
        # session[:id] = @user.id
        if @user.isAdmin
          session[:ia] = true
          redirect_to @user
        else
          puts "Is not an admin!!!"
          # what group?
          group_id = Person.select('group_id').find_by name: @user.name
          puts "*******group_id is "+group_id.to_s
          session[:group_id] = group_id
          redirect_to '/people'
        end
      else
        # show error
        flash[:alert] = "Could not log you in!"
        puts @user.errors.full_messages
        render 'users/login'
      end
    else
      # user not found at all
      flash[:alert] = "Could not log you in!"
      render 'users/login'
    end
  end

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
    log_in @user
    # to do: create a unique hash to force login user to only access their content
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    puts "We are now in create..................."
    puts "@user is  "+@user.to_s

    respond_to do |format|
      if @user.save
        log_in @user
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :isAdmin)
    end

    def login_params
      params.require(:user).permit(:email, :password)
    end

    def log_in(user)
      puts "logging in user..."
      session[:user_id] = user.id
      puts "user_id: "+user.id.to_s
      session[:user_name] = user.name
      puts "user_name: "+user.name.to_s
      person = Person.find_by name: user.name
      if person.present?
        session[:group_id] = person.group_id
        session[:person_id] = person.id
        puts "person.group_id: "+person.group_id.to_s
      end
      puts "if session[:user_id]: "+session[:user_id].to_s
      if session[:user_id]
        @current_user ||= User.find_by(id: session[:user_id])
        puts "#######Current User is "+@current_user.to_s
      end
    end
  
    # Returns the current logged-in user (if any).
    def current_user
      if session[:user_id]
        @current_user ||= User.find_by(id: session[:user_id])
      end
    end

    def logged_in?
      !current_user.nil?
    end
end
