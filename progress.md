# 📊 ParsLinux live-build - İlerleme ve Durum Raporu (progress.md)

Bu belge, **ParsLinux 26.04 LTS (Noble Pars) Canlı ISO Üretim Altyapısı (`live-build`)** projesinin tamamlanan aşamalarını ve hedeflerini özetler.

---

## 📌 Genel Durum Özeti
* **Proje:** ParsLinux Canlı ISO Üretim Mimarisi (`live-build`)
* **Hedef Sürüm:** ParsLinux 26.04 LTS (Noble Pars)
* **Temel Altyapı:** Debian `live-build`, Linux kernel amd64, GRUB EFI / Isolinux
* **Masaüstü Bağlantısı:** `pars-desktop-gnome`
* **Kurulum Aracı:** `pars-setup` (Calamares tarzı GTK4/Libadwaita arayüz)
* **Güncel Durum:** 🟢 Yapılandırma ve betikler tamamlandı, doğrulamadan geçti.

---

## ✅ Tamamlanan Aşamalar

### 1. `auto/` Yapılandırma ve Yürütme Betikleri
- [x] `auto/clean`: Chroot ve binary geçici artıklarını temizleyen betik.
- [x] `auto/config`: Debian Bookworm tabanı, amd64 mimarisi, iso-hybrid çıktısı ve ParsLinux önyükleme argümanlarını tanımlayan yapılandırma motoru.
- [x] `auto/build`: Derleme sürecini başlatan ve `build.log` günlüğü tutan yürütücü.

### 2. `config/package-lists/` Meta Paket Entegrasyonu
- [x] `pars-desktop-gnome.list.chroot`: `pars-desktop-gnome`, `pars-base`, `pars-branding` ve ParsLinux sistem uygulamalarını doğrudan bağlayan liste.
- [x] `live-core.list.chroot`: Canlı açılış (`live-boot`, `live-config`), NetworkManager, GDM3, PipeWire ve disk yönetim araçları.
- [x] `firmware.list.chroot`: Intel, AMD, Realtek, Atheros, Broadcom vb. donanım yazılımları.
- [x] `installer.list.chroot`: GTK4/Libadwaita çalışma zamanı, EFI önyükleyici ve bölümleme araçları.

### 3. `config/archives/` APT Depoları ve Önceliklendirme
- [x] `parslinux.list.chroot` ve `parslinux.list.binary`: ParsLinux resmi ve yerel depo tanımları.
- [x] `parslinux.pref.chroot`: ParsLinux paketlerine 999 önceliği veren APT sabitleme (pinning).
- [x] `packages.chroot/`: Yerel `.deb` paketlerinin doğrudan ISO içine gömülebilmesi için ayrılmış alan.

### 4. `config/includes.chroot/` ve `config/includes.binary/` Katmanları
- [x] `/etc/os-release`, `/etc/issue`, `/etc/hostname`, `/etc/hosts` ParsLinux kimliği.
- [x] `/etc/live/config.conf.d/01-parslinux.conf`: `pars` kullanıcısı, Türkçe yerel ayar (`tr_TR.UTF-8`) ve klavye.
- [x] `/etc/sudoers.d/99-parslinux-live`: Şifresiz sudo izni.
- [x] `/etc/polkit-1/rules.d/99-parslinux-live.rules`: Disk ve kurulum işlemleri için şifresiz polkit kuralı.
- [x] `/etc/gdm3/daemon.conf`: Otomatik oturum açma (Autologin).
- [x] `/etc/skel/Desktop/org.parslinux.setup.desktop`: Masaüstü kurulum kısayolu.
- [x] `.disk/info`, `.disk/cd_type` ve `README.txt` binary bilgileri.

### 5. `config/bootloaders/` Önyükleme Menüleri
- [x] `grub-pc/grub.cfg`: UEFI ve BIOS için şık simgeli GRUB canlı menüsü.
- [x] `isolinux/menu.cfg`: Legacy BIOS Isolinux menüsü.

### 6. `config/hooks/live/` Kancaları
- [x] `0100-parslinux-branding.hook.chroot`: GSettings şemaları, ikon önbellekleri, Plymouth teması ve initramfs.
- [x] `0200-parslinux-live-user.hook.chroot`: Masaüstü kısayolları ve kullanıcı profili.
- [x] `0300-parslinux-services.hook.chroot`: Servis aktivasyonu ve canlı oturumda uyku engelleme.
- [x] `0990-parslinux-cleanup.hook.chroot`: Paket önbellek temizliği ve ISO boyutu optimizasyonu.

### 7. Orkestrasyon ve Doğrulama Betikleri
- [x] `build.sh`: Yerel derleme betiği.
- [x] `docker-build.sh`: Her Linux dağıtımında (Arch, CachyOS, Fedora vb.) çalışabilen izole konteyner derleyicisi.
- [x] `collect-local-debs.sh`: Komşu projelerdeki derlenmiş `.deb` paketlerini toplayıcı.
- [x] `clean.sh`: Derinlemesine çalışma alanı temizleme betiği.
- [x] `check.sh`: Tüm yapılandırmayı ve sözdizimini test eden doğrulama aracı.

---

## 🔮 Sıradaki Adımlar (Master Fork Planı)
- [x] Hazırlanan `.deb` paketlerinin GitHub Pages resmi APT deposunda toplanması ve doğrulanması (`https://parslinux.github.io/apt_repo`).
- [ ] `docker-build.sh` veya `build.sh` ile ilk `ParsLinux-26.04-gnome-amd64.iso` kalıbının derlenmesi ve test edilmesi.
