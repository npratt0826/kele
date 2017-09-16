
require 'httparty'
require 'json'
require_relative './roadmap'

class Kele
  include HTTParty
  include Roadmap
  attr_reader :user, :current_enrollment, :messages, :email

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
    @email = @user['email']
    @mentor = @current_enrollment['mentor_id']
    @user_id = @user["id"]
    @enrollment_id = @current_enrollment["id"]
    @user

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
    # puts available.inspect1`
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
      response = self.class.post(api_url('messages'), body: { sender: @email, recipient_id: @mentor, subject: subject, "stripped-text": stripped }, headers: { authorization: @auth_token} )
    else
      response = self.class.post(api_url('messages'), body: { sender: @email, recipient_id: @mentor, token: token, subject: subject, "stripped-text": stripped }, headers: { authorization: @auth_token} )
    end
  end

  def create_submission(assignment_branch, assignment_commit_link, checkpoint_id, comment)
    response = self.class.post(api_url('checkpoint_submissions'), body: {assignment_branch: assignment_branch, assignment_commit_link: assignment_commit_link, checkpoint_id: checkpoint_id, comment: comment, enrollment_id: @enrollment_id}, headers: { authorization: @auth_token } )
  end

  private

  def api_url(endpoint)
    "https://www.bloc.io/api/v1/#{endpoint}"
  end
end
