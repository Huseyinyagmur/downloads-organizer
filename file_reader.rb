require "fileutils"

module FileReader
  # Sadece bu uzantılara sahip dosyaların içeriği okunacak
  TEXT_EXTENSIONS = %w[.txt .md .csv .json .rb .py .js .ts]
  MAX_FILE_SIZE_FOR_TEXT = 100 * 1024 # 100 KB
  MAX_CHARACTERS = 2000

  def self.read_files(directory)
    unless Dir.exist?(directory)
      puts "Hata: #{directory} klasörü bulunamadı."
      return []
    end

    files_info = []

    Dir.children(directory).each do |item|
      path = File.join(directory, item)
      next unless File.file?(path)

      ext = File.extname(path).downcase
      content = "content unavailable"

      if TEXT_EXTENSIONS.include?(ext) && File.size(path) <= MAX_FILE_SIZE_FOR_TEXT
        begin
          raw_text = File.read(path, mode: "rb")
          text = raw_text.force_encoding("UTF-8")
          unless text.valid_encoding?
            text = raw_text.force_encoding("Windows-1254").encode("UTF-8", invalid: :replace, undef: :replace, replace: "")
          end
          
          text = text.to_s.encode("UTF-8", invalid: :replace, undef: :replace, replace: "")
          content = text[0...MAX_CHARACTERS]
        rescue => e
          content = "error reading content: #{e.message}"
        end
      elsif File.size(path) > MAX_FILE_SIZE_FOR_TEXT
        content = "content too large to read"
      end

      files_info << {
        file_name: item,
        extension: ext,
        path: path,
        content_preview: content
      }
    end

    files_info
  end
end
