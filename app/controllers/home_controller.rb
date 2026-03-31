class HomeController < ApplicationController
  skip_before_action :login_required

  layout "application"

  def index
  end
end
