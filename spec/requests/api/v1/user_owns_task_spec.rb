# frozen_string_literal: true

RSpec.describe 'Api::V1::TasksController', type: :request do
  let!(:user) { create(:user) }
  let!(:user_credentials) { user.create_new_auth_token }
  let!(:user_headers) { { HTTP_ACCEPT: 'application/json' }.merge!(user_credentials) }

  let!(:user_1) { create(:user, email: 'papapa@mail.com') }
  let!(:user_credentials_1) { user.create_new_auth_token }
  let!(:user_headers_1) { { HTTP_ACCEPT: 'application/json' }.merge!(user_credentials_1) }


  let!(:product_1) {create(:product, name: "pasta", price: 20)}
    
  describe 'Successfully' do
    describe 'user can create a task' do
      before do
        post "/api/v1/tasks",
             params: {
              product_id: product_1.id,
                user_id: user.id,
                confirmed: true
               },
             headers: user_headers
      end

      it 'returns a 200 response status' do
        expect(response).to have_http_status 200
      end
    end
  end

  describe 'Unsuccessfully' do
    let(:task) { create(:task, user: user, confirmed: true) }
    let!(:task_items) { 5.times { create(:task_item, task: task) } }

    describe 'user can create a task' do
      before do
        post "/api/v1/tasks",
             params: {
              product_id: product_1.id,
                user_id: user.id,
               },
             headers: user_headers
      end

      it 'returns a 400 response status' do
        binding.pry
        expect(response).to have_http_status 403
      end

      it 'User has an active task' do
        expect(response_json[message]).to eq 'You already an active task, please remove it or update it.'
      end
    end
  end
end
