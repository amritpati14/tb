class Device < ActiveRecord::Base
  belongs_to :family
  has_and_belongs_to_many :phones
  has_many :reports, :order => 'created_at desc'
  has_many :events
  
  validates :mac, :presence => true, :uniqueness => true, :length => {:maximum => 50}
  validates :name, :presence => true, :length => {:maximum => 255}
  
  def last_position
    events.where("latitude is not null and longitude is not null").order("created_at desc").first
  end
  
  def display_name
    name || mac rescue ''
  end
end
