require 'rails_helper'

RSpec.describe 'Publications delete' do
  include ApiHelpers
  include_context "authentication_context"

  let(:api_url) { '/publications/:id' }
  let(:publication) { FactoryBot.create(:publication) }

  describe "DELETE /publications/:id", type: :request do
    context 'invalid calls' do
      it 'returns error if user is not logged in' do
        delete api_url.gsub(":id", publication.id)

        expect(response).to have_http_status(:forbidden)
      end

      it 'returns not found if publication is not found' do
        delete api_url.gsub(":id", "non-existent"), headers: user_headers

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'valid calls' do
      it 'successfully deletes a publication' do
        delete api_url.gsub(":id", publication.id), headers: user_headers

        expect(response).to have_http_status(:ok)
        expect(Publication.exists?(publication.id)).to be_falsey
      end
    end
  end
end
