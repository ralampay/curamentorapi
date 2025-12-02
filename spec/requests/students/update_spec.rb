require 'rails_helper'

RSpec.describe 'Students update' do
  include ApiHelpers
  include_context "authentication_context"

  let(:api_url) { '/students/:id' }
  let(:student) { FactoryBot.create(:student) }

  describe "PUT /students/:id", type: :request do
    context 'invalid calls' do
      it 'returns error if user is not logged in' do
        put api_url.gsub(":id", student.id)

        expect(response).to have_http_status(:forbidden)
      end

      it 'returns not found if student is not found' do
        put api_url.gsub(":id", "non-existent"), headers: user_headers

        expect(response).to have_http_status(:not_found)
      end

      it 'returns invalid if email is already taken' do
        conflicting_student = FactoryBot.create(:student)

        params = {
          email: conflicting_student.email
        }

        put api_url.gsub(":id", student.id), params: params, headers: user_headers

        payload = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_content)
        expect(payload['email'][0]).to eq('already taken')
      end
    end

    context 'valid calls' do
      it 'successfully updates a student' do
        params = {
          first_name: Faker::Name.first_name,
          email: Faker::Internet.unique.email
        }

        put api_url.gsub(":id", student.id), params: params, headers: user_headers

        student.reload

        expect(response).to have_http_status(:ok)
        expect(student.first_name).to eq(params[:first_name])
        expect(student.email).to eq(params[:email])
      end
    end
  end
end
