# ✨ Cutis Glow - Beauty Clinic Management System

**Cutis Glow** adalah sistem informasi manajemen klinik kecantikan berbasis **Website** dan **Mobile** yang dikembangkan menggunakan arsitektur **Client–Server**. Sistem ini membantu proses administrasi klinik mulai dari pengelolaan data pasien, dokter, layanan perawatan, jadwal praktik, booking konsultasi, hingga riwayat layanan dalam satu platform yang terintegrasi.

Backend aplikasi dikembangkan menggunakan **Laravel** sebagai penyedia **REST API**, sedangkan aplikasi mobile dikembangkan menggunakan **Flutter** sebagai client. Seluruh komunikasi data dilakukan melalui REST API yang diamankan menggunakan **Laravel Sanctum** untuk autentikasi dan **Spatie Laravel Permission** untuk otorisasi berbasis **Role-Based Access Control (RBAC)**.

---

# 🚀 Fitur Utama

## 👨‍💼 Administrator

* Dashboard statistik klinik
* CRUD Data Dokter
* CRUD Data Pasien
* CRUD Master Layanan
* CRUD Jadwal Dokter
* CRUD Booking Konsultasi
* CRUD Riwayat Layanan
* Manajemen User
* Manajemen Role & Permission
* Search, Filter, Sorting, dan Pagination

---

## 👨‍⚕️ Dokter

* Dashboard Dokter
* Melihat jadwal praktik
* Melihat daftar booking pasien
* Mengelola hasil konsultasi
* Mengelola riwayat layanan pasien

---

## 👩 Pasien

* Login
* Dashboard Pasien
* Melihat profil
* Mengubah profil
* Mengubah password
* Melihat daftar dokter
* Melihat layanan klinik
* Booking konsultasi
* Melihat hasil konsultasi
* Melihat riwayat layanan

---

# 🏗️ Arsitektur Sistem

Cutis Glow menggunakan arsitektur **Client–Server** yang terdiri dari tiga lapisan utama.

### Presentation Layer

* Laravel Web Dashboard
* Flutter Mobile Application

### Application Layer

* REST API
* Authentication (Laravel Sanctum)
* Authorization (Spatie Laravel Permission / RBAC)
* Master Data Module
* Booking Module
* Consultation Module
* Service Module

### Data Layer

* MySQL Database
* Eloquent ORM

Backend menerapkan arsitektur **Model–View–Controller (MVC)** sehingga logika bisnis, tampilan, dan pengelolaan data dipisahkan dengan baik. Website dan aplikasi mobile mengakses data melalui REST API sehingga keduanya menggunakan sumber data yang sama.

---

# 📂 Struktur Project

```text
Cutis Glow/
│
├── README.md
│
├── backend/
│   ├── app/
│   ├── bootstrap/
│   ├── config/
│   ├── database/
│   ├── public/
│   ├── resources/
│   ├── routes/
│   ├── storage/
│   └── composer.json
│
└── mobile/
    ├── lib/
    │   ├── models/
    │   ├── services/
    │   ├── screens/
    │   ├── widgets/
    │   └── main.dart
    └── pubspec.yaml
```

---

# 🛠️ Tech Stack

| Komponen | Teknologi |
|----------|-----------|
| Backend | Laravel 13 |
| Bahasa Backend | PHP 8.4+ |
| Database | MySQL / MariaDB |
| Authentication | Laravel Sanctum |
| Authorization | Spatie Laravel Permission |
| Frontend Mobile | Flutter |
| Bahasa Mobile | Dart |
| API | REST API |
| UI Website | Tailwind CSS |
| Version Control | Git & GitHub |

---

# 👥 Role & Hak Akses

## 👨‍💼 Admin

* Dashboard
* Kelola Dokter
* Kelola Pasien
* Kelola Master Layanan
* Kelola Jadwal Dokter
* Kelola Booking Konsultasi
* Kelola Riwayat Layanan
* Kelola User
* Kelola Role & Permission

---

## 👨‍⚕️ Dokter

* Dashboard
* Melihat Jadwal Praktik
* Melihat Booking Pasien
* Mengelola Hasil Konsultasi
* Mengelola Riwayat Layanan Pasien

---

## 👩 Pasien

* Dashboard
* Profil
* Booking Konsultasi
* Melihat Hasil Konsultasi
* Melihat Riwayat Layanan
* Mengubah Password

