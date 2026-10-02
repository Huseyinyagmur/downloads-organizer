# Downloads Organizer

Downloads Organizer, Windows'taki Downloads klasöründe biriken dosyaları dosya uzantılarına göre otomatik olarak kategorilere ayıran ve AI desteği ile doğal dilde arama yapabilen küçük bir Ruby CLI aracıdır.

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

## 7. Örnek Kullanım
```powershell
ruby file_assistant.rb search "bitirme projesi"
```
Bu komut sonrası program:
1. Taranacak klasörü sorar.
2. Dosya içeriklerini ve uzantılarını tarar.
3. AI ile ilgililik derecelerini belirler.
4. Dosyaları taşıyacağınız hedef klasörü sorar.

*Not: Dry-run moduyla dosya taşımadan test yapabilirsiniz:*
```powershell
ruby file_assistant.rb search "bitirme projesi" --dry-run
```

## 8. AI'nin Ne Yaptığı
AI (Google Gemini API):
- Verilen dizindeki dosyaların isimlerini, uzantılarını ve (uygunsa) metin içeriklerini inceler.
- Yapılan doğal dil sorgusuyla (örn: "Makine öğrenmesi dersindeki dosyalarımı bul") dosyaların ilişkili olup olmadığını (relevant true/false) değerlendirir.
- Kullanıcıya hangi dosyanın neden ilgili olduğuna dair Türkçe kısa bir "reason" (gerekçe) döner.
- **Sınırları:** AI sadece dosyaların ilgili olup olmadığını analiz eder, sınıflandırır ve önerir. Taşıma işlemi yapmaz.

## 9. Kullanıcının Nerede Kontrol Ettiği
Program hiçbir dosyayı otomatik veya izinsiz olarak taşımaz. 
- Normal organizer modunda taşıma işlemi için kullanıcıdan `[y/n]` onayı alınır.
- AI Search modunda sonuçlar listelendikten sonra, hangi hedef klasöre taşınacağı kullanıcı tarafından seçilir ve nihai işlem için yine `[y/n]` onayı alınır.
- Kullanıcı onaylamadığı sürece sistem hiçbir dosyaya müdahale etmez.

## 10. API Key Kurulumu
Projeyi çalıştırabilmek için Google Gemini API anahtarına ihtiyacınız vardır. Bu anahtar kesinlikle kaynak kodlara veya GitHub'a yüklenmemelidir. 

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
- Hedef klasörleri form alanından kolayca seçebilirsiniz.
- AI Search sonuçlarını (sadece ilgili/relevant olanları) kartlar halinde inceleyebilirsiniz.
- Seçtiğiniz dosyanın yanındaki hedef formunu kullanarak tek tıklamayla dosyayı taşıyabilirsiniz.

## 12. User Approval
AI dosyaları otomatik olarak taşımaz. Kullanıcı taşımayı onaylamadan (CLI'da "y" diyerek, Web arayüzünde "Taşı" butonuna basarak) dosya hareket ettirilmez.

## 13. Test Komutu
Projedeki tüm testleri çalıştırmak ve sistemdeki kırılmaları önlemek için (API çağrıları mock'lanmıştır):
```powershell
ruby -Ilib:test -e "Dir.glob('./test/**/*_test.rb').each { |file| require file }"
```

## 14. Log Sistemi
Program her çalıştırıldığında CLI ve Web üzerinden yapılan sonuçları `logs/organizer.log` dosyasına kaydeder.
AI Search loglarında kesinlikle API key veya dosya içeriği **loglanmaz**. Yalnızca sorgu metni, taranan dosya sayısı ve eşleşen dosya sayısı kaydedilir:
```text
2026-10-02 18:30:10 | AI_SEARCH | query="bitirme projesi" | scanned=42 | matched=5
2026-10-02 19:30:12 | WEB_SEARCH | Query: bitirme projesi | 2 dosya incelendi | 1 ilgili
2026-10-02 19:31:04 | WEB_MOVE | bitirme_notu.txt -> Bitirme-Projesi
```

## 15. Security & Environment Variables
- Tüm dosya içerikleri API'ye gönderilmez. Büyük dosyalar (100 KB üstü) es geçilir, metinler maksimum 2000 karakterle sınırlandırılır.
- Hassas `.env` dosyası `.gitignore` kuralları ile versiyon kontrol sisteminden çıkarılmıştır.
- Herhangi bir ortam değişkeni (API Key) log dosyalarına kaydedilmez.
- Web uygulamasında kullanıcı girdileri (folder path, dosya adları, vb.) HTML içine basılırken `ERB escaping` (HTML kaçış karakterleri) kullanılarak XSS saldırılarına karşı korunmuştur.
- Bilgisayardaki tüm dosya sistemi izinsiz taranmaz; kullanıcı açıkça tarama yapılacak klasörü belirtir.

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
│
├── tidy_downloads.rb          # Eski Organizer temel dosyası
├── file_assistant.rb          # AI File Search CLI ana girişi
├── file_reader.rb             # Dosya okuma modülü
├── ai_classifier.rb           # AI API bağlantı ve JSON parse modülü
├── web_app.rb                 # Sinatra Web App ana girişi
├── Gemfile                    # Ruby bağımlılıkları (Sinatra vb.)
├── .gitignore                 # Güvenlik ve çöp dosyaları engelleme
│
├── views/
│   ├── layout.erb             # Web arayüzü iskeleti
│   └── index.erb              # Web arayüzü ana sayfası
│
├── public/
│   └── style.css              # Web arayüzü CSS tasarımı
│
├── test/
│   ├── tidy_downloads_test.rb # Temel organizer testleri
│   ├── file_assistant_test.rb # AI özelliği ve okuma testleri
│   └── web_app_test.rb        # Web API / UI uç noktası testleri
│
├── logs/
│   └── organizer.log          # Çalıştırma geçmişi
│
└── README.md                  # Proje dökümantasyonu
```