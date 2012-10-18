class PointsController < ApplicationController
  respond_to :html, :json

  def index
    @route = Route.find(params[:route_id])
    @points = @route.points
    respond_with @points
  end
  
  def show
    @point = Point.find(params[:id])
    respond_with @point
  end
  
end
