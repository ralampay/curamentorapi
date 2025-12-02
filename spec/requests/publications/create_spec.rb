require 'rails_helper'

RSpec.describe 'Publications create' do
  include ApiHelpers
  include_context "authentication_context"
  include FileUploadHelper

  let(:api_url) { '/publications' }

  describe "POST /publications", type: :request do
    context 'invalid calls' do
      it 'returns error if user is not logged in' do
        post api_url

        expect(response).to have_http_status(:forbidden)
      end

      it 'returns error for missing values' do
        post api_url, headers: user_headers

        payload = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_content)
        expect(payload['title']).to eq(['required'])
        expect(payload['date_published']).to eq(['required'])
      end

      it 'returns error for invalid file type' do
        params = {
          title: Faker::Book.title,
          date_published: Date.today,
          file: upload_fixture("sample.jpg", "image/jpeg")
        }

        post api_url, params: params, headers: user_headers

        payload = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_content)
        expect(payload['file']).to include('must be a PDF')
      end
    end

    context 'valid calls' do
      it 'successfully creates a publication with PDF file' do
        params = {
          title: Faker::Book.title,
          date_published: Date.today,
          file: upload_fixture("sample.pdf", "application/pdf")
        }

        post api_url, params: params, headers: user_headers

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
