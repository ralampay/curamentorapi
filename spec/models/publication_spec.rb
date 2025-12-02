require 'rails_helper'

RSpec.describe Publication, type: :model do
  include FileUploadHelper

  let(:valid_attributes) do
    {
      title: "Test Publication",
      date_published: Date.today
    }
  end

  describe 'file attachment validations' do
    it 'accepts PDF uploads' do
      publication = described_class.new(valid_attributes)
      publication.file.attach(upload_fixture("sample.pdf", 'application/pdf'))

      expect(publication).to be_valid
      expect(publication.errors).to be_empty
    end

    it 'rejects non-PDF uploads' do
      publication = described_class.new(valid_attributes)
      publication.file.attach(upload_fixture("sample.jpg", 'image/jpeg'))

      expect(publication).to be_invalid
      expect(publication.errors[:file]).to include('must be a PDF')
    end

    it 'rejects PNG uploads' do
      publication = described_class.new(valid_attributes)
      publication.file.attach(upload_fixture("sample.png", 'image/png'))

      expect(publication).to be_invalid
      expect(publication.errors[:file]).to include('must be a PDF')
    end

    it 'rejects files larger than 10MB' do
      publication = described_class.new(valid_attributes)
      large_io = StringIO.new('0' * (10.megabytes + 1))
      large_io.rewind

      publication.file.attach io: large_io, filename: 'too_big.pdf', content_type: 'application/pdf'

      expect(publication).to be_invalid
      expect(publication.errors[:file]).to include('is too big (maximum is 10 MB)')
    end
  end
end
