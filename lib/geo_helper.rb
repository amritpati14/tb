# simple lib to retrieve timezone and distance from the geocode coordinates
# (latitude/longitude)
require 'rest_client'

module GeoHelper
  RAD_PER_DEG = Math::PI / 180  # rad per degree
  EARTH_RAD   = 6371            # earth radius in km (used to calculate distance)
  
  # assume the class has latitude/longitude methods defined
  def self.included(other)
    unless (other.column_names & ['latitude', 'longitude']).size.eql? 2
      raise "latitude/longitude methods required"
    end
  end
  
  # get timezone for given lat/lng
  # returns a decimal num, representing an hours shift corresponding utc
  def timeshift
    zone = RestClient.get "http://api.geonames.org/timezone?lat=#{latitude}&lng=#{longitude}&username=textbuster"
    Hash.from_xml(zone)["geonames"]["timezone"]["gmtOffset"].to_f rescue nil
  end
  
  # get distance in km between two points
  def distance_to point
    dlon = (point.longitude - longitude) * RAD_PER_DEG
    dlat = (point.latitude - latitude) * RAD_PER_DEG

    a = (Math.sin(dlat/2))**2 + Math.cos(latitude*RAD_PER_DEG)*Math.cos(point.latitude*RAD_PER_DEG)*(Math.sin(dlon/2))**2
    (2 * Math.atan2( Math.sqrt(a), Math.sqrt(1-a)) * EARTH_RAD).round 2
  end
  
  # get geolocated address for given lat/lng
  def geolocate
    return nil if [latitude.to_f, longitude.to_f].include? 0.0
    
    data = RestClient.get "http://nominatim.openstreetmap.org/reverse?format=json&lat=#{latitude}&lon=#{longitude}&addressdetails=0"
    (JSON.parse(data) rescue [])['display_name']
  end
end
