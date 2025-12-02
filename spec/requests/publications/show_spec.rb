require 'rails_helper'

RSpec.describe 'Publications show' do
  include ApiHelpers
  include_context "authentication_context"

  let(:api_url) { '/publications/:id' }

  describe "GET /publications/:id", type: :request do
    context 'invalid calls' do
      it 'returns error if user is not logged in' do
        publication = FactoryBot.create(:publication)
        get api_url.gsub(":id", publication.id)

        expect(response).to have_http_status(:forbidden)
      end

      it 'returns not found if publication is not found' do
        get api_url.gsub(":id", "non-existent"), headers: user_headers

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'valid calls' do
      it 'successfully returns a publication' do
        publication = FactoryBot.create(:publication)
        get api_url.gsub(":id", publication.id), headers: user_headers

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
