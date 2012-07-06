class Device < ActiveRecord::Base
  belongs_to :family
  has_and_belongs_to_many :phones
  has_many :reports, :order => 'created_at desc'
  
  has_many :events, :through => :phones_log, :foreign_key => 'textbuster_mac'
  has_many :phones_log, :foreign_key => 'imei', :primary_key => 'imei'
  has_many :calculated_events, :foreign_key => 'imei', :primary_key => 'textbuster_mac'
  
  validates :imei, :presence => true, :uniqueness => true, :length => {:maximum => 50}
  validates :name, :presence => true, :length => {:maximum => 255}
  
  def last_position
    events.where('locations_id IS NOT NULL').order("created desc").first
  end
  
  def display_name
    name || imei rescue ''
  end
end
