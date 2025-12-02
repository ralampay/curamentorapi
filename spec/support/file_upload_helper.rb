module FileUploadHelper
  include ActionDispatch::TestProcess::FixtureFile

  def upload_fixture(filename, content_type)
    fixture_file_upload(Rails.root.join("spec", "fixtures", "files", filename), content_type)
  end
end
