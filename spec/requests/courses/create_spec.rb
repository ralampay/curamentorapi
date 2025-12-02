require 'rails_helper'

RSpec.describe 'Courses create' do
  include ApiHelpers
  include_context "authentication_context"

  let(:api_url) { '/courses' }

  describe "POST /courses", type: :request do
    context 'invalid calls' do
      it 'returns error if user is not logged in' do
        post api_url

        expect(response).to have_http_status(:forbidden)
      end

      it 'returns error for missing values' do
        post api_url, headers: user_headers

        payload = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_content)
        expect(payload['name']).to eq(['required'])
        expect(payload['code']).to eq(['required'])
      end

      it 'returns error for duplicate name' do
        course = FactoryBot.create(:course)

        params = {
          name: course.name,
          code: Faker::Alphanumeric.alphanumeric(number: 6).upcase
        }

        post api_url, params: params, headers: user_headers

        payload = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_content)
        expect(payload['name']).to eq(['already taken'])
      end

      it 'returns error for duplicate code' do
        course = FactoryBot.create(:course)

        params = {
          name: Faker::Lorem.sentence(word_count: 2),
          code: course.code
        }

        post api_url, params: params, headers: user_headers

        payload = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_content)
        expect(payload['code']).to eq(['already taken'])
      end
    end

    context 'valid calls' do
      it 'successfully creates a course' do
        params = {
          name: Faker::Educator.course_name,
          code: Faker::Alphanumeric.alphanumeric(number: 6).upcase
        }

        post api_url, params: params, headers: user_headers

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
