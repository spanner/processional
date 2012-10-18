class Point < ActiveRecord::Base
  attr_accessible :latitude, :longitude, :route_id
  belongs_to :route
  
  def as_json(options={})
    {
      latitude: latitude,
      longitude: longitude,
      id: id
    }
  end
end
