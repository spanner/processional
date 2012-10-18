class ProcessionFloatsController < ApplicationController
  respond_to :html, :json, :js

  def index
    @floats = ProcessionFloat.all
    respond_with @floats
  end
  
  def show
    @float = ProcessionFloat.find(params[:id])
    respond_with @float do |format|
      format.js { render :partial => "float" }
    end
  end
  
end