---

# 🔌 REST API

Seluruh endpoint menggunakan format **JSON**.

Endpoint yang bersifat **protected** memerlukan Bearer Token yang diperoleh setelah proses login.

```http
Authorization: Bearer {token}
Accept: application/json
```

## Authentication

```http
POST   /api/login
POST   /api/logout
GET    /api/user
```

## Admin

```http
GET|POST|PUT|DELETE /api/doctors
GET|POST|PUT|DELETE /api/patients
GET|POST|PUT|DELETE /api/services
GET|POST|PUT|DELETE /api/schedules
GET|POST|PUT|DELETE /api/bookings
GET|POST|PUT|DELETE /api/service-histories
```

## Dokter

```http
GET    /api/dashboard
GET    /api/schedules
GET    /api/bookings
POST   /api/consultations
PUT    /api/consultations/{id}
```

## Pasien

```http
GET    /api/profile
PUT    /api/profile
PUT    /api/change-password

GET    /api/services
GET    /api/doctors

GET    /api/bookings
POST   /api/bookings

GET    /api/service-histories
```

---

# ⚙️ Instalasi

Clone repository

```bash
git clone https://github.com/Dhiyaan06/cutis-glow.git
cd cutis-glow
```

Install dependency Laravel

```bash
composer install
```

Salin file environment

```bash
cp .env.example .env
```

Generate application key

```bash
php artisan key:generate
```

Konfigurasi database pada file `.env`

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=db_cutis_glow
DB_USERNAME=root
DB_PASSWORD=
```

Install dependency frontend

```bash
npm install
npm run build
```

Jalankan migrasi database

```bash
php artisan migrate --seed
```

Jalankan server Laravel

```bash
php artisan serve
```

---

# 👤 Akun Default

| Email | Password | Role |
|:------|:---------|:-----|
| admin@cutisglow.com | password | Admin |
| dokter@cutisglow.com | password | Dokter |
| pasien@cutisglow.com | password | Pasien |

> **Catatan:** Pastikan data akun sesuai dengan seeder yang digunakan pada project.

---

# 📱 Menjalankan Aplikasi Mobile

Masuk ke folder Flutter

```bash
cd mobile
```

Install dependency

```bash
flutter pub get
```

Atur Base URL pada file

```dart
lib/services/api_client.dart
```

Android Emulator

```dart
const String baseUrl = "http://10.0.2.2:8000/api";
```

Real Device

```dart
const String baseUrl = "http://192.168.x.x:8000/api";
```

Jalankan aplikasi

```bash
flutter run
```

---

# 🔄 Catatan Pengembangan

Apabila terdapat perubahan struktur database setelah melakukan **clone** atau **pull**, jalankan:

```bash
php artisan migrate
```

Jika struktur database sudah tidak sesuai, gunakan:

```bash
php artisan migrate:fresh --seed
```

> **Perhatian:** Perintah `migrate:fresh --seed` akan menghapus seluruh data pada database.

---

# 📸 Tampilan Aplikasi

| Login | Dashboard Admin | Dashboard Dokter | Dashboard Pasien |
|:------:|:---------------:|:----------------:|:----------------:|
| Screenshot | Screenshot | Screenshot | Screenshot |

---

# 👨‍💻 Tim Pengembang

**Kelompok 4**

* Dhiya'an Sani — 230102036
* Dini Sri Ayu Priyono — 230102040
* Hilmi Durroh Taqwiyah — 230102060
* Putri Leonita Cikal Buchori — 230102108

**Program Studi Teknik Informatika**  
**Fakultas Sains dan Teknologi**  
**Universitas Muhammadiyah Bandung**

---

# 🎥 Demo

Tambahkan tautan video demonstrasi proyek.

https://youtu.be/bFyvM95-og4

---

# 📄 Lisensi

Cutis Glow dikembangkan sebagai proyek akademik untuk memenuhi tugas mata kuliah **Pemrograman Web Framework (PWBF)** dan **Pemrograman Perangkat Bergerak Client Server (PPBCS)** di Program Studi Teknik Informatika, Universitas Muhammadiyah Bandung.

Seluruh kode sumber dan dokumentasi pada repositori ini digunakan untuk keperluan pembelajaran dan pengembangan akademik.


link github laravel :
https://github.com/Dhiyaan06/cutis-glow.git
