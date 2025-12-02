require 'rails_helper'

RSpec.describe 'Courses update' do
  include ApiHelpers
  include_context "authentication_context"

  let(:api_url) { '/courses/:id' }

  describe "PUT /courses/:id", type: :request do
    let(:course) { FactoryBot.create(:course) }

    context 'invalid calls' do
      it 'returns error if user is not logged in' do
        put api_url.gsub(":id", course.id)

        expect(response).to have_http_status(:forbidden)
      end

      it 'returns not found if course is not found' do
        put api_url.gsub(":id", "non-existent"), headers: user_headers

        expect(response).to have_http_status(:not_found)
      end

      it 'returns invalid if name is already taken' do
        conflicting_course = FactoryBot.create(:course)

        params = {
          name: conflicting_course.name
        }

        put api_url.gsub(":id", course.id), params: params, headers: user_headers

        payload = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_content)
        expect(payload['name'][0]).to eq('already taken')
      end

      it 'returns invalid if code is already taken' do
        conflicting_course = FactoryBot.create(:course)

        params = {
          code: conflicting_course.code
        }

        put api_url.gsub(":id", course.id), params: params, headers: user_headers

        payload = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_content)
        expect(payload['code'][0]).to eq('already taken')
      end
    end

    context 'valid calls' do
      it 'successfully updates a course' do
        params = {
          name: Faker::Educator.course_name,
          code: Faker::Alphanumeric.alphanumeric(number: 6).upcase
        }

        put api_url.gsub(":id", course.id), params: params, headers: user_headers

        course.reload

        expect(response).to have_http_status(:ok)
        expect(course.name).to eq(params[:name])
        expect(course.code).to eq(params[:code])
      end
    end
  end
end
