require "minitest/autorun"
require_relative "../file_reader"
require_relative "../ai_classifier"

class FileAssistantTest < Minitest::Test

  def setup
    @test_dir = File.join(__dir__, "test_data")
    FileUtils.mkdir_p(@test_dir)
  end

  def teardown
    FileUtils.rm_rf(@test_dir) if Dir.exist?(@test_dir)
  end

  def test_text_extraction
    test_file = File.join(@test_dir, "test.txt")
    File.write(test_file, "Bu bir test dosyasidir.")

    files = FileReader.read_files(@test_dir)
    assert_equal 1, files.length
    assert_equal "Bu bir test dosyasidir.", files.first[:content_preview]
  end

  def test_unsupported_extension_extraction
    test_file = File.join(@test_dir, "test.unknown")
    File.write(test_file, "gizli icerik")

    files = FileReader.read_files(@test_dir)
    assert_equal 1, files.length
    assert_equal "content unavailable", files.first[:content_preview]
  end

  def test_large_file_handling
    test_file = File.join(@test_dir, "large.txt")
    # Simulate a file larger than MAX_FILE_SIZE_FOR_TEXT (100KB)
    # We will just stub the size method to avoid creating a real large file
    File.write(test_file, "kisa metin ama buyuk dosya gibi davranacak")
    
    File.stub :size, 150 * 1024 do
      files = FileReader.read_files(@test_dir)
      assert_equal "content too large to read", files.first[:content_preview]
    end
  end

  def test_ai_classifier_parsing_success
    mock_response = Minitest::Mock.new
    mock_response.expect :is_a?, true, [Net::HTTPSuccess]
    mock_response.expect :body, {
      "candidates" => [
        {
          "content" => {
            "parts" => [
              {
                "text" => {
                  "results" => [
                    { "id" => 0, "file" => "test.txt", "relevant" => true, "reason" => "relevant reason", "confidence" => 0.9 }
                  ]
                }.to_json
              }
            ]
          }
        }
      ]
    }.to_json

    mock_http = Minitest::Mock.new
    mock_http.expect :use_ssl=, true, [true]
    mock_http.expect :request, mock_response, [Net::HTTP::Post]

    Net::HTTP.stub :new, mock_http do
      ENV["GEMINI_API_KEY"] = "fake_key"
      files_info = [{ file_name: "test.txt", extension: ".txt", content_preview: "test", path: "test.txt" }]
      
      results = AiClassifier.classify_files("query", files_info)
      
      assert_equal 1, results.length
      assert_equal true, results.first["relevant"]
      assert_equal "test.txt", results.first["file"]
    end
    
    mock_http.verify
    mock_response.verify
  end

  def test_ai_classifier_missing_api_key
    ENV["GEMINI_API_KEY"] = nil
    files_info = [{ file_name: "test.txt", extension: ".txt", content_preview: "test", path: "test.txt" }]
    
    assert_output(/Hata: GEMINI_API_KEY environment variable is not set\./) do
      results = AiClassifier.classify_files("query", files_info)
      assert_nil results
    end
  end

  def test_json_generator_encoding
    # Simulate a malformed string or Turkish string that could cause JSON::GeneratorError
    # We will pass a string encoded in Windows-1254 to test the resilience, or just standard string.
    # The prompt asked for: "Bu dosya bilgisayarlı görü, YOLO ve derin öğrenme kullanılarak geliştirilecek bitirme projesi ile ilgili notları içermektedir."
    content = "Bu dosya bilgisayarlı görü, YOLO ve derin öğrenme kullanılarak geliştirilecek bitirme projesi ile ilgili notları içermektedir."
    
    # Intentionally malformed or just using the string
    malformed_content = content.encode("Windows-1254").force_encoding("UTF-8")

    files_info = [{ 
      file_name: "bitirme_notu.txt", 
      extension: ".txt", 
      content_preview: malformed_content, 
      path: "bitirme_notu.txt" 
    }]
    
    ENV["GEMINI_API_KEY"] = "fake_key"
    
    # We only care that JSON.generate(body) inside AiClassifier.classify_files doesn't throw JSON::GeneratorError.
    # We'll mock the HTTP request to just return empty or fail gracefully to avoid actual network call.
    mock_http = Minitest::Mock.new
    mock_http.expect :use_ssl=, true, [true]
    
    # We don't care about the response much, just that we reach the request part without crashing in JSON.generate
    mock_response = Minitest::Mock.new
    mock_response.expect :is_a?, false, [Net::HTTPSuccess]
    mock_response.expect :code, "500"
    mock_response.expect :message, "Internal Error"
    mock_response.expect :body, "{}"

    mock_http.expect :request, mock_response, [Net::HTTP::Post]

    # Silence output for this test
    $stdout = StringIO.new
    begin
      Net::HTTP.stub :new, mock_http do
        # If this raises JSON::GeneratorError, the test will fail
        AiClassifier.classify_files("query", files_info)
      end
    ensure
      $stdout = STDOUT
    end
    
    # If we got here, no JSON::GeneratorError was raised
    assert true
  end

  def test_cli_filters_irrelevant_files
    # Mocking AiClassifier and FileReader to test FileAssistant.run
    files_info = [
      { file_name: "bitirme_notu.txt", extension: ".txt", content_preview: "test", path: "bitirme_notu.txt" },
      { file_name: "market_listesi.txt", extension: ".txt", content_preview: "test", path: "market_listesi.txt" }
    ]

    mock_results = [
      { "id" => 0, "file" => "bitirme_notu.txt", "relevant" => true, "reason" => "relevant reason" },
      { "id" => 1, "file" => "market_listesi.txt", "relevant" => false, "reason" => "irrelevant reason" }
    ]

    ARGV.clear
    ARGV << "search" << "bitirme projesi" << "--dry-run"

    # We need to simulate user input for folder
    original_stdin = $stdin
    $stdin = StringIO.new("C:\\AI-Test\n")

    out = StringIO.new
    $stdout = out

    begin
      FileReader.stub :read_files, files_info do
        AiClassifier.stub :classify_files, mock_results do
          FileAssistant.run
        end
      end
    ensure
      $stdin = original_stdin
      $stdout = STDOUT
      ARGV.clear
    end

    output = out.string
    assert_match(/1 ilgili dosya bulundu/, output)
    assert_match(/bitirme_notu\.txt/, output)
    refute_match(/\[2\] market_listesi\.txt/, output)
    assert_match(/Reason:\n"relevant reason"/, output)
  end
end
