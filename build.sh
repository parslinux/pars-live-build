#!/usr/bin/env bash
set -e

# ==============================================================================
# ParsLinux Canlı ISO Derleme Ana Betiği (build.sh)
# Yerel sistemde root yetkisiyle 'live-build' araçlarını çalıştırır
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo -e "${BLUE}==========================================================${NC}"
echo -e "${BLUE}  🐆 ParsLinux 0.1 - Canlı ISO Derleme  ${NC}"
echo -e "${BLUE}==========================================================${NC}"

# 1. Root / Sudo Yetkisi Denetimi
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[HATA] Bu işlem kök (root / sudo) yetkisi gerektirir.${NC}"
    echo -e "Lütfen şu şekilde çalıştırın: ${GREEN}sudo ./build.sh${NC}"
    exit 1
fi

# 2. live-build (lb) Denetimi
if ! command -v lb >/dev/null 2>&1; then
    echo -e "${RED}[HATA] 'live-build' (lb) komutu sistemde bulunamadı!${NC}"
    echo -e "Debian/Ubuntu üzerinde kurmak için:"
    echo -e "   ${GREEN}sudo apt update && sudo apt install -y live-build debootstrap${NC}"
    echo ""
    echo -e "Eğer Arch Linux / CachyOS / Fedora üzerundayseniz:"
    echo -e "   ${GREEN}./docker-build.sh${NC} betiğini kullanarak Docker veya Podman ile izole derleme yapabilirsiniz."
    exit 1
fi

# 3. auto/ betiklerinin izinlerini sağla
chmod +x auto/clean auto/config auto/build 2>/dev/null || true
chmod +x config/hooks/live/*.hook.chroot 2>/dev/null || true

# 4. Temizlik ve Yapılandırma
echo -e "\n${BLUE}>> [1/3] Önceki derleme artıkları temizleniyor (lb clean)...${NC}"
lb clean

echo -e "\n${BLUE}>> [2/3] Dağıtım parametreleri yapılandırılıyor (lb config)...${NC}"
lb config

echo -e "\n${BLUE}>> [3/3] Canlı ISO kalıbı derleniyor (lb build)...${NC}"
echo -e "${YELLOW}>> Not: Bu işlem internet hızınıza ve işlemcinize bağlı olarak 15-45 dakika sürebilir.${NC}"
echo -e "${YELLOW}>> Detaylı günlük 'build.log' dosyasına yazılacaktır.${NC}\n"

lb build 2>&1 | tee build.log

echo -e "\n${BLUE}==========================================================${NC}"
ISO_FILE=$(ls -1 *.iso 2>/dev/null | head -n 1 || true)
if [ -n "$ISO_FILE" ] && [ -f "$ISO_FILE" ]; then
    ISO_SIZE=$(ls -lh "$ISO_FILE" | awk '{print $5}')
    echo -e "${GREEN}✓ TEBRİKLER! ParsLinux ISO kalıbı başarıyla oluşturuldu:${NC}"
    echo -e "  Dosya : ${GREEN}$ISO_FILE${NC} ($ISO_SIZE)"
    echo -e "  SHA256: $(sha256sum "$ISO_FILE" | awk '{print $1}')"
    echo -e "  QEMU ile test etmek için:"
    echo -e "  ${YELLOW}qemu-system-x86_64 -enable-kvm -m 4G -cdrom $ISO_FILE -boot d${NC}"
else
    echo -e "${RED}✗ ISO dosyası oluşturulamadı. Lütfen 'build.log' dosyasını inceleyin.${NC}"
fi
echo -e "${BLUE}==========================================================${NC}"
