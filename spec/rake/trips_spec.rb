require 'spec_helper'
require "rake"

describe "Test rake trips tasks" do
	before do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "lib/tasks/trips"
    Rake::Task.define_task(:environment)
  end

  describe Mailer do
  	it 'mail should be sent' do
  		alert = Factory.create :alert
  		phone = Factory.create :phone
  		user = Factory.build :user
  		PhonesLog.stub!(:phone).and_return(phone)
  		alert.stub!(:users).and_return([user])
  		email = Mailer.alert_notification(Time.now, alert, PhonesLog, Event, Trip).deliver
  		ActionMailer::Base.deliveries.empty?.should be_false  		
  		email.to.should include user.email
  		email.subject.should match("You are being sent an alert message")
  	end
	end

  describe "rake trips:speed" do
  	before do
      @task_name = "trips:speed"
    end

		it "should have 'environment' as a prereq" do
      @rake[@task_name].prerequisites.should include("environment")
    end

    it 'speed and distance should be calculated' do
			trip = Factory.create :trip
			locations = Factory.create :location, {:trip_id => trip.id, :lat => 49.628162, :lng => 49.628162, :time => 1343220263}
			locations = Factory.create :location, {:trip_id => trip.id, :lat => 49.626357, :lng => 49.626357, :time => 1343223863}
			@rake[@task_name].execute
			trip.reload.distance.to_f.should == 0.15
			trip.reload.average_speed.to_f.should == 178.95
  	end

  	it 'trip should be created' do
      User.stub!(:admin?).and_return(false)
  		user = Factory.create :user
  		device = Factory.create :device
  		phone = Factory.create :phone, {:user_id => user.id}
  		phones_log = Factory.create :phones_log, {:imei => phone.imei}
  		location = Factory.create :location
  		time = Time.now
  		event = Factory.create :event, {:phones_log_id => phones_log.id, 
  			:time => time,
  			:alert => 3,
  			:gps => 3,
  			:locked => 2,
  			:textbuster_mac => device.imei,
  			:locations_id => location.id
  		}


  		@rake['trips:calculate'].execute
			Trip.count.should == 1
  	end

  end

end