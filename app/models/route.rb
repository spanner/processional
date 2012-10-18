class Route < ActiveRecord::Base
  attr_accessible :name
  has_many :points
  
  def as_json(options={})
    {
      name: name,
      points: points.as_json({})
    }
  end
  
end