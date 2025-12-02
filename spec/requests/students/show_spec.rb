require 'rails_helper'

RSpec.describe 'Students show' do
  include ApiHelpers
  include_context "authentication_context"

  let(:api_url) { '/students/:id' }

  describe "GET /students/:id", type: :request do
    context 'invalid calls' do
      it 'returns error if user is not logged in' do
        student = FactoryBot.create(:student)
        get api_url.gsub(":id", student.id)

        expect(response).to have_http_status(:forbidden)
      end

      it 'returns not found if student is not found' do
        get api_url.gsub(":id", "non-existent"), headers: user_headers

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'valid calls' do
      it 'successfully returns a student' do
        student = FactoryBot.create(:student)
        get api_url.gsub(":id", student.id), headers: user_headers

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
