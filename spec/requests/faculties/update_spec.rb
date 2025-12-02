require 'rails_helper'

RSpec.describe 'Faculties update' do
  include ApiHelpers
  include_context "authentication_context"

  let(:api_url) { '/faculties/:id' }

  describe "PUT /faculties/:id", type: :request do
    let(:faculty) { FactoryBot.create(:faculty) }

    context 'invalid calls' do
      it 'returns error if user is not logged in' do
        put api_url.gsub(":id", faculty.id)

        expect(response).to have_http_status(:forbidden)
      end

      it 'returns not found if faculty is not found' do
        put api_url.gsub(":id", "non-existent"), headers: user_headers

        expect(response).to have_http_status(:not_found)
      end

      it 'returns invalid if id number is already taken' do
        conflicting_faculty = FactoryBot.create(:faculty)

        params = {
          id_number: conflicting_faculty.id_number
        }

        put api_url.gsub(":id", faculty.id), params: params, headers: user_headers

        payload = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_content)
        expect(payload['id_number'][0]).to eq('already taken')
      end
    end

    context 'valid calls' do
      it 'successfully updates a faculty' do
        params = {
          first_name: Faker::Name.first_name,
          middle_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          id_number: Faker::Number.number(digits: 6).to_s
        }

        put api_url.gsub(":id", faculty.id), params: params, headers: user_headers

        faculty.reload

        expect(response).to have_http_status(:ok)
        expect(faculty.first_name).to eq(params[:first_name])
        expect(faculty.middle_name).to eq(params[:middle_name])
        expect(faculty.last_name).to eq(params[:last_name])
        expect(faculty.id_number).to eq(params[:id_number])
      end
    end
  end
end
