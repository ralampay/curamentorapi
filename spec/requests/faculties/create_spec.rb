require 'rails_helper'

RSpec.describe 'Faculties create' do
  include ApiHelpers
  include_context "authentication_context"

  let(:api_url) { '/faculties' }

  describe "POST /faculties", type: :request do
    context 'invalid calls' do
      it 'returns error if user is not logged in' do
        post api_url

        expect(response).to have_http_status(:forbidden)
      end

      it 'returns error for missing values' do
        post api_url, headers: user_headers

        payload = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_content)
        expect(payload['first_name']).to eq(['required'])
        expect(payload['last_name']).to eq(['required'])
        expect(payload['id_number']).to eq(['required'])
      end

      it 'returns error for duplicate id number' do
        faculty = FactoryBot.create(:faculty)

        params = {
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          id_number: faculty.id_number
        }

        post api_url, params: params, headers: user_headers

        payload = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_content)
        expect(payload['id_number']).to eq(['already taken'])
      end
    end

    context 'valid calls' do
      it 'successfully creates a faculty' do
        params = {
          first_name: Faker::Name.first_name,
          middle_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          id_number: Faker::Number.number(digits: 6).to_s
        }

        post api_url, params: params, headers: user_headers

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
