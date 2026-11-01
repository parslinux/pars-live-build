# 🛠️ ParsLinux 26.04 LTS (Noble Pars) - Canlı ISO Üretim Altyapısı (`live-build`)

Bu dizin, **ParsLinux 26.04 LTS** dağıtımının resmi canlı (Live) ve kurulum (Installer) USB ISO kalıbını (`ParsLinux-26.04-gnome-amd64.iso`) sıfırdan derlemek için yapılandırılmış profesyonel **Debian `live-build`** altyapısını içerir.

---

## 🌟 Öne Çıkan Özellikler

* **📦 Doğrudan Meta Paket Bağlantısı:**
  * Çekirdek sistem `config/package-lists/pars-desktop-gnome.list.chroot` üzerinden doğrudan **`pars-desktop-gnome`**, `pars-base` ve `pars-branding` meta paketlerine bağlanmıştır.
* **🎨 Kusursuz Pars Görsel Kimliği:**
  * GRUB önyükleme menüsü, Plymouth açılış teması, GDM3 otomatik oturum açma ve koyu tema uyumu.
* **🦎 Entegre Kurulum Sihirbazı:**
  * Canlı masaüstünde hazır `pars-setup` (ParsLinux Kurulum Sihirbazı) kısayolu ve tam yetkili PolicyKit (`pkexec`) kuralları.
* **⚙️ Çift Derleme Motoru:**
  1. **Yerel Derleme (`build.sh`):** Debian/Ubuntu sistemlerde doğrudan `lb` ile derleme.
  2. **Konteynerli Derleme (`docker-build.sh`):** Arch Linux, CachyOS, Fedora gibi sistemlerde Docker/Podman ile izole Debian Bookworm ortamında tam uyumlu derleme.
* **📁 Yerel `.deb` Entegrasyonu:**
  * Henüz harici repoda olmayan paketleri `config/packages.chroot/` dizinine atarak veya `./collect-local-debs.sh` ile komşu projelerden tek tıkla çekerek kalıba gömebilme.

---

## 📂 Dizin Mimarisi

```
live-build/
├── auto/                               # live-build otomatik yürütme betikleri
│   ├── clean                           # Çalışma dizini ve chroot temizleyici
│   ├── config                          # lb config parametreleri (Debian Bookworm tabanı, amd64, iso-hybrid)
│   └── build                           # lb build yürütücü ve log kaydedici
├── config/
│   ├── archives/                       # APT depo kaynakları ve paket sabitleme
│   │   ├── parslinux.list.chroot       # Chroot aşamasında ParsLinux deposu
│   │   ├── parslinux.list.binary       # Canlı sistem içinde /etc/apt/sources.list.d kaynağı
│   │   └── parslinux.pref.chroot       # Pars paketlerine öncelik (Pin-Priority: 999)
│   ├── bootloaders/                    # Açılış menüleri ve temaları
│   │   ├── grub-pc/grub.cfg            # UEFI ve BIOS için şık GRUB canlı menüsü
│   │   └── isolinux/menu.cfg           # Legacy BIOS Isolinux menüsü
│   ├── hooks/live/                     # Chroot içinde çalışan kurulum kancaları
│   │   ├── 0100-parslinux-branding.hook.chroot # GSettings şemaları, ikonlar, initramfs
│   │   ├── 0200-parslinux-live-user.hook.chroot# Canlı kullanıcı masaüstü kısayolları
│   │   ├── 0300-parslinux-services.hook.chroot # GDM3, NetworkManager, uyku engelleme
│   │   └── 0990-parslinux-cleanup.hook.chroot  # Önbellek temizliği ve ISO optimizasyonu
│   ├── includes.binary/                # Doğrudan ISO kök dizinine yerleştirilen dosyalar (.disk/info, README)
│   ├── includes.chroot/                # Canlı sistem kök dizinine (/etc, /usr vb.) bindirilen dosyalar
│   │   └── etc/
│   │       ├── os-release              # ParsLinux 26.04 LTS kimlik dosyası
│   │       ├── gdm3/daemon.conf        # Canlı kullanıcı 'pars' için otomatik giriş
│   │       ├── live/config.conf.d/     # Canlı kullanıcı, dil (tr_TR) ve saat ayarları
│   │       ├── polkit-1/rules.d/       # Şifresiz kurulum sihirbazı ve disk izinleri
│   │       ├── sudoers.d/              # Şifresiz sudo kuralı
│   │       └── skel/Desktop/           # Masaüstü kurulum kısayolu (pars-setup.desktop)
│   ├── package-lists/                  # Sistem paket listeleri
│   │   ├── pars-desktop-gnome.list.chroot # ParsLinux meta paketi ve araçları
│   │   ├── live-core.list.chroot       # Canlı açılış, PipeWire, GDM3, NetworkManager
│   │   ├── firmware.list.chroot        # Wi-Fi, Bluetooth, GPU mikro kodları
│   │   └── installer.list.chroot       # Kurulum sihirbazı çalışma zamanı ve GRUB araçları
│   └── packages.chroot/                # Doğrudan chroot içine kurulacak yerel .deb dosyaları
├── build.sh                            # Yerel sistemde root ile canlı ISO derleme betiği
├── docker-build.sh                     # Docker / Podman ile izole konteynerde ISO derleme betiği
├── collect-local-debs.sh               # Komşu projelerdeki .deb paketlerini toplayıcı
├── clean.sh                            # Derinlemesine temizlik ve sıfırlama betiği
├── check.sh                            # Sözdizimi ve bütünlük doğrulama betiği
└── README.md                           # Bu dokümantasyon
```

---

## 🚀 Canlı ISO Nasıl Derlenir?

### 1. Bütünlük ve Sözdizimi Testi
Herhangi bir derlemeye başlamadan önce yapılandırmanın doğruluğunu denetleyin:
```bash
./check.sh
```

### 2. Yerel `.deb` Paketlerini Toplama (İsteğe Bağlı)
Eğer komşu dizinlerde (`../pars-desktop-gnome`, `../pars-setup` vb.) derlenmiş `.deb` paketleriniz varsa bunları tek komutla canlı ortama dahil edebilirsiniz:
```bash
./collect-local-debs.sh
```

### 3. Derleme Seçenekleri

#### Seçenek A: Docker / Podman ile Derleme (Tavsiye Edilir - Her Dağıtımda Çalışır)
Özellikle **Arch Linux / CachyOS / Fedora** gibi ana sistemlerde hiçbir ek paket kurmadan tam uyumlu Debian Bookworm konteyneri üzerinde derleme yapar:
```bash
./docker-build.sh
```

#### Seçenek B: Yerel Sistemde Derleme (Debian / Ubuntu / ParsLinux üzerinde)
Eğer doğrudan bir Debian veya türevi sistem üzerindeyseniz:
```bash
# 1. Gerekli araçları kurun:
sudo apt update && sudo apt install -y live-build debootstrap

# 2. Derlemeyi başlatın:
sudo ./build.sh
```

---

## 🧪 ISO Kalıbını Sanal Makinede Test Etme

Derleme tamamlandığında çalışma dizininde **`ParsLinux-26.04-gnome-amd64.iso`** dosyası oluşacaktır.

QEMU / KVM ile anında test etmek için:
```bash
qemu-system-x86_64 \
    -enable-kvm \
    -m 4G \
    -smp 4 \
    -vga virtio \
    -display gtk \
    -cdrom ParsLinux-26.04-gnome-amd64.iso \
    -boot d
```
