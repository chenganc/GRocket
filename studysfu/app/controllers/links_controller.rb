class LinksController < ApplicationController
  before_action :set_link, only: [:show, :edit, :update, :destroy]
  before_action :authorized_user, only: [:edit, :update, :destroy]
  require 'rest-client'
  require 'date'
  SFUAPI="http://www.sfu.ca/bin/wcm/course-outlines"
  # GET /links
  # GET /links.json
  def index
    @links = Link.paginate(page: params[:page])
  end

  # GET /links/1
  # GET /links/1.json
  def show
  end

  # GET /links/new
  def new
    @link = Link.new

    if Year.count == 0 or (Time.now-(Year.order('updated_at').last.updated_at)) > 1.month
      request_years = JSON.parse(RestClient.get SFUAPI)
      request_years.each do |y|
        year_obj = Year.find_by(number: y["text"])
        if !year_obj
          year_obj = Year.new
          year_obj.number = y["text"]
          year_obj.save
        else
          year_obj.touch
        end
      end
    end

    @years = Year.order('number ASC').all
    if !params[:year].to_s.blank?
      year = Year.find(params[:year])
      @terms = get_terms_api(year).order('name ASC')
      @year_select = params[:year]
    else
      @terms = []
    end
    if !params[:term].to_s.blank?
      term = Term.find(params[:term])
      @departments = get_departments_api(term).order('name ASC')
      @term_select = params[:term]
    else
      @departments = []
    end
    if !params[:department].to_s.blank?
      department = Department.find(params[:department])
      @courses = get_courses_api(department).order('number ASC')
      @department_select = params[:department]
    else
      @courses = []
    end
    if !params[:course].to_s.blank?
      course = Course.find(params[:course])
    end
  end

  # GET /links/1/edit
  def edit
    if Year.count == 0 or (Time.now-(Year.order('updated_at').last.updated_at)) > 1.month
      request_years = JSON.parse(RestClient.get SFUAPI)
      request_years.each do |y|
        year_obj = Year.find_by(number: y["text"])
        if !year_obj
          year_obj = Year.new
          year_obj.number = y["text"]
          year_obj.save
        else
          year_obj.touch
        end
      end
    end

    @years = Year.order('number ASC').all
    if !params[:year].to_s.blank?
      year = Year.find(params[:year])
      @terms = get_terms_api(year).order('name ASC')
      @year_select = params[:year]
    else
      @terms = []
    end
    if !params[:term].to_s.blank?
      term = Term.find(params[:term])
      @departments = get_departments_api(term).order('name ASC')
      @term_select = params[:term]
    else
      @departments = []
    end
    if !params[:department].to_s.blank?
      department = Department.find(params[:department])
      @courses = get_courses_api(department).order('number ASC')
      @department_select = params[:department]
    else
      @courses = []
    end
    if !params[:course].to_s.blank?
      course = Course.find(params[:course])
    end
  end

  # POST /links
  # POST /links.json
  def create
    @link = current_user.links.new(link_params)

    respond_to do |format|
      if @link.save
        flash[:info] = "Post was successfully created"
        #redirect_to @link
        format.html { redirect_to @link, notice: 'Link was successfully created.' }
        format.json { render :show, status: :created, location: @link }
      else
        flash[:error] = "Post could not be created"
        #redirect_to @link
        format.html { render :new }
        format.json { render json: @link.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /links/1
  # PATCH/PUT /links/1.json
  def update
    #respond_to do |format|
      if @link.update(link_params)
        flash[:info] = "Post was successfully updated"
        redirect_to @link
        #format.html { redirect_to @link, notice: 'Link was successfully updated.' }
        #format.json { render :show, status: :ok, location: @link }
      else
        flash[:error] = "Post could not be updated"
        redirect_to @link
        #format.html { render :edit }
        #format.json { render json: @link.errors, status: :unprocessable_entity }
      end
    #end
  end

  # DELETE /links/1
  # DELETE /links/1.json
  def destroy
    #@link.destroy
    #respond_to do |format|
    #  format.html { redirect_to links_url, notice: 'Link was successfully destroyed.' }
    #  format.json { head :no_content }
    #end
    @link.destroy
    flash[:info] = "Post deleted"
    redirect_to links_path
  end

  def upvote
    @link = Link.find(params[:id])
    @link.upvote_by current_user
    redirect_to :back
  end

  def downvote
    @link = Link.find(params[:id])
    @link.downvote_from current_user
    redirect_to :back
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_link
      @link = Link.find(params[:id])
    end

    def authorized_user
      @link = current_user.links.find_by(id: params[:id])
      redirect_to links_path, notice: "Not authorized to edit this link" if @link.nil?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def link_params
      params.require(:link).permit(:title, :course, :department, :body, :attachment)
    end

    def admin_user
      redirect_to(root_path) unless current_user && current_user.admin?
    end

    def get_terms_api(year)
    terms = year.terms

    if terms.count == 0 or (Time.now-(terms.order('updated_at').last.updated_at)) > 1.month
      request_terms = JSON.parse(RestClient.get "#{SFUAPI}?#{year.number}")
      request_terms.each do |t|
        term_obj = year.terms.find_by(name: t["text"])
        if !term_obj
          term_obj = Term.new
          term_obj.name = t["text"]
          year.terms << term_obj
        else
          term_obj.touch
        end
      end
      year.save
    end

    return terms
  end

  def get_departments_api(term)
    year = term.year
    departments = term.departments

    if departments.count == 0 or (Time.now-(departments.order('updated_at').last.updated_at)) > 1.month
      request_departments = JSON.parse(RestClient.get "#{SFUAPI}?#{year.number}/#{term.name}")
      request_departments.each do |d|
        # department_obj = Department.find_by(name: d["text"], term_id: term.id)
        department_obj = term.departments.find_by(name: d["text"])
        if !department_obj
          department_obj = Department.new
          department_obj.name = d["text"]
          term.departments << department_obj
        else
          department_obj.touch
        end
      end
      term.save
    end

    return departments
  end

  def get_courses_api(department)
    term = department.term
    year = term.year
    courses = department.courses

    if courses.count == 0 or (Time.now-(courses.order('updated_at').last.updated_at)) > 2.weeks
      begin
        request_courses = JSON.parse(RestClient.get "#{SFUAPI}?#{year.number}/#{term.name}/#{department.name}")
      rescue => e
        puts "#{SFUAPI}?#{year.number}/#{term.name}/#{department.name}"
        puts e.response
        courses = []
        return
      end
      request_courses.each do |c|
        # course_obj = Course.find_by(number: c["text"], department_id: department.id)
        course_obj = department.courses.find_by(number: c["text"])
        if !course_obj
          course_obj = Course.new
          course_obj.number = c["text"]
          department.courses << course_obj
        else
          course_obj.touch
        end # !course_obj

        course_obj.save
      end # request_courses.each do
      department.save
    end # courses.count == 0 or (Time.now-(courses.order('updated_at').last.updated_at)) > 1.day

    return courses
  end

  def get_terms
    year = Year.find(params[:year_id])
    @terms = get_terms_api(year).order('name ASC')
  end

  def get_departments
    term = Term.find(params[:term_id])
    @departments = get_departments_api(term).order('name ASC')
  end

  def get_courses
    department = Department.find(params[:department_id])

    @courses = get_courses_api(department).order('number ASC')
  end

  def get_course_api(course)
    course.with_lock do
      if course.associated_classes.length == 0 or (Time.now-(course.associated_classes.order('updated_at').last.updated_at)) > 2.weeks
        sections_fetch_error_count = 0

        begin
          request_sections = JSON.parse(RestClient.get "#{SFUAPI}?#{course.department.term.year.number}/#{course.department.term.name}/#{course.department.name}/#{course.number}")
        rescue => e
          puts "#{SFUAPI}?#{course.department.term.year.number}/#{course.department.term.name}/#{course.department.name}/#{course.number}"
          puts e.response # Redo.
          if sections_fetch_error_count < 2
            sections_fetch_error_count += 1
            retry
          else
            flash[:error] = "Could not load Course Details"
            return
          end
        end
        course.save
      end
    end

    return course
  end
end
