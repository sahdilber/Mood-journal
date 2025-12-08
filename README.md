<div align="center">

# 🌙📓 **Moodiary**  
### *Your everyday mood companion.*

Her gün nasıl hissettiğini nazikçe takip et, not ekle, grafikleri incele ve duygusal yolculuğunu keşfet.  
Moodiary, SwiftUI + Firebase ile geliştirilmiş modern bir **mood tracking (ruh hali günlüğü)** uygulamasıdır.  
Minimal, akıcı ve kullanıcı dostu.

---

## 📱 Uygulama Görselleri

<div align="center">
<p>
  <img src="https://github.com/user-attachments/assets/fee0017e-f331-43dc-8c6d-59a22cb839b2" width="170" style="margin:6px; border-radius:24px;" />
  <img src="https://github.com/user-attachments/assets/f0f78292-ad00-414e-bb6c-a688be676cb8" width="170" style="margin:6px; border-radius:24px;" />
  <img src="https://github.com/user-attachments/assets/5bd62176-b9ce-46c0-931e-96207faae7cb" width="170" style="margin:6px; border-radius:24px;" />
  <img src="https://github.com/user-attachments/assets/194e4186-2b37-463e-9158-94b47adb2487" width="170" style="margin:6px; border-radius:24px;" />
  <img src="https://github.com/user-attachments/assets/d4ad6374-7c96-48e4-91f4-3f0f049f5d61" width="170" style="margin:6px; border-radius:24px;" />
</p>
<!-- SATIR 1 -->
<p>
  <img src="https://github.com/user-attachments/assets/f4947cf7-3b40-4306-83ba-5fa782ef02ac" width="170" style="margin:6px; border-radius:24px;" />
  <img src="https://github.com/user-attachments/assets/3718bc8c-0b70-4fad-a826-31dd8290da89" width="170" style="margin:6px; border-radius:24px;" />
  <img src="https://github.com/user-attachments/assets/6d54ad34-4697-4adf-838f-7b5d7c8dadf7" width="170" style="margin:6px; border-radius:24px;" />
</p>
<p>
  <img src="https://github.com/user-attachments/assets/1c200e54-e397-4ff5-a6f1-c7ee33e38ff1" width="170" style="margin:6px; border-radius:24px;" />
  <img src="https://github.com/user-attachments/assets/06061eb4-2dde-45e2-bfa2-8d4d4826c357" width="170" style="margin:6px; border-radius:24px;" />
</p>


</div>

---

## 🌟 Neler Yapabilirsin?

📝 Günlük mood kaydı oluştur  
💬 Her mood için kısa bir not ekle  
📊 İstatistik ekranında grafiklerle ruh halini analiz et  
🗓 Takvim görünümü ile geçmiş günlerine geri dön  
🗑 Mood kayıtlarını düzenle veya sil  
📴 Offline cache (internet yokken bile kayıtlarına bakabilirsin)  
🔔 Günlük bildirim hatırlatıcısı ile “Bugün nasılsın?” sorusunu unutma

---

## 🧩 Uygulama Akışı

1️⃣ Mood seç → “Bugün nasılım?”  
2️⃣ Kısa bir not yaz → o gününe küçük bir açıklama  
3️⃣ Kaydet → veri Firestore’a yazılır  
4️⃣ HomeView’da tüm mood’larını liste halinde gör  
5️⃣ Bir mood’a dokun → detay sayfasında görüntüle, düzenle veya sil  
6️⃣ StatsView ve CalendarView → grafikler + takvim üzerinden genel ruh halini analiz et

---
## 🛠 Teknik Özellikler (Tech Stack)

- **Dil:** Swift 5+  
- **UI:** SwiftUI  
- **Mimari:** MVVM  
- **Backend:** Firebase  
  - Firebase Authentication  
  - Cloud Firestore  
- **Diğer:**  
  - UNUserNotificationCenter ile lokal bildirim planlama  
  - Offline cache / lokal veri tutma stratejisi  
  - Güvenli `List` güncelleme (unique `listID` + animasyonsuz update)  
  - Reusable SwiftUI bileşenleri ve custom button style  
  - Gradient arka planlar ve tematik renk sistemi (`AppColors`)  


## 🛠 Uygulama Yapısı

```bash
Moodiary/
├── Views/
│   ├── LoginView.swift
│   ├── HomeView.swift
│   ├── NewEntryView.swift
│   ├── EditEntryView.swift
│   ├── MoodDetailView.swift
│   ├── StatsView.swift
│   ├── CalendarView.swift
│   └── ProfileView.swift
│
├── ViewModels/
│   ├── AuthViewModel.swift
│   ├── MoodViewModel.swift
│   └── StatsViewModel.swift
│
├── Services/
│   ├── FirestoreService.swift
│   └── NotificationService.swift
│
└── Utils/
    ├── AppColors.swift
    ├── MoodModel.swift
    └── CustomButtonStyle.swift
```

<div align="center">

## 💌 **İletişim**

Bana ulaşmak istersen:  
📧 **dilber-sah@hotmail.com**

<br>

⭐ Eğer bu proje hoşuna gittiyse GitHub’da bir yıldız bırakmayı unutma!  
*ArtifyAI ile hayatı renklendir.* 🌈✨

</div>
