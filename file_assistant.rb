require "fileutils"
require_relative "file_reader"
require_relative "ai_classifier"

module FileAssistant
  LOG_DIR = File.join(__dir__, "logs")
  LOG_FILE = File.join(LOG_DIR, "organizer.log")

  def self.log_search(query, scanned_count, matched_count)
    FileUtils.mkdir_p(LOG_DIR)
    timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    File.open(LOG_FILE, "a") do |file|
      file.puts("#{timestamp} | AI_SEARCH | query=\"#{query}\" | scanned=#{scanned_count} | matched=#{matched_count}")
    end
  end

  def self.unique_destination(path)
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

  def self.run
    if ARGV[0] != "search" || ARGV[1].nil? || ARGV[1].empty?
      puts "Kullanım: ruby file_assistant.rb search \"<arama sorgusu>\" [--dry-run]"
      return
    end

    query = ARGV[1]
    is_dry_run = ARGV.include?("--dry-run")

    puts "Enter folder to search:"
    search_dir = $stdin.gets&.chomp || ""

    # Expand ~ if used
    search_dir = File.expand_path(search_dir)

    unless Dir.exist?(search_dir)
      puts "Hata: #{search_dir} klasörü bulunamadı."
      return
    end

    puts "\nDosyalar taranıyor..."
    files_info = FileReader.read_files(search_dir)

    if files_info.empty?
      puts "Klasörde dosya bulunamadı."
      return
    end

    puts "AI analizi yapılıyor... (Bu işlem biraz zaman alabilir)"
    results = AiClassifier.classify_files(query, files_info)

    if results.nil?
      return # Hata mesajı ai_classifier içinde yazdırıldı
    end

    matched_files = []
    matched_results = []

    results.each do |result|
      # id eşleştirmesi yapıp orjinal dosya bilgisini buluyoruz
      original_info = files_info.find { |f| f[:file_name] == result["file"] } || files_info[result["id"]]
      next unless original_info

      if result["relevant"] || result["relevant"].to_s.downcase == "true"
        matched_files << original_info
        matched_results << { info: original_info, result: result }
      end
    end

    puts "\n========================================"
    puts "AI FILE SEARCH"
    puts "========================================"
    puts "Query:\n\"#{query}\"\n"
    puts "\n#{files_info.length} dosya incelendi, #{matched_files.length} ilgili dosya bulundu.\n\n"

    if matched_results.any?
      puts "Found files:\n\n"
      matched_results.each_with_index do |item, index|
        puts "[#{index + 1}] #{item[:info][:file_name]}"
        puts "Reason:\n\"#{item[:result]["reason"]}\"\n\n"
      end
    end

    log_search(query, files_info.length, matched_files.length)

    if matched_files.empty?
      puts "İlgili dosya bulunamadı."
      return
    end

    if is_dry_run
      puts "========================================"
      puts "DRY RUN"
      puts "========================================"
      puts "\nHiçbir dosya taşınmayacak.\n"
      return
    end

    puts "#{matched_files.length} related files found."
    puts "\nEnter destination folder to move these files to:"
    dest_dir = $stdin.gets&.chomp || ""
    dest_dir = File.expand_path(dest_dir)

    puts "\nMove these files to:"
    puts dest_dir
    print "[y/n]: "
    
    answer = ($stdin.gets&.chomp || "").downcase
    if answer == "y"
      FileUtils.mkdir_p(dest_dir)
      moved_count = 0
      error_count = 0

      matched_files.each do |file_info|
        source = file_info[:path]
        destination = File.join(dest_dir, file_info[:file_name])
        destination = unique_destination(destination)

        begin
          FileUtils.mv(source, destination)
          moved_count += 1
          puts "Taşındı: #{file_info[:file_name]} -> #{destination}"
        rescue StandardError => e
          error_count += 1
          puts "Hata: #{file_info[:file_name]}"
          puts "  #{e.message}"
        end
      end
      
      puts "\nİşlem tamamlandı. #{moved_count} dosya taşındı, #{error_count} hata."
    else
      puts "\nİşlem iptal edildi. Hiçbir dosya taşınmadı."
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  FileAssistant.run
end
