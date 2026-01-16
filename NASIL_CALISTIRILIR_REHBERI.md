# Projeyi Çalıştırma Rehberi

## 1. Visual Studio Code ile Çalıştırma
Projeyi VS Code için yapılandırdım. Artık çok daha kolay çalıştırabilirsiniz:
1.  Soldaki menüden **"Run and Debug"** (Böcek/Play ikonu) sekmesine gelin.
2.  Yukarıdaki açılır menüden istediğiniz cihazı seçin (Örn: `derss1 (Windows)` veya `derss1 (Chrome)`).
3.  **Yeşil Play tuşuna** basın (veya `F5` tuşuna basın).

---

## 2. Telefondan Nasıl Açarım? (Android)
Uygulamayı Android telefonunuza yüklemek için şu adımları izleyin:

### Hazırlık
1.  Telefonunuzda **Geliştirici Seçeneklerini** açın:
    *   *Ayarlar > Telefon Hakkında > Yazılım Bilgileri* menüsüne gidin.
    *   *Yapım Numarası (Build Number)* üzerine 7 kez arka arkaya basın.
2.  **USB Hata Ayıklama (Debugging)** modunu açın:
    *   *Ayarlar > Geliştirici Seçenekleri > USB Hata Ayıklama* seçeneğini aktif edin.
3.  Telefonunuzu kablo ile bilgisayara bağlayın ve telefondan "Bu bilgisayara güven" onayını verin.

### Yükleme ve Çalıştırma (Kablolu)
VS Code içerisindeyken:
1.  Telefonunuz bağlıyken sağ alttaki cihaz seçim kısmında telefonunuzu görün. (Örn: `Samsung SM-A52...`)
2.  Görmüyorsanız `Ctrl + Shift + P` yapıp **"Flutter: Select Device"** diyerek telefonunuzu seçin.
3.  `F5` tuşuna basarak uygulamayı telefonunuza yükleyin.

### APK Oluşturup Gönderme (Kablosuz)
Eğer kabloyla uğraşmak istemezseniz, kurulum dosyası (APK) oluşturup telefona atabilirsiniz:
1.  VS Code terminaline şu komutu yazın:
    ```bash
    flutter build apk --release
    ```
2.  İşlem bittikten sonra dosya şu konumda oluşacaktır:
    `build/app/outputs/flutter-apk/app-release.apk`
3.  Bu dosyayı WhatsApp, Email veya USB ile telefonunuza gönderin.
4.  Telefonda dosyaya tıklayıp "Yükle" diyerek kurun.

> **Not:** iOS (iPhone) cihazlara yükleme yapmak için bir Mac bilgisayar gereklidir. Windows üzerinden iPhone'a doğrudan yükleme yapılamaz.

---

## Önemli Notlar
*   **İnternet:** Haberleri ilk kez yüklerken telefonunuzun interneti açık olmalıdır. Sonrasında internet olmasa da çalışır.
*   **Veritabanı:** Telefondaki veriler (üyelikler vb.) sadece o telefonda saklanır. Bilgisayardaki verilerle karışmaz.
