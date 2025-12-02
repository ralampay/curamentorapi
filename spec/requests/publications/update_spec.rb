require 'rails_helper'

RSpec.describe 'Publications update' do
  include ApiHelpers
  include_context "authentication_context"
  include FileUploadHelper

  let(:api_url) { '/publications/:id' }
  let(:publication) { FactoryBot.create(:publication) }

  describe "PUT /publications/:id", type: :request do
    context 'invalid calls' do
      it 'returns error if user is not logged in' do
        put api_url.gsub(":id", publication.id)

        expect(response).to have_http_status(:forbidden)
      end

      it 'returns not found if publication is not found' do
        put api_url.gsub(":id", "non-existent"), headers: user_headers

        expect(response).to have_http_status(:not_found)
      end

      it 'returns error for invalid file type' do
        params = {
          file: upload_fixture("sample.jpg", "image/jpeg")
        }

        put api_url.gsub(":id", publication.id), params: params, headers: user_headers

        payload = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_content)
        expect(payload['file']).to include('must be a PDF')
      end
    end

    context 'valid calls' do
      it 'successfully updates a publication and file' do
        params = {
          title: "Updated Title",
          date_published: Date.yesterday,
          file: upload_fixture("sample.pdf", "application/pdf")
        }

        put api_url.gsub(":id", publication.id), params: params, headers: user_headers

        publication.reload

        expect(response).to have_http_status(:ok)
        expect(publication.title).to eq(params[:title])
        expect(publication.date_published).to eq(params[:date_published])
        expect(publication.file.attached?).to be_truthy
      end
    end
  end
end
