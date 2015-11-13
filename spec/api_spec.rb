describe Api do
  include Rack::Test::Methods

  def app; Api end

  let(:json) { JSON.parse last_response.body }
  let(:expected_status_code) { 200 }

  shared_examples "a successful request" do
    it "is success" do
      expect(last_response).to be_success
      expect(last_response.status).to be expected_status_code
    end

    it "returns correct JSON" do
      expect(json).to eq expected_json
    end
  end

  describe "GET: /tasks" do
    before do
      # populate! # need to implement
      get "/tasks"
    end

    context "when many records" do
      it_behaves_like "a successful request"
    end

    context "when only one record" do
      it_behaves_like "a successful request"
    end

    context "when no records" do
      it_behaves_like "a successful request"
    end
  end

  describe "GET: /tasks/:task_id" do
    before do
      # poputale! # need to implement
      task = {task_id: 1, title: "Task 1", description: "Do something!"}

      get "/tasks/#{task[:task_id]}"

      context "when task with given ID exists" do
        it_behaves_like "a successful request"
      end

      context "when task with given ID doesn't exists" do

      end
    end
  end
end
