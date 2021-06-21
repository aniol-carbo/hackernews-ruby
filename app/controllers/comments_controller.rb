class CommentsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_comment, only: [:show, :edit, :update, :destroy]

  # GET /comments
  # GET /comments.json
  def index
    signin_apikey
    if request.headers["Accept"] == "application/json" or request.path.include? ".json"
      if params[:user_id]!=nil
        if params[:voted] == "true"
          if params[:user_id] == session[:user_id].to_s
            @comments = []
            @liked = Vote.where(idUser: params[:user_id], tipus: "comment")
            @liked += Vote.where(idUser: params[:user_id], tipus: "reply")
            @liked.each do |vote|
              @comment =Comment.where(id: vote.idType)
              if @comment != nil
                @comments.push(@comment)
              end
            end
            render json: @comments
          else
            msg = "You can't look at the comments voted by another user"
            respond_to do |format|
              format.html { redirect_to '/comments' }
              format.json { render json: msg.to_json , status: 403, location: @tweet }
            end
            return
          end
        else
          @comments = Comment.where(user: params[:user_id])
          render json: @comments

        end
      else
        @comments = Comment.all
        render json: @comments

      end
    else
      @comments = Comment.all
        
    end
  end

  # GET /comments/1
  # GET /comments/1.json
  def show
    signin_apikey
    
    if params[:vote] != nil
      if session[:user_id] != nil
        @userID = User.find(session[:user_id]).id
        if @comment.user == @userID
          msg = "You can't vote your comment"
          if params[:show] == nil
            respond_to do |format|
              format.html { redirect_to '/tweets' }
              format.json { render json: msg.to_json , status: 403, location: @comment }
            end
            return
          end
        else
          @reply = Comment.find(params[:id])
          if @reply.comment_id != nil
            @comment = Comment.find(@reply.comment_id)
          end
          if @reply.escomment == true #comment
            if params[:vote] == "true"
              @vote = Vote.new
              @vote.tipus = "comment"
              @vote.idType = params[:id]
              @vote.idUser = session[:user_id]
              @vote.save
              @reply.points += 1
              @reply.save
              @user = User.find(@reply.user)
              @user.karma += 2
              @user.save
            elsif params[:vote] != nil &&  params[:vote] == "false"
              @vote = Vote.find_by(tipus: "comment", idType: params[:id], idUser: session[:user_id])
              @vote.destroy
              @reply.points -= 1
              @reply.save
              @user = User.find(@reply.user)
              @user.karma -= 2
              @user.save
            end
          else #reply
            if params[:vote] == "true"
              @vote = Vote.new
              @vote.tipus = "reply"
              @vote.idType = params[:id]
              @vote.idUser = session[:user_id]
              @vote.save
              @reply.points += 1
              @reply.save
              @user = User.find(@reply.user)
              @user.karma += 1
              @user.save
            elsif params[:vote] != nil &&  params[:vote] == "false"
              @vote = Vote.find_by(tipus: "reply", idType: params[:id], idUser: session[:user_id])
              @vote.destroy
              @reply.points -= 1
              @reply.save
              @user = User.find(@reply.user)
              @user.karma -= 1
              @user.save
            end
          end
        end
      end
      @tweet = Tweet.find(@reply.contribution)
      msg = "OK"
       respond_to do |format|
         if params[:comments]
           format.html { redirect_to '/comments' }
           format.json { render json: msg.to_json , status: 200, location: @comments }
         else
          format.html { redirect_to '/tweets/'+@reply.contribution.to_s }
          format.json { render json: msg.to_json , status: 200, location: @tweet }
         end
       end
    end
  end

  # GET /comments/new
  def new
    @comment = Comment.new
  end

  # GET /comments/1/edit
  def edit
  end

  # POST /comments
  # POST /commments.json
  def create
    signin_apikey
    if session[:user_id] != nil
      @comment = Comment.new(comment_params)
      @comment.user = User.find(session[:user_id]).id
      
      respond_to do |format|
        if @comment.text.blank?
              format.html { redirect_to '/contribution_comments/' + @comment.contribution.to_s, alert: 'Please try again.' }
              msg = 'Text property cannot be blank'
              format.json { render json: msg.to_json, status: 400  }
        elsif @comment.save
          @contribution = Tweet.find(@comment.contribution)
          @user = User.find(@contribution.user_id)
          @user.karma += 5
          @user.save
          format.html { redirect_to '/tweets/'+@comment.contribution.to_s, notice2: 'Comment was successfully created.' }
          format.json { render json: @comment, status: 201 }
        else
          format.html { render :new }
          format.json { render json: @comment.errors, status: 422 }
        end
      end
    else
      respond_to do |format|
        format.json { render json: {message: 'Unauthorized, you don\'t have a valid api_key' }, status: 401 }
       end
    end
  end

  # PATCH/PUT /comments/1
  # PATCH/PUT /comments/1.json
  def update
      signin_apikey
      if session[:user_id] != nil
        if @comment.user == session[:user_id]
        respond_to do |format|
          if @comment.update(comment_update_params)
            format.html { redirect_to '/tweets' +  @comment.contribution.to_s}
            # format.json { render json: msg.to_json , status: 200, location: @comment }
            format.json { render json: @comment, status: 200 }
          else
            # format.html { render :edit }
            format.json { render json: @comment.errors, status: 422 }
          end
        end
        else
          respond_to do |format|
          format.json { render json: {message: 'Forbidden, you can\'t edit a comment that is not yours' }, status: 403 }
         end
       end
      else
      respond_to do |format|
        format.json { render json: {message: 'Unauthorized, you don\'t have a valid api_key' }, status: 401 }
       end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    signin_apikey
    if session[:user_id] != nil
      if @comment.user.to_s == session[:user_id].to_s
        @comment.destroy
        respond_to do |format|
          format.html { redirect_to comments_url, notice: 'Tweet was successfully destroyed.' }
          format.json { head :no_content }
        end
      else
        respond_to do |format|
        format.json { render json: {message: 'Forbidden, you can\'t delete a comment that is not yours' }, status: 403 }
       end
      end
    else
      respond_to do |format|
        format.json { render json: {message: 'Unauthorized, you don\'t have a valid api_key' }, status: 401 }
       end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def comment_params
      params.permit(:contribution, :text, :escomment, :comment_id)
    end
    
    def comment_update_params
      params.permit(:text, :created_at, :updated_at)
    end
    
    def signin_apikey
      if request.headers["X-API-KEY"] != nil
        puts "Header:"
        puts request.headers["X-API-KEY"]
        @user = User.where(api_key: request.headers["X-API-KEY"]).take
        session[:user_id] = @user.id
      end
    end
end
