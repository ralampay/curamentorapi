require 'rails_helper'

RSpec.describe 'Faculties show' do
  include ApiHelpers
  include_context "authentication_context"

  let(:api_url) { '/faculties/:id' }

  describe "GET /faculties/:id", type: :request do
    context 'invalid calls' do
      it 'returns error if user is not logged in' do
        faculty = FactoryBot.create(:faculty)
        get api_url.gsub(":id", faculty.id)

        expect(response).to have_http_status(:forbidden)
      end

      it 'returns not found if faculty is not found' do
        get api_url.gsub(":id", "non-existent"), headers: user_headers

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'valid calls' do
      it 'successfully returns a faculty' do
        faculty = FactoryBot.create(:faculty)
        get api_url.gsub(":id", faculty.id), headers: user_headers

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
