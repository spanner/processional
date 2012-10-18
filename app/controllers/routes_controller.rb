class RoutesController < ApplicationController
  respond_to :html, :json
  before_filter :get_route, :only => :show

  def index
    @routes = Route.all
    respond_with @routes
  end
  
  def show
    respond_with @route
  end

private

  def get_route
    @route = Route.find(params[:id])
  end
end
