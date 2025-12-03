require 'rails_helper'
require 'ostruct'
require 'aws-sdk-sqs'

RSpec.describe 'Publications vectorize' do
  include ApiHelpers
  include_context "authentication_context"

  let(:publication) { FactoryBot.create(:publication) }
  let(:api_url) { "/publications/#{publication.id}/vectorize" }

  describe "POST /publications/:id/vectorize", type: :request do
    context 'invalid calls' do
      it 'returns error if user is not logged in' do
        post api_url

        expect(response).to have_http_status(:forbidden)
      end

      it 'returns not found if publication is missing' do
        post "/publications/non-existent/vectorize", headers: user_headers

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'valid calls' do
      let(:sent_body) { [] }
      let(:queue_url) { 'https://sqs.local/test' }
      let(:aws_client) { instance_double(Aws::SQS::Client) }

      before do
        @original_queue = ENV['AWS_SQS_VECTORIZE_QUEUE']
        ENV['AWS_SQS_VECTORIZE_QUEUE'] = queue_url
        allow(Aws::SQS::Client).to receive(:new).and_return(aws_client)
        allow(aws_client).to receive(:send_message) do |**opts|
          sent_body << opts[:message_body]
          OpenStruct.new(message_id: 'msg-123')
        end
      end

      after do
        ENV['AWS_SQS_VECTORIZE_QUEUE'] = @original_queue
      end

      it 'queues a vectorization job' do
        post api_url, headers: user_headers

        expect(response).to have_http_status(:ok)
        payload = JSON.parse(sent_body.last)

        expect(payload['publication_id']).to eq(publication.id)
        expect(payload['title']).to eq(publication.title)
        expect(JSON.parse(response.body)['message_id']).to eq('msg-123')
      end
    end
  end
end
