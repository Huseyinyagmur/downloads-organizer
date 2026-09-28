require "minitest/autorun"
require_relative "../tidy_downloads"

class DownloadsOrganizerTest < Minitest::Test

  def test_pdf_is_document
    assert_equal "Documents", DownloadsOrganizer.categorize("example.pdf")
  end

  def test_word_is_document
    assert_equal "Documents", DownloadsOrganizer.categorize("example.docx")
  end

  def test_image_is_image
    assert_equal "Images", DownloadsOrganizer.categorize("photo.png")
  end

  def test_video_is_video
    assert_equal "Videos", DownloadsOrganizer.categorize("video.mp4")
  end

  def test_zip_is_archive
    assert_equal "Archives", DownloadsOrganizer.categorize("project.zip")
  end

  def test_python_file_is_code
    assert_equal "Code", DownloadsOrganizer.categorize("main.py")
  end

  def test_unknown_extension_is_other
    assert_equal "Other", DownloadsOrganizer.categorize("file.xyz")
  end

end