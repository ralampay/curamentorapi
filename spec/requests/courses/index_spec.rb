require 'rails_helper'

RSpec.describe 'Courses index' do
  include ApiHelpers
  include_context "authentication_context"

  let(:api_url) { '/courses' }

  describe "GET /courses", type: :request do
    context 'invalid calls' do
      it 'returns error if user is not logged in' do
        get api_url

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'valid calls' do
      it 'successfully returns the course list' do
        get api_url, headers: user_headers

        expect(response).to have_http_status(:ok)
      end

      it 'filters courses by query' do
        course = FactoryBot.create(:course, name: "Physics 101", code: "PHY101")
        FactoryBot.create(:course, name: "Biology 101", code: "BIO101")

        get api_url, params: { q: 'Physics' }, headers: user_headers

        expect(response).to have_http_status(:ok)
        payload = JSON.parse(response.body)

        expect(payload['records'].size).to eq(1)
        expect(payload['records'][0]['id']).to eq(course.id)
      end
    end
  end
end
