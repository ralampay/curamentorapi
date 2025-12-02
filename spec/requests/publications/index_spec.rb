require 'rails_helper'

RSpec.describe 'Publications index' do
  include ApiHelpers
  include_context "authentication_context"

  let(:api_url) { '/publications' }

  describe "GET /publications", type: :request do
    context 'invalid calls' do
      it 'returns error if user is not logged in' do
        get api_url

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'valid calls' do
      it 'successfully returns the publication list' do
        FactoryBot.create(:publication)
        get api_url, headers: user_headers

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
