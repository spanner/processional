class ProcessionFloat < ActiveRecord::Base
  attr_accessible :name, :length, :offset, :text
  
  default_scope order("procession_floats.offset")
  
  def as_json(options={})
    {
      :offset => offset,
      :id => id,
      :name => name,
      :length => length
    }
  end
end