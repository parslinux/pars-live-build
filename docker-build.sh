#!/usr/bin/env bash
set -e

# ==============================================================================
# ParsLinux Konteyner Tabanlı Canlı ISO Derleyici (docker-build.sh)
# Arch Linux, CachyOS, Fedora veya diğer dağıtımlarda Docker/Podman ile izole
# Debian ortamında 'live-build' çalıştırarak ParsLinux ISO kalıbını derler.
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo -e "${BLUE}==========================================================${NC}"
echo -e "${BLUE}  🐆 ParsLinux 26.04 LTS - Konteyner Canlı ISO Derleyici  ${NC}"
echo -e "${BLUE}==========================================================${NC}"

# Konteyner motoru tespiti (Docker veya Podman)
CONTAINER_ENGINE=""
if command -v docker >/dev/null 2>&1; then
    CONTAINER_ENGINE="docker"
elif command -v podman >/dev/null 2>&1; then
    CONTAINER_ENGINE="podman"
else
    echo -e "${RED}[HATA] Sistemde 'docker' veya 'podman' bulunamadı!${NC}"
    echo -e "Lütfen Docker veya Podman kurup servisini başlatın."
    exit 1
fi

echo -e ">> Konteyner Motoru: ${GREEN}$CONTAINER_ENGINE${NC}"
echo -e ">> Çalışma Dizini  : ${GREEN}$SCRIPT_DIR${NC}"

# İzinleri ayarla
chmod +x auto/clean auto/config auto/build 2>/dev/null || true
chmod +x config/hooks/live/*.hook.chroot 2>/dev/null || true

# Yerel paketleri topla
if [ -f "./collect-local-debs.sh" ]; then
    bash ./collect-local-debs.sh || true
fi

echo -e "\n${BLUE}>> İzole Debian Bookworm ortamı başlatılıyor ve live-build yürütülüyor...${NC}"
echo -e "${YELLOW}>> Not: Chroot ve loop aygıtı bağlama (mount) işlemleri için konteyner '--privileged' modda çalışacaktır.${NC}\n"

$CONTAINER_ENGINE run --rm -it \
    --privileged \
    -v "$SCRIPT_DIR":/workspace \
    -w /workspace \
    -e DEBIAN_FRONTEND=noninteractive \
    debian:bookworm bash -c '
        echo "=== [Konteyner] Gerekli araçlar kuruluyor ===" && \
        apt-get update && \
        apt-get install -y --no-install-recommends \
            live-build \
            debootstrap \
            squashfs-tools \
            xorriso \
            isolinux \
            syslinux-common \
            mtools \
            dosfstools \
            ca-certificates \
            systemd-container && \
        echo "=== [Konteyner] live-build adımları başlatılıyor ===" && \
        lb clean && \
        lb config && \
        lb build 2>&1 | tee build.log && \
        echo "=== [Konteyner] Derleme tamamlandı ==="
    '

echo -e "\n${BLUE}==========================================================${NC}"
ISO_FILE=$(ls -1 *.iso 2>/dev/null | head -n 1 || true)
if [ -n "$ISO_FILE" ] && [ -f "$ISO_FILE" ]; then
    ISO_SIZE=$(ls -lh "$ISO_FILE" | awk '{print $5}')
    echo -e "${GREEN}✓ BAŞARILI! ParsLinux ISO kalıbı üretildi:${NC}"
    echo -e "  Dosya: ${GREEN}$ISO_FILE${NC} ($ISO_SIZE)"
    echo -e "  SHA256: $(sha256sum "$ISO_FILE" | awk '{print $1}')"
else
    echo -e "${YELLOW}ℹ İşlem tamamlandı. ISO durumunu kontrol etmek için dizini ve 'build.log'u inceleyin.${NC}"
fi
echo -e "${BLUE}==========================================================${NC}"
