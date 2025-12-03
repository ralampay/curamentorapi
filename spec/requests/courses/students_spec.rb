require 'rails_helper'

RSpec.describe 'Courses students' do
  include ApiHelpers
  include_context "authentication_context"

  let(:course) { FactoryBot.create(:course) }
  let(:api_url) { "/courses/#{course.id}/students" }

  describe "GET /courses/:id/students", type: :request do
    context 'invalid calls' do
      it 'requires authentication' do
        get api_url

        expect(response).to have_http_status(:forbidden)
      end

      it 'returns not found for missing course' do
        get "/courses/non-existent/students", headers: user_headers

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'valid calls' do
      it 'returns students of the course' do
        student = FactoryBot.create(:student, course: course)
        FactoryBot.create(:student)

        get api_url, headers: user_headers

        expect(response).to have_http_status(:ok)
        payload = JSON.parse(response.body)

        expect(payload).to be_an(Array)
        expect(payload.map { |r| r['id'] }).to contain_exactly(student.id)
      end
    end
  end
end
