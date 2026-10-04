# Downloads Organizer

Downloads Organizer, Windows'taki Downloads klasöründe biriken dosyaları dosya uzantılarına göre otomatik olarak kategorilere ayıran, AI desteği ile doğal dilde arama yapabilen küçük bir Ruby CLI ve Web aracıdır.

Proje artık iki şekilde kullanılabiliyor:
1. CLI
2. Sinatra Web Interface

**Web Teknolojileri:**
- Ruby
- Sinatra 4.x
- Puma
- Rackup
- ERB
- Vanilla CSS
- Gemini API

## 1. Problem
Downloads klasörümde farklı türlerde dosyalar birikiyor ve belirli aralıklarla bunları manuel olarak kategorilere ayırmam gerekiyor. Ayrıca "bitirme projemle ilgili dosyalar", "staj belgeleri" gibi belirli bir amaca hizmet eden dosyaları, sadece isimlerine bakarak bulmak zorlaşıyor ve içeriklerini tek tek kontrol etmek zaman kaybettiriyor.

## 2. Pain Diary

| Tarih | Yapılan işlem | Harcanan süre | Kanıt |
|---|---|---:|---|
| 25.09.2026 | Downloads dosyalarının türlerine göre düzenlenmesi | 4 dk | Ekran görüntüsü |
| 26.09.2026 | PDF, ZIP ve dokümanların ayrılması | 7 dk | Ekran görüntüsü |
| 27.09.2026 | Dosyaların kategorilere ayrılması ve gereksiz dosyaların temizlenmesi | 5 dk | Ekran görüntüsü |

**Toplam:** 16 dakika
**Tekrarlanma:** 3 kez / 3 gün
**Ortalama:** 5,3 dakika / işlem

## 3. Mevcut Manuel Çözüm
Manuel çözümde kullanıcı, dosya gezgininde klasörleri tek tek dolaşarak ve belgeleri teker teker açarak içerik kontrolü yapmaktadır. PDF, Word, dosya tiplerini gözle kontrol etmek ve sonrasında manuel taşıma işlemi yorucu ve uzun sürmektedir.

## 4. Projenin Amacı
Bu projenin amacı, "tekrarlayan dosya düzenleme/bulma problemini kendi hayatımda azaltan küçük bir araç geliştirmek"tir. Bu yüzden aşırı mimari (Docker, veritabanı, microservices vb.) sistemler eklenmemiş, proje CLI aracı olarak kalmıştır.

## 5. Normal Organizer Özelliği
Downloads Organizer'ın temel yeteneği, Downloads klasöründeki dosyaları uzantılarına göre otomatik olarak kategorilere ayırmaktır: Documents, Images, Videos, Archives vb. Bu modda sadece Downloads klasöründe çalışır. `--dry-run` desteği ile test edilebilir.

## 6. AI File Search Özelliği
Bu özellik sayesinde sistem sadece bir organizer olmaktan çıkarak AI destekli bir kişisel dosya bulma ve düzenleme aracına dönüştü. "Bitirme projesiyle ilgili dosyaları bul" veya "CV hazırlarken kullanabileceğim projelerimi bul" gibi doğal dilde sorgular yapabilirsiniz. Program, belirttiğiniz klasördeki metin tabanlı (txt, md, csv, rb vb.) dosyaların içeriğini, dosya adlarını ve uzantılarını bir AI API'si ile analiz eder, ilgililik durumuna göre dosyaları listeler.

## 7. Örnek Kullanım Akışı

CLI:
```powershell
ruby file_assistant.rb search "bitirme projesiyle ilgili dosyaları bul" --dry-run
```

