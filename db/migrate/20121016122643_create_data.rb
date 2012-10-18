class CreateData < ActiveRecord::Migration
  def change
    create_table :procession_floats do |t|
      t.string  :name
      t.text    :text
      t.integer :offset
      t.integer :length
    end

    create_table :routes do |t|
      t.string  :name
    end

    create_table :points do |t|
      t.decimal :latitude
      t.decimal :longitude
      t.integer :route_id
    end
  end
end
