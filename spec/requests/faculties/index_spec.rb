require 'rails_helper'

RSpec.describe 'Faculties index' do
  include ApiHelpers
  include_context "authentication_context"

  let(:api_url) { '/faculties' }

  describe "GET /faculties", type: :request do
    context 'invalid calls' do
      it 'returns error if user is not logged in' do
        get api_url

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'valid calls' do
      it 'successfully returns the faculty list' do
        get api_url, headers: user_headers

        expect(response).to have_http_status(:ok)
      end

      it 'filters faculties by query' do
        faculty = FactoryBot.create(:faculty, first_name: "Carol", last_name: "Lee")
        FactoryBot.create(:faculty, first_name: "David", last_name: "Brown")

        get api_url, params: { q: 'Lee' }, headers: user_headers

        expect(response).to have_http_status(:ok)
        payload = JSON.parse(response.body)

        expect(payload['records'].map { |r| r['id'] }).to eq([faculty.id])
      end
    end
  end
end
