class Event < ActiveRecord::Base
  attr_accessible :name, :start_time, :end_time
end
