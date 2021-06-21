class TweetsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_tweet, only: [:show, :edit, :update, :destroy]

  # GET /tweets
  # GET /tweets.json
  def index
    signin_apikey
    if params[:orderby] != nil
      if params[:orderby] == "newest"
        @tweets = Tweet.all.order("created_at DESC")
      elsif params[:orderby] == "past"
        @tweets = Tweet.all.order("created_at ASC")
      elsif params[:orderby] == "ask"
        @tweets = Tweet.where({ ask: true })
      elsif params[:orderby] == "url"
        @tweets = Tweet.where({ ask: false })
      else 
        @tweets = Tweet.all
      end
    else
      if params[:user_id] != nil
        if params[:voted] == "true"
          puts params[:user_id]
          puts session[:user_id]
          if params[:user_id] == session[:user_id].to_s
            puts "entro a dins if user_id=session_id"
            @tweets = []
            @liked = Vote.where(idUser: params[:user_id], tipus: "contribution")
            @liked.each do |vote|
              @tweet =Tweet.where(id: vote.idType)
              if @tweet != nil
                @tweets.push(@tweet)
              end
            end
          else
            puts "entro else"
            msg = "You can't look at the contributions voted by another user"
            respond_to do |format|
              format.html { redirect_to '/tweets' }
              format.json { render json: msg.to_json , status: 403, location: @tweet }
              end
            return
          end
        else
          @author = User.find(params[:user_id])
          @tweets = Tweet.where(author: @author.username)
        end
      else
        @tweets = Tweet.all
      end
    end
    render :json => @tweets.to_json
  end

  # GET /tweets/1
  # GET /tweets/1.json
  def show
    signin_apikey
    
    if params[:vote] != nil
      if session[:user_id] != nil
        @userID = User.find(session[:user_id]).id
        if @tweet.user_id == @userID
          msg = "You can't vote your contribution"
          if params[:show] == nil
            respond_to do |format|
              format.html { redirect_to '/tweets' }
              format.json { render json: msg.to_json , status: 403, location: @tweet }
            end
          end
        else
          if params[:vote] == "true"
            @vote = Vote.find_by(tipus: "contribution", idType: params[:id], idUser: @userID)
            if @vote != nil
                if params[:show] == nil
                msg = "You have alredy voted this contribution"
                respond_to do |format|
                  format.html { redirect_to '/tweets' }
                  format.json { render json: msg.to_json , status: 400, location: @tweet }
                  end
              end
            else
              @vote = Vote.new
              @vote.tipus = "contribution"
              @vote.idType = params[:id]
              @vote.idUser = @userID
              @vote.save
              @tweet.points += 1
              @tweet.save
              @user = User.find(@tweet.user_id)
              @user.karma += 3
              @user.save
              if params[:show] == nil
              msg = "The contribution has been voted"
              respond_to do |format|
                format.html { redirect_to '/tweets' }
                format.json { render json: @tweet.to_json , status: 200, location: @tweet }
                end
              end
            end
          elsif params[:vote] == "false"
            @vote = Vote.find_by(tipus: "contribution", idType: params[:id], idUser: @userID)
            if @vote.nil?
              if params[:show] == nil
              msg = "You have alredy unvoted this contribution"
              respond_to do |format|
              format.html { redirect_to '/tweets' }
              format.json { render json: msg.to_json , status: 400, location: @tweet }
              end
            end
            else
              @vote.destroy
              @tweet.points -= 1
              @tweet.save
              @user = User.find(@tweet.user_id)
              @user.karma -= 3
              @user.save
              if params[:show] == nil
              msg = "The contribution has been unvoted"
              respond_to do |format|
                format.html { redirect_to '/tweets' }
                format.json { render json: @tweet.to_json , status: 200, location: @tweet }
                end
              end
            end
          end
        end
      else
        msg = "You don't have a valid api_key"
        respond_to do |format|
          format.json { render json: {message: msg }, status: 401 }
        end
      end
    else
      render :json => @tweet.attributes.merge( )
    end
  end

  # GET /tweets/new
  def new
    @tweet = Tweet.new
  end

  # GET /tweets/1/edit
  def edit
  end

  # POST /tweets
  # POST /tweets.json
  def create
    signin_apikey
    
    if session[:user_id] != nil
      @tweet = Tweet.new(tweet_params)
      @tweet.author = User.find(session[:user_id]).email.split('@')[0].strip
      @tweet.user_id = User.find(session[:user_id]).id
      if !@tweet.url.blank?
        if !is_url(@tweet.url)
          respond_to do |format|
            format.json { render json: "Invalid url!".to_json, status: 400 }
          end
          return
        end
        @tweet.url = @tweet.url.sub "https://", ""
        @tweet.url = @tweet.url.sub "www.", ""
        @urlsplit = @tweet.url.split("/")
          @urlsplit.each do |suburl|
            if suburl.include?(".")
              @tweet.shorturl = suburl
            end
          end
      end
      @tweet2 = Tweet.find_by url: @tweet.url
      if (@tweet.content.blank? && !@tweet.url.blank?)
        respond_to do |format|
          if @tweet.title.blank?
            format.html { redirect_to new_tweet_path, alert: 'Please try again.' }
            format.json { render json: "Title property cannot be blank".to_json, status: 400 }
          elsif (@tweet2 != nil)
            format.html { redirect_to '/tweets/' + @tweet2.id.to_s }
            msg = "The URL already exists"
            format.json { render json: msg.to_json , status: 400, location: @tweet }
          elsif @tweet.save
              format.html { redirect_to '/tweets', notice: 'Tweet was successfully created.' }
              format.json { render json: @tweet, status: 201 }
          else
            format.html { render :new }
            format.json { render json: @tweet.errors, status: :unprocessable_entity }
          end
        end
      elsif (@tweet.url.blank? && !@tweet.content.blank?)
        @tweet.ask = true
        respond_to do |format|
          if @tweet.title.blank?
            format.html { redirect_to new_tweet_path, alert: 'Please try again.' }
            format.json { render json: "Title property cannot be blank".to_json, status: 400 }
          elsif @tweet.save
              format.html { redirect_to '/tweets', notice: 'Tweet was successfully created.' }
              format.json { render json: @tweet, status: 201 }
          else
            format.html { render :new }
            format.json { render json: @tweet.errors, status: :unprocessable_entity }
          end
        end
      else
        @comment_text=@tweet.content
        @tweet.content=nil
        @tweet.ask = false
        
        if @tweet.save
          Comment.create(contribution: @tweet.id, text: @comment_text, escomment: true, comment_id: nil, user: @tweet.user_id)
          render :json => @tweet.attributes.merge( )
        end
      end
    else
      respond_to do |format|
        format.json { render json: {message: 'Unauthorized, you don\'t have a valid api_key' }, status: 401 }
       end
    end
  end

  # PATCH/PUT /tweets/1
  # PATCH/PUT /tweets/1.json
  def update
    signin_apikey
    if session[:user_id] != nil
      if @tweet.user_id.to_s == session[:user_id].to_s
        respond_to do |format|
          if @tweet.update(tweet_update_params)
            format.html { redirect_to @tweet, notice: 'Tweet was successfully edited.' }
            format.json { render json: @tweet, status: 200 }
          else
            format.html { render :edit }
            format.json { render json: @tweet.errors, status: :unprocessable_entity }
          end
        end
      else
        respond_to do |format|
        format.json { render json: {message: 'Forbidden, you can\'t edit a tweet that is not yours' }, status: 403 }
       end
     end
    else
      respond_to do |format|
        format.json { render json: {message: 'Unauthorized, you don\'t have a valid api_key' }, status: 401 }
       end
    end
  end

  # DELETE /tweets/1
  # DELETE /tweets/1.json
  def destroy
    signin_apikey
    if session[:user_id] != nil
      if @tweet.user_id.to_s == session[:user_id].to_s
        @tweet.destroy
        respond_to do |format|
          format.html { redirect_to tweets_url, notice: 'Tweet was successfully destroyed.' }
          format.json { render json: {message: 'Contribution destroyed!' } }
        end
      else
        respond_to do |format|
        format.json { render json: {message: 'Forbidden, you can\'t delete a tweet that is not yours' }, status: 403 }
       end
      end
    else
      respond_to do |format|
        format.json { render json: {message: 'Unauthorized, you don\'t have a valid api_key' }, status: 401 }
       end
    end
  end

  private
  
    def signin_apikey
      if request.headers["X-API-KEY"] != nil
        puts "Header:"
        puts request.headers["X-API-KEY"]
        @user = User.where(api_key: request.headers["X-API-KEY"]).take
        session[:user_id] = @user.id
      end
    end
    
    def is_url(url)
      @a = false
      if (url.include?("www") || url.include?("http"))
        @a=true
      end
      return @a
    end
      
    # Use callbacks to share common setup or constraints between actions.
    def set_tweet
      @tweet = Tweet.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def tweet_params
      params.require(:tweet).permit(:author, :content,:title,:url, :created_at, :user_id)
    end
    
    def tweet_update_params
      params.permit(:content, :created_at, :updated_at)
    end
end
