require 'rails_helper'

RSpec.describe 'Courses show' do
  include ApiHelpers
  include_context "authentication_context"

  let(:api_url) { '/courses/:id' }

  describe "GET /courses/:id", type: :request do
    context 'invalid calls' do
      it 'returns error if user is not logged in' do
        get api_url.gsub(":id", user.id)

        expect(response).to have_http_status(:forbidden)
      end

      it 'returns not found if course is not found' do
        get api_url.gsub(":id", "non-existent"), headers: user_headers

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'valid calls' do
      it 'successfully returns a course' do
        course = FactoryBot.create(:course)
        get api_url.gsub(":id", course.id), headers: user_headers

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
