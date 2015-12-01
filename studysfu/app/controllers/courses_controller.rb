class CoursesController < ApplicationController
  before_action :valid_course, only: [:show, :info, :course_members]
  before_action :verify_membership, only: [:show]
  require 'rest-client'
  require 'date'

  SFU_CO_API = "http://www.sfu.ca/bin/wcm/course-outlines"

  def index
    if Year.count == 0 or (Time.now-(Year.order('updated_at').last.updated_at)) > 1.month
      request_years = JSON.parse(RestClient.get SFU_CO_API)
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
      @course_select = params[:course]
    else
      @courses = []
    end
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

  def info
    @course = Course.find_by(id: params[:id])
    @cm = current_user.course_memberships.find_by(course_id: @course.id)

    get_course_api(@course)
  end

  def show
    @course = Course.find_by(id: params[:id])

    get_course_api(@course)

    @chat_channel_type = 1;
    @post_channel_type = 4;
    @messages = Message.where(channel_type: @chat_channel_type, channel_id: @course.id).last(30)
    @posts = Message.where(channel_type: @post_channel_type, channel_id: @course.id).last(30)
  end

  def course_members
    @course = Course.find_by(id: params[:id])
    @users = @course.users.paginate(page: params[:page], per_page: 25).order('created_at ASC')
  end

  private

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

  def get_course_api(course)
    course.with_lock do
      if course.associated_classes.length == 0 or (Time.now-(course.associated_classes.order('updated_at').last.updated_at)) > 2.weeks
        sections_fetch_error_count = 0

        begin
          request_sections = JSON.parse(RestClient.get "#{SFU_CO_API}?#{course.department.term.year.number}/#{course.department.term.name}/#{course.department.name}/#{course.number}")
        rescue => e
          puts "#{SFU_CO_API}?#{course.department.term.year.number}/#{course.department.term.name}/#{course.department.name}/#{course.number}"
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
