require 'rails_helper'

RSpec.describe 'Students create' do
  include ApiHelpers
  include_context "authentication_context"

  let(:api_url) { '/students' }
  let(:course) { FactoryBot.create(:course) }

  describe "POST /students", type: :request do
    context 'invalid calls' do
      it 'returns error if user is not logged in' do
        post api_url

        expect(response).to have_http_status(:forbidden)
      end

      it 'returns error for missing values' do
        post api_url, headers: user_headers

        payload = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_content)
        expect(payload['course_id']).to eq(['required'])
        expect(payload['first_name']).to eq(['required'])
        expect(payload['middle_name']).to eq(['required'])
        expect(payload['last_name']).to eq(['required'])
        expect(payload['id_number']).to eq(['required'])
        expect(payload['email']).to eq(['required'])
      end

      it 'returns error for duplicate email' do
        student = FactoryBot.create(:student)

        params = {
          course_id: course.id,
          first_name: Faker::Name.first_name,
          middle_name: Faker::Name.middle_name,
          last_name: Faker::Name.last_name,
          id_number: "ID-#{Faker::Number.number(digits: 6)}",
          email: student.email
        }

        post api_url, params: params, headers: user_headers

        payload = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_content)
        expect(payload['email']).to eq(['already taken'])
      end
    end

    context 'valid calls' do
      it 'successfully creates a student' do
        params = {
          course_id: course.id,
          first_name: Faker::Name.first_name,
          middle_name: Faker::Name.middle_name,
          last_name: Faker::Name.last_name,
          id_number: "ID-#{Faker::Number.number(digits: 6)}",
          email: Faker::Internet.unique.email
        }

        post api_url, params: params, headers: user_headers

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
