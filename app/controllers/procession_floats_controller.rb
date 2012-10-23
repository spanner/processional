class ProcessionFloatsController < ApplicationController
  respond_to :html, :json, :js

  def index
    @data = File.read("lib/json_data/floats.json")
    @floats = ProcessionFloat.all
    respond_with @floats do |format|
      format.json {render :json => @data}
    end
  end
  
  def show
    @float = ProcessionFloat.find(params[:id])
    respond_with @float do |format|
      format.js { render :partial => "float" }
    end
  end


end
