require 'rails_helper'

RSpec.describe 'Courses delete' do
  include ApiHelpers
  include_context "authentication_context"

  let(:api_url) { '/courses/:id' }
  let(:course) { FactoryBot.create(:course) }

  describe "DELETE /courses/:id", type: :request do
    context 'invalid calls' do
      it 'returns error if user is not logged in' do
        delete api_url.gsub(":id", course.id)

        expect(response).to have_http_status(:forbidden)
      end

      it 'returns not found if course is not found' do
        delete api_url.gsub(":id", "non-existent"), headers: user_headers

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'valid calls' do
      it 'successfully deletes a course' do
        delete api_url.gsub(":id", course.id), headers: user_headers

        expect(response).to have_http_status(:ok)
        expect(Course.exists?(course.id)).to be_falsey
      end
    end
  end
end
