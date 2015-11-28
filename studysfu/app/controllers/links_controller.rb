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
      request_terms = JSON.parse(RestClient.get "#{SFU_CO_API}?#{year.number}")
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
      request_departments = JSON.parse(RestClient.get "#{SFU_CO_API}?#{year.number}/#{term.name}")
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
        request_courses = JSON.parse(RestClient.get "#{SFU_CO_API}?#{year.number}/#{term.name}/#{department.name}")
      rescue => e
        puts "#{SFU_CO_API}?#{year.number}/#{term.name}/#{department.name}"
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
        request_sections.each do |s|
          associated_class_obj = course.associated_classes.find_by(number: s["associatedClass"])
          if s["associatedClass"].blank?
            next
          end
          if !associated_class_obj
            associated_class_obj = AssociatedClass.new
            puts s["associatedClass"]
            associated_class_obj.number = s["associatedClass"]
            course.associated_classes << associated_class_obj
          end # !associated_class_obj

          section_obj = associated_class_obj.sections.find_by(key: s["text"])
          if !section_obj
            section_obj = Section.new
            section_obj.key = s["text"]
            section_obj.code = s["sectionCode"]
            associated_class_obj.sections << section_obj
          end # !section_obj

          section_fetch_error_count = 0

          begin
            request_section = JSON.parse(RestClient.get ("#{SFUAPI}?#{course.department.term.year.number}/#{course.department.term.name}/#{course.department.name}/#{course.number}/#{section_obj.key}".downcase))
          rescue => e
            puts "#{SFUAPI}?#{course.department.term.year.number}/#{course.department.term.name}/#{course.department.name}/#{course.number}/#{section_obj.key}".downcase
            puts e.response
            if section_fetch_error_count < 2
              section_fetch_error_count += 1
              retry
            else
              flash[:error] = "Could not load some Course Details"
              next
            end
          end
          section_obj.unique_number = request_section["info"]["classNumber"]
          if course.name.blank?
            course.name = request_section["info"]["title"]
            course.save
          end # course_obj.name.blank?

          if request_section["courseSchedule"]
            request_section["courseSchedule"].each_with_index do |sched, index|
              next if (sched["startDate"].blank? or sched["startTime"].blank? or sched["days"].blank?)

              sectiontime_obj = section_obj.section_times[index]
              if !sectiontime_obj
                sectiontime_obj = SectionTime.new
                section_obj.section_times << sectiontime_obj
              else
                sectiontime_obj.touch
              end # !sectiontime_obj

              sectiontime_obj.start_date = Date.parse(sched["startDate"])
              sectiontime_obj.start_time = Time.parse(sched["startTime"])
              sectiontime_obj.end_date = Date.parse(sched["endDate"])
              sectiontime_obj.end_time = Time.parse(sched["endTime"])
              sectiontime_obj.days = sched["days"]
              sectiontime_obj.building = sched["buildingCode"]
              sectiontime_obj.room = sched["roomNumber"]
              sectiontime_obj.campus = sched["campus"]
              sectiontime_obj.save
            end # request_section["courseSchedule"].each_with_index

            while section_obj.section_times.length > request_section["courseSchedule"].length do
              section_obj.section_times.last.destroy
            end
          end # request_section["courseSchedule"]

          if request_section["examSchedule"]
            request_section["examSchedule"].each_with_index do |exam, index|
              next if (exam["startDate"].blank? or exam["startTime"].blank?)

              exam_obj = section_obj.exams[index]
              if !exam_obj
                exam_obj = Exam.new
                section_obj.exams << exam_obj
              else
                exam_obj.touch
              end # !exam_obj

              time_start = Time.parse(exam["startTime"])
              time_end = Time.parse(exam["endTime"])

              exam_obj.exam_start = DateTime.parse(exam["startDate"]).change({hour: time_start.hour, min: time_start.min})
              exam_obj.exam_end = DateTime.parse(exam["endDate"]).change({hour: time_end.hour, min: time_end.min})
              exam_obj.building = exam["buildingCode"]
              exam_obj.room = exam["roomNumber"]
              exam_obj.campus = exam["campus"]
              exam_obj.save
            end # request_section["examSchedule"].each_with_index

            while section_obj.exams.length > request_section["examSchedule"].length do
              section_obj.exams.last.destroy
            end
          end # request_section["examSchedule"]

          if request_section["instructor"]
            request_section["instructor"].each_with_index do |instr, index|
              next if (instr["firstName"].blank? or instr["lastName"].blank?)

              instructor_obj = section_obj.instructors[index]
              if !instructor_obj
                instructor_obj = Instructor.new
                section_obj.instructors << instructor_obj
              else
                instructor_obj.touch
              end # !instructor_obj

              instructor_obj.first_name = instr["firstName"]
              instructor_obj.last_name = instr["lastName"]
              instructor_obj.email = instr["email"]
              instructor_obj.office = instr["office"]
              instructor_obj.office_hours = instr["officeHours"]
              instructor_obj.phone = instr["phone"]
              instructor_obj.website = instr["profileUrl"]
              instructor_obj.save
            end # request_section["instructors"].each_with_index

            while section_obj.instructors.length > request_section["instructor"].length do
              section_obj.instructors.last.destroy
            end
          end # request_section["instructors"]

          section_obj.save
          associated_class_obj.save
        end # request_sections.each
        course.save
      end
    end

    return course
  end
end
