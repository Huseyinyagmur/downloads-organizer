require 'sinatra'
require 'fileutils'
require_relative 'file_reader'
require_relative 'ai_classifier'
require_relative 'folder_picker'
require 'json'
require 'dotenv/load'

# ERB escape utils
helpers do
  def html_escape(text)
    Rack::Utils.escape_html(text)
  end

  def get_file_icon(filename)
    ext = File.extname(filename.to_s).downcase
    case ext
    when '.pdf' then '📕'
    when '.txt' then '📄'
    when '.docx', '.doc' then '📝'
    when '.csv', '.xlsx', '.xls' then '📊'
    when '.png', '.jpg', '.jpeg', '.gif', '.svg' then '🖼️'
    when '.zip', '.rar', '.tar', '.gz' then '📦'
    when '.py', '.rb', '.js', '.html', '.css', '.json' then '💻'
    else '📄'
    end
  end
end

def log_web_search(query, scanned_count, matched_count)
  log_dir = File.join(__dir__, "logs")
  FileUtils.mkdir_p(log_dir)
  log_file = File.join(log_dir, "organizer.log")
  timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")
  File.open(log_file, "a") do |file|
    file.puts("#{timestamp} | WEB_SEARCH | Query: #{query} | #{scanned_count} dosya incelendi | #{matched_count} ilgili")
  end
end

def log_web_move(file_name, dest_folder)
  log_dir = File.join(__dir__, "logs")
  FileUtils.mkdir_p(log_dir)
  log_file = File.join(log_dir, "organizer.log")
  timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")
  File.open(log_file, "a") do |file|
    file.puts("#{timestamp} | WEB_MOVE | #{file_name} -> #{dest_folder}")
  end
end

def unique_destination(path)
  return path unless File.exist?(path)

  directory = File.dirname(path)
  extension = File.extname(path)
  name = File.basename(path, extension)

  counter = 1
  loop do
    new_name = "#{name}_#{counter}#{extension}"
    new_path = File.join(directory, new_name)
    return new_path unless File.exist?(new_path)
    counter += 1
  end
end

get '/' do
  erb :index
end

get '/api/browse-folder' do
  content_type :json
  path = FolderPicker.browse
  
  if path
    { success: true, path: path }.to_json
  else
    if RUBY_PLATFORM =~ /mswin|mingw|cygwin/
      { success: false, error: 'canceled' }.to_json
    else
      { success: false, error: 'not_supported' }.to_json
    end
  end
end

post '/search' do
  @folder = params[:folder].to_s.strip
  @query = params[:query].to_s.strip

  unless Dir.exist?(@folder)
    @error = "Hata: Klasör bulunamadı veya erişilemiyor (#{@folder})"
    return erb :index
  end

  files_info = FileReader.read_files(@folder)

  if files_info.empty?
    @error = "Klasörde dosya bulunamadı."
    return erb :index
  end

  # Check API Key before trying
  api_key = ENV["GEMINI_API_KEY"]
  unless api_key && !api_key.empty?
    @error = "Gemini API key bulunamadı. GEMINI_API_KEY environment variable tanımlayın."
    return erb :index
  end

  begin
    raw_results = AiClassifier.classify_files(@query, files_info)
    
    if raw_results.nil?
      @error = "Gemini API hatası oluştu. Lütfen logları kontrol edin."
      return erb :index
    end

    @total_scanned = files_info.length
    @results = []

    raw_results.each do |result|
      original_info = files_info.find { |f| f[:file_name] == result["file"] } || files_info[result["id"]]
      next unless original_info

      if result["relevant"] || result["relevant"].to_s.downcase == "true"
        @results << { info: original_info, result: result }
      end
    end

    log_web_search(@query, @total_scanned, @results.length)
  rescue => e
    @error = "Bir hata oluştu: #{e.message}"
  end

  erb :index
end

post '/move' do
  source_path = params[:source_path].to_s
  dest_folder = params[:dest_folder].to_s
  file_name = params[:file_name].to_s

  unless File.exist?(source_path)
    @error = "Kaynak dosya bulunamadı: #{source_path}"
    return erb :index
  end

  begin
    FileUtils.mkdir_p(dest_folder)
    destination = File.join(dest_folder, file_name)
    destination = unique_destination(destination)

    FileUtils.mv(source_path, destination)
    
    log_web_move(file_name, File.basename(dest_folder))
    
    @success = "Dosya başarıyla taşındı: #{File.basename(destination)}"
  rescue => e
    @error = "Dosya taşıma hatası: #{e.message}"
  end

  erb :index
end
