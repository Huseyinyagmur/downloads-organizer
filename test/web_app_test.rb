ENV['APP_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require_relative '../web_app'

class WebAppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_get_root_returns_200_and_shows_form
    get '/'
    assert_predicate last_response, :ok?
    assert_match(/AI File Assistant/, last_response.body)
    assert_match(/What are you looking for/, last_response.body)
  end

  def test_search_without_folder_returns_error
    post '/search', folder: 'non_existent_folder_123', query: 'test'
    assert_predicate last_response, :ok?
    assert_match(/Hata: Klasör bulunamadı veya erişilemiyor/, last_response.body)
  end

  def test_search_without_api_key_returns_error
    # Setup
    test_dir = File.join(__dir__, "test_data_web")
    FileUtils.mkdir_p(test_dir)
    File.write(File.join(test_dir, "test.txt"), "hello")

    original_api_key = ENV["GEMINI_API_KEY"]
    ENV["GEMINI_API_KEY"] = nil

    begin
      post '/search', folder: test_dir, query: 'test'
      assert_predicate last_response, :ok?
      assert_match(/GEMINI_API_KEY environment variable tanımlayın/, last_response.body)
    ensure
      ENV["GEMINI_API_KEY"] = original_api_key
      FileUtils.rm_rf(test_dir)
    end
  end

  def test_search_with_mocked_ai
    test_dir = File.join(__dir__, "test_data_web_ai")
    FileUtils.mkdir_p(test_dir)
    File.write(File.join(test_dir, "test.txt"), "hello")

    original_api_key = ENV["GEMINI_API_KEY"]
    ENV["GEMINI_API_KEY"] = "fake_key"

    mock_results = [
      { "id" => 0, "file" => "test.txt", "relevant" => true, "reason" => "Because test." }
    ]

    begin
      AiClassifier.stub :classify_files, mock_results do
        post '/search', folder: test_dir, query: 'find test'
        assert_predicate last_response, :ok?
        assert_match(/Relevant<br>files/, last_response.body)
        assert_match(/Because test\./, last_response.body)
      end
    ensure
      ENV["GEMINI_API_KEY"] = original_api_key
      FileUtils.rm_rf(test_dir)
    end
  end
end
