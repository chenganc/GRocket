# class ResumelistsController < ApplicationController
#     before_action :logged_in_user, only: [:create, :destroy]
    
#     def create
#       # @user = User.find(params[:id])
        
#         @resumelist = current_user.resumelists.build(post_params)

# 		if @resumelist.save
# 			redirect_to resumelists_path
# 		else
# 			render resumelists_path
# 		end
#     end

#     def destroy
#         @user = User.find(params[:id])
#     end
# end
class ResumelistsController < ApplicationController
	#before_action :sessions.logged_in?, only: [:create, :upvote, :downvote]


	before_action :logged_in_user, only: [:create, :upvote, :downvote, :destroy, :edit, :update]
	before_action :correct_user,   only: [:destroy, :edit, :update]

	def index
		@resumelists = Resumelist.all.paginate(page: params[:page])
	end

	def create
		@resumelist = current_user.resumelists.build(resumelist_params)

		if @resumelist.save
			redirect_to resumelists_path
		else
			render resumelists_path
		end
	end

	def new
		@resumelist = Resumelist.new
	end

	def edit
	    @resumelist = Resumelist.find(params[:id])
	end

    def update
	    respond_to do |format|
	      if @resumelist.update(post_params)
	        format.html { redirect_to current_user, notice: 'Resumelist was successfully updated.' }
	        format.json { render :show, status: :ok, location: @resumelist }
	      else
	        format.html { render :edit }
	        format.json { render json: @resumelist.errors, status: :unprocessable_entity }
	      end
	    end
	end


	def upvote
		@resumelist = Resumelist.find(params[:id])

		if @resumelist.save
			@resumelist.upvote_by current_user
			flash[:info] = "Upvoted"
		else
			flash[:error] = "Please Sign In"
		end
		redirect_to resumelists_path
	end

	def downvote
		@resumelist = Resumelist.find(params[:id])

		if @resumelist.save
			@resumelist.downvote_by current_user
			flash[:info] = "Downvoted"
		else
			flash[:error] = "Please Sign In"
		end
		redirect_to resumelists_path
	end

#  	def destroy
#		@resumelist.destroy
#		flash[:success] = "Micropost deleted"
#		redirect_to request.referrer || root_url
#  	end

	def destroy
		@resumelist = Resumelist.find(params[:id])
		@resumelist.destroy
		redirect_to request.referrer
	end

	private

		def resumelist_params
		params.require(:resumelist).permit(:content, :section)
		end

		def logged_in_user
			unless logged_in?
				store_location
				#format.html { redirect_to login_url, notice: 'Please log in.' }
				flash[:error] = "Please log in."
				redirect_to login_url
			end
		end

	    def correct_user
	      @resumelist = current_user.resumelists.find_by(id: params[:id])
	      redirect_to root_url if @resumelist.nil?
	    end
end
