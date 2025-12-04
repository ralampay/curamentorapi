require 'digest'

module System
  class SendSqsPayload
    attr_reader :payload, :message_id, :message_group_id, :message_deduplication_id

    def initialize(payload:, message_group_id: 'publication-vectorization-group', message_deduplication_id: nil)
      @payload = payload
      @message_group_id = message_group_id
      @message_deduplication_id = message_deduplication_id || default_deduplication_id
    end

    def execute!
      raise "Missing AWS_SQS_VECTORIZE_QUEUE env variable" if ENV['AWS_SQS_VECTORIZE_QUEUE'].blank?

      response = sqs_client.send_message(
        queue_url: ENV['AWS_SQS_VECTORIZE_QUEUE'],
        message_body: @payload.to_json,
        message_group_id: message_group_id,
        message_deduplication_id: message_deduplication_id
      )

      @message_id = response.message_id

      Rails.logger.info("[SendSqsPayload]: Message sent successfully. MessageId: #{response.message_id}")
    end

    private

    def sqs_client
      @sqs_client ||= Aws::SQS::Client.new(sqs_config)
    end

    def sqs_config
      region            = ENV.fetch('AWS_REGION', 'ap-southeast-1')
      access_key_id     = ENV.fetch('AWS_ACCESS_KEY_ID', 'test')
      secret_access_key = ENV.fetch('AWS_SECRET_ACCESS_KEY', 'test')

      base = {
        region: region,
        credentials: Aws::Credentials.new(access_key_id, secret_access_key)
      }

      if Rails.env.development? || Rails.env.test?
        endpoint        = ENV.fetch('LOCALSTACK_URL', 'http://localhost:4566')
        base[:endpoint] = endpoint
      end

      base
    end

    def default_deduplication_id
      Digest::SHA256.hexdigest(payload.to_json)
    end
  end
end
