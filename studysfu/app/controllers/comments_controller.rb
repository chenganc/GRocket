class CommentsController < ApplicationController
  before_action :set_comment, only: [:show, :edit, :update, :destroy]
  #def index
  #  @comment = Comment.all
  #end
  def create
    @link = Link.find(params[:link_id])
    @comment = @link.comments.new(comment_params)
    @comment.user = current_user

    respond_to do |format|
      if @comment.save
        format.html { redirect_to @link, notice: 'Comment was successfully created.' }
        format.json { render json: @comment, status: :created, location: @comment }
      else
        flash[:error] = "Operation was unsuccessful."
        render 'new'
        #format.html { render action: "new" }
        #format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @comment.destroy
    #respond_to do |format|
    #  format.html { redirect_to :back, notice: 'Comment was successfully destroyed.' }
    #  format.json { head :no_content }
    #end
    flash[:info] = "Comment deleted"
    redirect_to :back
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def comment_params
      params.require(:comment).permit(:link_id, :body, :user_id)
    end

    def authorized_user
      @link = current_user.links.find_by(id: params[:id])
      redirect_to links_path, notice: "Not authorized" if @link.nil?
    end
end
