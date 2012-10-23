class RoutesController < ApplicationController
  respond_to :html, :json
  before_filter :get_route, :only => :show

  def index
    @routes = Route.all
    respond_with @routes
  end
  
  def show
    @data = File.read("lib/json_data/route.json")
    respond_with @route do |format|
      format.json {render :json => @data}
    end
  end

private

  def get_route
    @route = Route.find(params[:id])
  end
end
