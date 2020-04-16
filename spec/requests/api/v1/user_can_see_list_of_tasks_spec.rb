require "rails_helper"

RSpec.describe "Api::V1::TasksController", type: :request do
  let(:user) { create(:user) }
  let(:user_credentials) { user.create_new_auth_token }
  let(:user_headers) { { HTTP_ACCEPT: "application/json" }.merge!(user_credentials) }

  let(:task) { create(:task, user: user) }
  let!(:task_items) { 5.times { create(:task_item, task: task) } }

  let(:other_task) { create(:task, user: user) }
  let!(:other_task_items) { 5.times { create(:task_item, task: other_task) } }

  describe "GET /tasks" do
    before do
      put "/api/v1/tasks/#{task.id}",
        params: { activity: "confirmed" },
        headers: user_headers
      put "/api/v1/tasks/#{other_task.id}",
          params: { activity: "confirmed" },
          headers: user_headers
      get "/api/v1/tasks"
    end

    it "returns a 200 response status" do
      expect(response).to have_http_status 200
    end

    it "returns correct number of tasks" do
      expect(response_json.count).to eq 2
    end

    it "task contains five products" do
      expect(response_json[0]["products"].count).to eq 5
    end
  end
end
