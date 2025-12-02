require 'rails_helper'

RSpec.describe 'Faculties delete' do
  include ApiHelpers
  include_context "authentication_context"

  let(:api_url) { '/faculties/:id' }
  let(:faculty) { FactoryBot.create(:faculty) }

  describe "DELETE /faculties/:id", type: :request do
    context 'invalid calls' do
      it 'returns error if user is not logged in' do
        delete api_url.gsub(":id", faculty.id)

        expect(response).to have_http_status(:forbidden)
      end

      it 'returns not found if faculty is not found' do
        delete api_url.gsub(":id", "non-existent"), headers: user_headers

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'valid calls' do
      it 'successfully deletes a faculty' do
        delete api_url.gsub(":id", faculty.id), headers: user_headers

        expect(response).to have_http_status(:ok)
        expect(Faculty.exists?(faculty.id)).to be_falsey
      end
    end
  end
end
