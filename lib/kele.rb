
require 'httparty'
require 'json'

class Kele
  include HTTParty
  attr_reader :user

  base_uri "https://www.bloc.io/api/v1/"

  def initialize(email, password)
    response = self.class.post(api_url("sessions"), body: {"email": email, "password": password})
    raise 'Invalid email or password' if response.code == 404
    @auth_token = response["auth_token"]
  end

  def get_me
    response = self.class.get(api_url("users/me"), headers: {"authorization" => @auth_token})
    @user = JSON.parse(response.body)
    # @user_id = @user["id"]
  end

  def get_mentor_availability(id)
    response = self.class.get(api_url("mentors/#{id}/student_availability"), headers: { :authorization => @auth_token } )
    available = []
    response.each do |timeslot|
      if timeslot["booked"] == nil
        # available >> timeslot
        available.push(timeslot)
      end
    end
    # puts available.inspect
    puts available
  end


  private

  def api_url(endpoint)
    "https://www.bloc.io/api/v1/#{endpoint}"
  end
end
