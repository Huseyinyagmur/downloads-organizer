require "fileutils"
require "time"

DOWNLOADS_PATH = File.join(Dir.home, "Downloads")
LOG_DIR = File.join(__dir__, "logs")
LOG_FILE = File.join(LOG_DIR, "organizer.log")

CATEGORIES = {
  "Documents" => %w[.pdf .doc .docx .txt],
  "Images" => %w[.png .jpg .jpeg .webp .gif],
  "Videos" => %w[.mp4 .mkv .avi .mov],
  "Archives" => %w[.zip .rar .7z],
  "Spreadsheets" => %w[.xlsx .xls],
  "Presentations" => %w[.ppt .pptx],
  "Code" => %w[.rb .py .js .ts .ipynb],
  "Datasets" => %w[.csv .json],
  "Installers" => %w[.exe .msi],
  "Models" => %w[.pt .pth],
  "Network" => %w[.pka .pkt],
  "Project" => %w[.drawio]
}

def categorize(file_name)
  extension = File.extname(file_name).downcase

  CATEGORIES.each do |category, extensions|
    return category if extensions.include?(extension)
  end

  "Other"
end

def write_log(message)
  FileUtils.mkdir_p(LOG_DIR)

  timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")

  File.open(LOG_FILE, "a") do |file|
    file.puts("#{timestamp} | #{message}")
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

unless Dir.exist?(DOWNLOADS_PATH)
  puts "Hata: Downloads klasörü bulunamadı."
  write_log("FAILED | Downloads klasörü bulunamadı")
  exit 1
end

files = Dir.children(DOWNLOADS_PATH).select do |item|
  File.file?(File.join(DOWNLOADS_PATH, item))
end

categorized_files = Hash.new { |hash, key| hash[key] = [] }

files.each do |file|
  category = categorize(file)
  categorized_files[category] << file
end

puts
puts "========================================"
puts "       DOWNLOADS ORGANIZER"
puts "========================================"
puts
puts "Downloads klasörü:"
puts DOWNLOADS_PATH
puts
puts "Toplam dosya: #{files.length}"
puts

categorized_files.each do |category, category_files|
  puts "#{category}: #{category_files.length}"

  category_files.each do |file|
    puts "  - #{file}"
  end

  puts
end

if ARGV.include?("--dry-run")
  puts "========================================"
  puts "DRY RUN"
  puts "========================================"
  puts
  puts "Hiçbir dosya taşınmayacak."
  puts

  categorized_files.each do |category, category_files|
    category_files.each do |file|
      destination_dir = File.join(DOWNLOADS_PATH, category)
      destination = File.join(destination_dir, file)

      puts "#{file}"
      puts "  -> #{category}/#{file}"
    end
  end

  write_log("SUCCESS | Dry run | #{files.length} dosya analiz edildi")

  puts
  puts "Dry run tamamlandı."
  exit
end

puts "========================================"
puts "DOSYA TAŞIMA"
puts "========================================"
puts

print "Dosyalar kategorilerine göre taşınsın mı? [y/n]: "
answer = gets.chomp.downcase

unless answer == "y"
  puts
  puts "İşlem iptal edildi."
  write_log("CANCELLED | Kullanıcı işlemi iptal etti")
  exit
end

moved_count = 0
error_count = 0

categorized_files.each do |category, category_files|
  destination_dir = File.join(DOWNLOADS_PATH, category)

  FileUtils.mkdir_p(destination_dir)

  category_files.each do |file|
    source = File.join(DOWNLOADS_PATH, file)
    destination = File.join(destination_dir, file)

    destination = unique_destination(destination)

    begin
      FileUtils.mv(source, destination)
      moved_count += 1

      puts "Taşındı: #{file} -> #{category}/#{File.basename(destination)}"
    rescue StandardError => e
      error_count += 1

      puts "Hata: #{file}"
      puts "  #{e.message}"
    end
  end
end

puts
puts "========================================"
puts "İŞLEM TAMAMLANDI"
puts "========================================"
puts
puts "Taşınan dosya: #{moved_count}"
puts "Hatalı işlem: #{error_count}"
puts

if error_count == 0
  write_log("SUCCESS | #{moved_count} dosya taşındı")
else
  write_log("PARTIAL | #{moved_count} dosya taşındı | #{error_count} hata")
end

puts "Log: #{LOG_FILE}"