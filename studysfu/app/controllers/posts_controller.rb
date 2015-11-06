class PostsController < ApplicationController
	#before_action :sessions.logged_in?, only: [:create, :upvote, :downvote]


	  before_action :logged_in_user, only: [:create, :upvote, :downvote]
	def index
		@posts = Post.all
	end

	def create
		@post = current_user.posts.build(post_params)

		if @post.save
			redirect_to root_path
		else
			render posts_path
		end
	end

	def new
		@post = Post.new
	end

	def upvote
		@post = Post.find(params[:id])

		if @post.save
			@post.upvote_by current_user
			flash[:info] = "Upvoted"
		else
			flash[:error] = "Please Sign In"
		end
		redirect_to posts_path
	end

	def downvote
		@post = Post.find(params[:id])

		if @post.save
			@post.downvote_by current_user
			flash[:info] = "Downvoted"
		else
			flash[:error] = "Please Sign In"
		end
		redirect_to posts_path
	end

	private

		def post_params
			params.require(:post).permit(:title, :url, :body)
		end

		def logged_in_user
			unless logged_in?
				store_location
				#format.html { redirect_to login_url, notice: 'Please log in.' }
				flash[:error] = "Please log in."
				redirect_to login_url
			end
		end
end
