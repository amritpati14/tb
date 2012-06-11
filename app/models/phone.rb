class Phone < ActiveRecord::Base
  has_and_belongs_to_many :devices
  has_and_belongs_to_many :alerts
  has_many :events
  belongs_to :user

  validates :imei, :presence => true
  
  bitmask :abilities, :as => [:GPS, :Bluetooth]
  
  def last_position
    events.where("latitude is not null and longitude is not null").order("created_at desc").first
  end
  
  def restrictions
    alerts.map(&:restrictions)
  end
end
