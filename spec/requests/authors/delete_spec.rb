require 'rails_helper'

RSpec.describe 'Authors delete' do
  include ApiHelpers
  include_context "authentication_context"

  let(:publication) { FactoryBot.create(:publication) }
  let(:author) { FactoryBot.create(:author, publication: publication) }
  let(:api_url) { "/publications/#{publication.id}/authors/#{author.id}" }

  describe "DELETE /publications/:publication_id/authors/:id", type: :request do
    context 'invalid calls' do
      it 'returns error if user is not logged in' do
        delete api_url

        expect(response).to have_http_status(:forbidden)
      end

      it 'returns not found if publication is missing' do
        delete "/publications/non-existent/authors/#{author.id}", headers: user_headers

        expect(response).to have_http_status(:not_found)
      end

      it 'returns not found if author is missing' do
        delete "/publications/#{publication.id}/authors/non-existent", headers: user_headers

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'valid calls' do
      it 'deletes the specified author' do
        delete api_url, headers: user_headers

        expect(response).to have_http_status(:ok)
        expect(Author.exists?(author.id)).to be_falsey
      end
    end
  end
end
