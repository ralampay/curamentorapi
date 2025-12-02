require 'rails_helper'

RSpec.describe 'Authors index' do
  include ApiHelpers
  include_context "authentication_context"

  let(:publication) { FactoryBot.create(:publication) }
  let(:api_url) { "/publications/#{publication.id}/authors" }

  describe "GET /publications/:publication_id/authors", type: :request do
    context 'invalid calls' do
      it 'returns forbidden when unauthenticated' do
        get api_url

        expect(response).to have_http_status(:forbidden)
      end

      it 'returns not found when publication is missing' do
        get "/publications/non-existent/authors", headers: user_headers

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'valid calls' do
      it 'returns publication authors' do
        FactoryBot.create_list(:author, 2, publication: publication)

        get api_url, headers: user_headers

        expect(response).to have_http_status(:ok)
        payload = JSON.parse(response.body)

        expect(payload).to be_an(Array)
        expect(payload.size).to eq(2)
      end
    end
  end
end
