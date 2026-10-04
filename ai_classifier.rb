require "net/http"
require "json"
require "uri"
require "dotenv/load"

module AiClassifier
  def self.classify_files(query, files_info)
    api_key = ENV["GEMINI_API_KEY"]
    unless api_key && !api_key.empty?
      puts "Hata: GEMINI_API_KEY environment variable is not set."
      return nil
    end

    return [] if files_info.empty?

    query_utf8 = query.to_s.encode("UTF-8", invalid: :replace, undef: :replace, replace: "")

    # Prepare files summary to send to AI
    files_payload = files_info.map.with_index do |info, index|
      {
        id: index,
        file_name: info[:file_name].to_s.encode("UTF-8", invalid: :replace, undef: :replace, replace: ""),
        extension: info[:extension].to_s.encode("UTF-8", invalid: :replace, undef: :replace, replace: ""),
        content_preview: info[:content_preview].to_s.encode("UTF-8", invalid: :replace, undef: :replace, replace: "")
      }
    end

    prompt = <<~PROMPT
      You are an AI file organizer. The user is searching for files related to: "#{query_utf8}"

      Here is a list of files with their names, extensions, and content previews.
      Determine which files are relevant to the user's query.

      Files:
      #{JSON.generate(files_payload)}

      You must return ONLY a JSON object in the following format, with no extra text or markdown code blocks:
      {
        "results": [
          {
            "id": 0,
            "file": "example.pdf",
            "relevant": true,
            "reason": "Short reason in Turkish explaining why it's relevant or not",
            "confidence": 0.95
          }
        ]
      }
    PROMPT

    uri = URI("https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=#{api_key}")
    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"

    body = {
      contents: [
        {
          parts: [
            { text: prompt }
          ]
        }
      ],
      generationConfig: {
        responseMimeType: "application/json",
        temperature: 0.1
      }
    }

    request.body = JSON.generate(body)

    begin
      http = Net::HTTP.new(uri.hostname, uri.port)
      http.use_ssl = true
      response = http.request(request)

      if response.is_a?(Net::HTTPSuccess)
        parsed_response = JSON.parse(response.body)
        content = parsed_response.dig("candidates", 0, "content", "parts", 0, "text")
        return JSON.parse(content)["results"]
      else
        puts "API Hatası: #{response.code} - #{response.message}"
        puts response.body
        return nil
      end
    rescue => e
      puts "API Bağlantı Hatası: #{e.message}"
      return nil
    end
  end
end
