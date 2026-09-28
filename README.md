# Downloads Organizer

Downloads Organizer, Windows'taki Downloads klasöründe biriken dosyaları dosya uzantılarına göre otomatik olarak kategorilere ayıran küçük bir Ruby CLI aracıdır.

## Problem

Downloads klasörümde farklı türlerde dosyalar birikiyor ve belirli aralıklarla bunları manuel olarak kategorilere ayırmam gerekiyor.

Örneğin PDF, Word, PowerPoint, ZIP, görsel ve kod dosyalarını tek tek seçip ilgili klasörlere taşımak gerekiyor. Bu işlem tekrarlandığı için her seferinde zaman kaybına neden oluyor.

### Pain Diary

| Tarih | Yapılan işlem | Harcanan süre | Kanıt |
|---|---|---:|---|
| 25.09.2026 | Downloads dosyalarının türlerine göre düzenlenmesi | 4 dk | Ekran görüntüsü |
| 26.09.2026 | PDF, ZIP ve dokümanların ayrılması | 7 dk | Ekran görüntüsü |
| 27.09.2026 | Dosyaların kategorilere ayrılması ve gereksiz dosyaların temizlenmesi | 5 dk | Ekran görüntüsü |

**Toplam:** 16 dakika

**Tekrarlanma:** 3 kez / 3 gün

**Ortalama:** 5,3 dakika / işlem

Bu kayıtlar, problemin günlük kullanım sırasında tekrarlandığını göstermek için tutulmuştur.

---

## Çözüm

Downloads Organizer, Downloads klasöründeki dosyaları uzantılarına göre otomatik olarak kategorilere ayırır.

Desteklenen kategoriler:

- Documents
- Images
- Videos
- Archives
- Spreadsheets
- Presentations
- Code
- Datasets
- Installers
- Models
- Network
- Project
- Other

Örneğin başlangıçta Downloads klasörü şu şekilde olabilir:

```text
Downloads/
├── report.pdf
├── presentation.pptx
├── photo.png
└── project.zip
```

Program çalıştırıldıktan sonra:

```text
Downloads/
├── Documents/
│   └── report.pdf
├── Presentations/
│   └── presentation.pptx
├── Images/
│   └── photo.png
└── Archives/
    └── project.zip
```

şeklinde düzenlenir.

---

## Gereksinimler

- Ruby 3.x
- Windows
- Downloads klasörü

Projede harici bir Ruby gem'i kullanılmamaktadır.

Testler Ruby'nin Minitest kütüphanesi kullanılarak yazılmıştır.

---

## Kullanım

### Dry Run

Dosyaları taşımadan önce hangi dosyanın hangi klasöre gideceğini görmek için:

```powershell
ruby tidy_downloads.rb --dry-run
```

Bu modda hiçbir dosya taşınmaz.

Örnek çıktı:

```text
log.txt
  -> Documents/log.txt

presentation.pptx
  -> Presentations/presentation.pptx
```

---

### Normal Çalıştırma

Dosyaları gerçekten kategorilerine göre taşımak için:

```powershell
ruby tidy_downloads.rb
```

Program taşıma işleminden önce kullanıcıdan onay ister:

```text
Dosyalar kategorilerine göre taşınsın mı? [y/n]:
```

`y` girilirse dosyalar taşınır.

`n` girilirse işlem iptal edilir.

---

## Dosya Çakışmaları

Hedef klasörde aynı isimde bir dosya zaten varsa mevcut dosyanın üzerine yazılmaz.

Örneğin:

```text
report.pdf
```

zaten `Documents` klasöründe bulunuyorsa yeni dosya:

```text
report_1.pdf
```

olarak kaydedilir.

Başka çakışmalar olması durumunda:

```text
report_2.pdf
report_3.pdf
```

şeklinde devam edilir.

---

## Log Sistemi

Program her çalıştırıldığında:

```text
logs/organizer.log
```

dosyasına sonuç kaydedilir.

Örnek:

```text
2026-09-27 14:30:12 | SUCCESS | 2 dosya taşındı
2026-09-27 14:35:20 | SUCCESS | Dry run | 3 dosya analiz edildi
2026-09-27 14:40:10 | CANCELLED | Kullanıcı işlemi iptal etti
```

Loglar aracın kaç kez çalıştırıldığını ve her çalıştırmada ne olduğunu takip etmek için kullanılmaktadır.

---

## Kullanıcı Kontrolü

Program aşağıdaki işlemleri otomatik olarak gerçekleştirir:

1. Downloads klasörünü tarar.
2. Dosyaların uzantılarını kontrol eder.
3. Dosyaları kategorilere ayırır.
4. Gerekli klasörleri oluşturur.
5. Dosyaları uygun klasörlere taşır.
6. İşlemin sonucunu log dosyasına kaydeder.

Gerçek taşıma işleminden önce kullanıcıdan onay alınır.

Bu nedenle dosyaların taşınması kullanıcı onayı olmadan gerçekleştirilmez.

Ayrıca `--dry-run` seçeneği ile herhangi bir değişiklik yapılmadan önce sonuç kontrol edilebilir.

---

## Testler

Projede dosya kategorilendirme fonksiyonunu kontrol eden Minitest testleri bulunmaktadır.

Testleri çalıştırmak için:

```powershell
ruby test\tidy_downloads_test.rb
```

Mevcut test sonucu:

```text
7 runs, 7 assertions, 0 failures, 0 errors, 0 skips
```

Test edilen örnekler:

- PDF → Documents
- DOCX → Documents
- PNG → Images
- MP4 → Videos
- ZIP → Archives
- PY → Code
- Tanınmayan uzantı → Other

---

## Proje Yapısı

```text
downloads-organizer/
│
├── tidy_downloads.rb
│
├── test/
│   └── tidy_downloads_test.rb
│
├── logs/
│   └── organizer.log
│
└── README.md
```

---

## 5 Günlük Kullanım

Araç teslimden önce en az 5 gün gerçek kullanım sırasında kullanılacaktır.

Her çalıştırma `logs/organizer.log` dosyasına kaydedilecektir.

5 günlük kullanım sonunda aşağıdaki değerler karşılaştırılacaktır:

- Toplam araç çalıştırma sayısı
- Organize edilen dosya sayısı
- Manuel işlem için harcanan süre
- Araç kullanımı sonrası harcanan süre
- Tasarruf edilen toplam süre

Bu veriler pain diary ile karşılaştırılarak aracın gerçek kullanım sırasında sağladığı zaman tasarrufu gösterilecektir.

Gerçek kullanım tamamlanmadan sonuç değerleri eklenmeyecektir.

---

## Teknolojiler

- Ruby
- FileUtils
- Minitest
- Windows File System

---

## Komutlar

### Dry Run

```powershell
ruby tidy_downloads.rb --dry-run
```

### Normal Çalıştırma

```powershell
ruby tidy_downloads.rb
```

### Test

```powershell
ruby test\tidy_downloads_test.rb
```

---

## Projenin Amacı

Bu projenin amacı, Downloads klasöründe tekrar eden manuel dosya düzenleme işlemini küçük ve doğrudan kullanılabilir bir CLI aracıyla azaltmaktır.

Araç, gerçek kullanım sırasında en az 5 gün test edilerek kullanım sıklığı ve zaman tasarrufu loglar üzerinden değerlendirilecektir.