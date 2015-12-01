# class ResumesController < ApplicationController
# end
class ResumesController < ApplicationController
	#before_action :sessions.logged_in?, only: [:create, :upvote, :downvote]


	# before_action :logged_in_user, only: [:create, :upvote, :downvote, :destroy, :edit, :update, :show]
	before_action :correct_user,   only: [:destroy, :edit, :update, :show, :create]

	def index
		# @resumes = Resume.all.paginate(page: params[:page])
		@resumes = Resume.all
	end

	def create
		@resume = current_user.resumes.build(resume_params)

		# if @resume.save
		# 	redirect_to resumes_path
		# else
		# 	render resumes_path
		# end
		respond_to do |format|
	      if @resume.save
	        format.html { redirect_to action: "index", notice: 'Resume was successfully created.' }
	        format.json { render :show, status: :created, location: @resume }
	      else
	        format.html { render :new }
	        format.json { render json: @resume.errors, status: :unprocessable_entity }
	      end
	    end
	end
	
	def show
	    
	end

	def new
		@resume = Resume.new
	end

	def edit
	    @resume = Resume.find(params[:id])
	end

    def update
	    respond_to do |format|
	      if @resume.update(resume_params)
	        format.html { redirect_to action: "index", notice: 'Resume was successfully updated.' }
	        format.json { render :show, status: :ok, location: @resume }
	      else
	        format.html { render :edit }
	        format.json { render json: @resume.errors, status: :unprocessable_entity }
	      end
	    end
	end


	def upvote
		@resume = Resume.find(params[:id])

		if @resume.save
			@resume.upvote_by current_user
			flash[:info] = "Upvoted"
		else
			flash[:error] = "Please Sign In"
		end
		redirect_to resumes_path
	end

	def downvote
		@resume = Resume.find(params[:id])

		if @resume.save
			@resume.downvote_by current_user
			flash[:info] = "Downvoted"
		else
			flash[:error] = "Please Sign In"
		end
		redirect_to resumes_path
	end

#  	def destroy
#		@resume.destroy
#		flash[:success] = "Micropost deleted"
#		redirect_to request.referrer || root_url
#  	end

	def destroy
		@resume = Resume.find(params[:id])
		@resume.destroy
		redirect_to request.referrer
	end

	private
		def set_link
      		@resume = Resume.find(params[:id])
		end

		def resume_params
		params.require(:resume).permit(:name, :email, :phone, :p1, :p2, :p3, :p4, :p5, :p6, :p7, :p8)
		end
		
		def authorized_user
	      @resume = current_user.resumes.find_by(id: params[:id])
	      redirect_to resumes_path, notice: "Not authorized to edit this resume" if @resume.nil?
		end
	    
	     def admin_user
	      redirect_to(root_path) unless current_user && current_user.admin?
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
	      @resume = current_user.resumes.find_by(id: params[:id])
	      #redirect_to root_url if @resume.nil?
	    end
end
