require 'rails_helper'

RSpec.describe 'Students index' do
  include ApiHelpers
  include_context "authentication_context"

  let(:api_url) { '/students' }

  describe "GET /students", type: :request do
    context 'invalid calls' do
      it 'returns error if user is not logged in' do
        get api_url

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'valid calls' do
      it 'successfully returns the student list' do
        FactoryBot.create(:student)

        get api_url, headers: user_headers

        expect(response).to have_http_status(:ok)
      end

      it 'filters students by query' do
        student = FactoryBot.create(:student, first_name: "Alice", last_name: "Smith")
        FactoryBot.create(:student, first_name: "Bob", last_name: "Jones")

        get api_url, params: { q: 'Alice' }, headers: user_headers

        expect(response).to have_http_status(:ok)
        payload = JSON.parse(response.body)

        expect(payload['records'].map { |r| r['id'] }).to eq([student.id])
      end
    end
  end
end
