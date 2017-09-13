
require 'httparty'
require 'json'
require_relative './roadmap'

class Kele
  include HTTParty
  include Roadmap
  attr_reader :user, :current_enrollment, :messages

  base_uri "https://www.bloc.io/api/v1/"

  def initialize(email, password)
    response = self.class.post(api_url("sessions"), body: {"email": email, "password": password})
    raise 'Invalid email or password' if response.code == 404
    @auth_token = response["auth_token"]
    get_me
  end

  def get_me
    response = self.class.get(api_url("users/me"), headers: {"authorization" => @auth_token})
    @user = JSON.parse(response.body)
    @current_enrollment = @user['current_enrollment']
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

  def get_messages(page_num = nil)
    if page_num == nil
      response = self.class.get(api_url('message_threads'), headers: { authorization: @auth_token } )
      @messages = JSON.parse(response.body)
    else
      response = self.class.get(api_url('message_threads'), body: { page: page_num }, headers: { :authorization => @auth_token })
      @messages = JSON.parse(response.body)
    end

  end

  def create_message(token = nil, subject, stripped)
    if token == nil
      response = self.class.post(api_url('messages'), body: { sender: @user['email'], recipient_id: @user['mentor_id'], subject: subject, stripped: stripped }, headers: { authorization: @auth_token} )
    else
      response = self.class.post(api_url('messages'), body: { sender: @user['email'], recipient_id: @user['mentor_id'], token: token, subject: subject, stripped: stripped }, headers: { authorization: @auth_token} )
    end

  end

  private

  def api_url(endpoint)
    "https://www.bloc.io/api/v1/#{endpoint}"
  end
end
