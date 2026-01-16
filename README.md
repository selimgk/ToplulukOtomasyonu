# ToplulukOtomasyonu
**youtube linki:** https://youtu.be/6aP62bbVFxE
 


Bu proje, **Mobil Programlama** dersi final ödevi kapsamında geliştirilmiş, veritabanı destekli bir topluluk yönetim uygulamasıdır.

## 1. Bu uygulama kimin işine yarar?
Bu uygulama iki temel kullanıcı kitlesine hitap eder:
*   **Üniversite Öğrencileri:** Kampüs hayatını aktif yaşamak, toplulukların düzenlediği etkinliklerden anında haberdar olmak ve bu etkinliklere karmaşık süreçlerle uğraşmadan tek tıkla kaydolmak isteyen tüm öğrenciler.
*   **Topluluk Yöneticileri (Başkanlar):** Etkinliklerini düzenli bir şekilde duyurmak, katılımcı başvurularını (RSVP) dijital ortamda yönetmek (onaylama/reddetme) ve etkinlik girişlerinde güvenli bir denetim sağlamak isteyen topluluk liderleri.

## 2. Hangi problemi çözer?
*   **Duyuru Kirliliği ve İletişimsizlik:** Kampüsteki etkinliklerin afişlerde veya farklı sosyal medya gruplarında gözden kaçmasını engeller; tüm etkinlikleri merkezi bir mobil platformda toplar.
*   **Manuel Süreçlerin Yarattığı Yük:** Etkinlik kayıtlarının kağıt-kalem veya formlar üzerinden manuel yapılması yerine, sürecin tamamen dijital ve otomatik (veritabanı kayıtlı) ilerlemesini sağlar.
*   **Giriş Kontrolü ve Güvenlik:** Etkinliklere kayıt dışı katılımları önler. Sadece yöneticinin onayladığı kişilere özel **QR Kodlu Bilet** oluşturarak etkinlik girişindeki denetim sorununu çözer.
*   **İnternet Bağımlılığı:** Uygulama **Offline-First (Çevrimdışı Öncelikli)** mimariyle tasarlandığı için, internetin çekmediği amfilerde veya kampüs bölgelerinde bile öğrenciler biletlerine ve daha önce yüklenen verilere erişebilir.

## 3. Nerede ve nasıl kullanılır?
Uygulama Android işletim sistemli mobil cihazlarda kullanılır.

*   **Öğrenci Senaryosu:**
    1.  Öğrenci uygulamayı açar ve öğrenci numarasıyla giriş yapar.
    2.  Ana sayfada yaklaşan etkinlikleri ve üye olduğu topluluğu görüntüler.
    3.  İlgisini çeken bir etkinliğe girip **"Katıl"** butonuna basar.
    4.  Başvurusu onaylandığında **"Biletlerim"** menüsüne giderek QR biletini görüntüler.
    5.  Etkinlik günü bu QR kodu görevliye göstererek giriş yapar.

*   **Yönetici Senaryosu:**
    1.  Yönetici (Topluluk Başkanı) kendi kullanıcı bilgileriyle giriş yapar.
    2.  **"Yönetici Paneli"** üzerinden yeni bir etkinlik oluşturur (Tarih, yer, afiş vb.).
    3.  Gelen başvuruları listeler ve uygun gördüğü öğrencileri **"Onayla"** butonuna basarak etkinliğe kabul eder.
    4.  Etkinlik kapısında uygulamanın **"QR Tara"** özelliğini açarak öğrencilerin biletlerini okutur ve içeri alır.

## Teknik Altyapı
*   **Dil/Framework:** Dart & Flutter
*   **Veritabanı:** SQLite (Yerel Veritabanı)
*   **Özellikler:** QR Kod Oluşturma/Okuma, Dinamik Yetkilendirme, Türkçe Dil Desteği.
