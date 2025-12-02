require 'rails_helper'

RSpec.describe 'Authors create' do
  include ApiHelpers
  include_context "authentication_context"

  let(:publication) { FactoryBot.create(:publication) }
  let(:api_url) { "/publications/#{publication.id}/authors" }

  describe "POST /publications/:publication_id/authors", type: :request do
    context 'invalid calls' do
      it 'returns error if user is not logged in' do
        post api_url

        expect(response).to have_http_status(:forbidden)
      end

      it 'returns errors for missing values' do
        post api_url, headers: user_headers

        payload = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_content)
        expect(payload['person_type']).to eq(['required'])
        expect(payload['person_id']).to eq(['required'])
      end

      it 'returns error for invalid person type' do
        params = {
          person_type: 'Unknown',
          person_id: SecureRandom.uuid
        }

        post api_url, params: params, headers: user_headers

        payload = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_content)
        expect(payload['person_type']).to include('invalid')
      end

      it 'returns error for invalid person id' do
        params = {
          person_type: 'Student',
          person_id: SecureRandom.uuid
        }

        post api_url, params: params, headers: user_headers

        payload = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_content)
        expect(payload['person_id']).to include('invalid')
      end
    end

    context 'valid calls' do
      it 'creates an author for a publication' do
        student = FactoryBot.create(:student)
        params = {
          person_type: 'Student',
          person_id: student.id,
          is_primary: true
        }

        post api_url, params: params, headers: user_headers

        publication.reload

        expect(response).to have_http_status(:ok)
        expect(publication.authors.where(person: student)).to exist
      end
    end
  end
end
