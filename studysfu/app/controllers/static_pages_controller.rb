class StaticPagesController < ApplicationController
  def home
    if logged_in?
      @link  = current_user.links.build
      @feed_items = current_user.feed.paginate(page: params[:page])
    end
  end

  def personalpage
  end

  def coursepage
  end

  def posting
  end

  def login
  end
end
