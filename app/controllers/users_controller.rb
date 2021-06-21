class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  

  # GET /users
  # GET /users.json
  def index
    if params[:id] != nil
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    signin_apikey
    if params[:logout] != nil
      session.clear
      respond_to do |format|
        format.html { redirect_to '/tweets'}
      end
    else
     @user = User.find(params[:id])
      if request.headers["accept"] == "application/json" or request.path.include? ".json"
        render :json => @user.attributes.merge( )
      end
    end
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    signin_apikey
    @user = User.new(user_params)
   
    respond_to do |format|
      if @user.save
        format.html { redirect_to tweets_url, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def login
    @user = User.new(user_params)
    users = User.all
    for u in users
      if @user.username == u.username
        if @user.password == u.password
          respond_to do |format|
            format.html { redirect_to tweets_url, notice: 'User was successfully logged in.' }
            format.json { render :show, status: :logged_in, location: @user }
          end
        else
          respond_to do |format|
            format.html { redirect_to new_user_path, notice: 'Incorrect password' }
            format.json { render json: @user.errors, status: :unprocessable_entity }
          end
        end
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    signin_apikey
    if session[:user_id]!= nil
      @user = User.find(params[:id])
      if (session[:user_id].to_s == params[:id].to_s)
        @user.update(user_params)
        respond_to do |format|
          format.html { redirect_to edit_user_path(@user) }
          format.json { render json: @user.to_json, status: 200 }
        end
      else
        respond_to do |format|
          format.json { render json: "Forbidden, you can\'t edit this user as the api_key does not match".to_json, status: 403 }
        end
      end
    else
      respond_to do |format|
          format.json { render json: "Unauthorized, you don\'t have a valid api_key".to_json, status: 401 }
        end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    signin_apikey
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      # @user = User.find(params[:id])
    end
    
    def signin_apikey
      if request.headers["X-API-KEY"] != nil
        puts "Header:"
        puts request.headers["X-API-KEY"]
        @user = User.where(api_key: request.headers["X-API-KEY"]).take
        if @user != nil
         session[:user_id] = @user.id
        end
      end
    end
    
    # Only allow a list of trusted parameters through.
    def user_params
      params.permit(:about, :email, :id, :username, :password)
    end
end