Web:
```powershell
bundle install
bundle exec ruby web_app.rb
```
Tarayıcı:
[http://localhost:4567](http://localhost:4567)

*Not: Örnek olarak C:\AI-Test gibi klasörler kullanabilirsiniz, kendi bilgisayarınızdaki herhangi bir klasör yolu da geçerlidir.*

## 8. AI'nin Ne Yaptığı
AI (Gemini API):
- Verilen dizindeki dosyaların isimlerini, uzantılarını ve (uygunsa) metin içeriklerini inceler (doğal dil ile dosya arama, dosya içeriği analizi).
- Yapılan doğal dil sorgusuyla (örn: "Makine öğrenmesi dersindeki dosyalarımı bul") dosyaların ilişkili olup olmadığını (relevant true/false filtreleme) değerlendirir.
- Kullanıcıya hangi dosyanın neden ilgili olduğuna dair AI reason (gerekçe) döner.
- **Sınırları:** AI sadece dosyaların ilgili olup olmadığını analiz eder, sınıflandırır ve önerir. Kullanıcı onayı olmadan dosya taşımama kuralına sıkı sıkıya uyar.

## 8.5. Web Arayüzü Özellikleri
Web arayüzünde aşağıdaki özellikler sunulmaktadır:
- Modern dashboard
- AI search ve search summary
- Relevant file cards (Sadece ilgili dosyaların gösterimi)
- AI reason (Dosyanın neden seçildiğine dair yapay zeka açıklaması)
- Target folder seçimi ve dosya taşıma (file moving)
- Loading state ve empty state bildirimleri
- Success/error messages
- Responsive design

## 9. Kullanıcının Nerede Kontrol Ettiği
Program hiçbir dosyayı otomatik veya izinsiz olarak taşımaz. 
- Normal organizer modunda taşıma işlemi için kullanıcıdan `[y/n]` onayı alınır.
- AI Search modunda sonuçlar listelendikten sonra, hangi hedef klasöre taşınacağı kullanıcı tarafından seçilir ve nihai işlem için yine `[y/n]` onayı alınır.
- Kullanıcı onaylamadığı sürece sistem hiçbir dosyaya müdahale etmez.

## 10. API Key Kurulumu
Projeyi çalıştırabilmek için Google Gemini API anahtarına ihtiyacınız vardır. Bu anahtar `ENV["GEMINI_API_KEY"]` environment variable'ı (ortam değişkeni) ile tanımlanır. Gerçek API anahtarınızı (API key) kesinlikle kaynak kodlara veya GitHub'a yüklemeyin.

Windows PowerShell'de tanımlamak için:
```powershell
$env:GEMINI_API_KEY="your_api_key_here"
```

Veya `.env` dosyası oluşturarak yönetebilirsiniz (Bu dosya `.gitignore` a eklenmiştir). API key bulunmazsa program, hata fırlatmadan "GEMINI_API_KEY environment variable is not set." mesajı verir ve güvenli bir şekilde kapanır.

## 11. Çalıştırma Komutları

### CLI Usage (Terminal)

**Normal Organizer (Taşıma):**
```powershell
ruby tidy_downloads.rb
```

**Normal Organizer (Önizleme):**
```powershell
ruby tidy_downloads.rb --dry-run
```

**AI File Search:**
```powershell
ruby file_assistant.rb search "sorgu metni"
```

**AI File Search (Önizleme):**
```powershell
ruby file_assistant.rb search "sorgu metni" --dry-run
```

### Web Interface

Uygulamayı tarayıcı üzerinden, daha kullanıcı dostu bir arayüzle kullanabilirsiniz.

**Running the Web App:**
```powershell
bundle exec ruby web_app.rb
```

Uygulama çalıştıktan sonra tarayıcınızda şu adrese gidin:
[http://localhost:4567](http://localhost:4567)

Web arayüzü sayesinde:
- Kullanıcı klasör yolunu manuel girebilir veya Windows klasör seçicisini kullanarak klasör seçebilir.
- Hedef klasörleri form alanından kolayca seçebilirsiniz.
- AI Search sonuçlarını (sadece ilgili/relevant olanları) kartlar halinde inceleyebilirsiniz.
- Seçtiğiniz dosyanın yanındaki hedef formunu kullanarak tek tıklamayla dosyayı taşıyabilirsiniz.

## 12. User Approval
AI dosyaları otomatik olarak taşımaz. Kullanıcı taşımayı onaylamadan (CLI'da "y" diyerek, Web arayüzünde "Taşı" butonuna basarak) dosya hareket ettirilmez.

## 13. Test Komutu ve Sonuçları
Projedeki tüm testleri çalıştırmak ve sistemdeki kırılmaları önlemek için (API çağrıları mock'lanmıştır):
```powershell
ruby -Ilib:test -e "Dir.glob('./test/**/*_test.rb').each { |file| require file }"
```

**Güncel Test Sonucu:**
`18 runs, 43 assertions, 0 failures, 0 errors, 0 skips`

## 14. Log Sistemi
Program her çalıştırıldığında CLI ve Web üzerinden yapılan sonuçları `logs/organizer.log` dosyasına kaydeder.
AI Search loglarında kesinlikle API key veya dosya içeriği **loglanmaz**. Yalnızca sorgu metni, taranan dosya sayısı ve eşleşen dosya sayısı kaydedilir:
```text
2026-10-02 18:30:10 | AI_SEARCH | query="bitirme projesi" | scanned=42 | matched=5
2026-10-02 19:30:12 | WEB_SEARCH | Query: bitirme projesi | 2 dosya incelendi | 1 ilgili
2026-10-02 19:31:04 | WEB_MOVE | bitirme_notu.txt -> Bitirme-Projesi
```

## 15. Security & Environment Variables
- API key source code içinde tutulmaz, ENV değişkeniyle (`ENV["GEMINI_API_KEY"]`) alınır.
- API key ve diğer hassas veriler GitHub'a gönderilmez.
- Dosyalar kullanıcı onayı olmadan taşınmaz.
- Dosyaların üzerine yazılmaz. Unique destination/collision handling kullanılır (aynı isimde dosya varsa yeni isim verilir).
- Web uygulamasında kullanıcı girdileri HTML içine basılırken `ERB escaping` (HTML kaçış karakterleri) kullanılarak XSS saldırılarına karşı korunmuştur.
- Bilgisayardaki tüm dosya sistemi izinsiz taranmaz; kullanıcı açıkça tarama yapılacak klasörü belirtir.
- Tüm dosya içerikleri API'ye gönderilmez. Büyük dosyalar es geçilir.

## 16. 5 Günlük Gerçek Kullanım Değerlendirmesi
Araç teslimden önce en az 5 gün gerçek kullanım sırasında kullanılacaktır. Her çalıştırma `logs/organizer.log` dosyasına kaydedilecektir. 5 günlük kullanım sonunda aşağıdaki değerler karşılaştırılacaktır:
- Toplam araç çalıştırma sayısı
- Organize edilen ve AI ile bulunan dosya sayısı
- Manuel işlem için harcanan süre
- Araç kullanımı sonrası harcanan süre
- Tasarruf edilen toplam süre

*(Gerçek kullanım tamamlanmadan sonuç değerleri eklenmeyecektir.)*

## 17. Proje Yapısı

```text
downloads-organizer/
├── tidy_downloads.rb
├── file_reader.rb
├── ai_classifier.rb
├── file_assistant.rb
├── web_app.rb
├── views/
│   ├── layout.erb
│   └── index.erb
├── public/
│   └── style.css
├── test/
├── logs/
├── Gemfile
├── Gemfile.lock
└── README.md
```