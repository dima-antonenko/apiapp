require_relative "../api/api"
require "rack/test"

describe Api do
  include Rack::Test::Methods

  def app
  	Api
  end

  context 'GET /tasks' do
  	it 'returns the list of tasks' do
  		get '/tasks'
  		expect(last_response.status).to eq(200)
  	end
  end

  context 'GET /tasks/:id' do
  	it 'returns a task by id' do
  		get "/tasks/#{task.id}"
  		expect(last_response.status).to eq(200)
  	end
  end

end