#!/usr/bin/env bash
set -e

# ==============================================================================
# ParsLinux live-build Derinlemesine Temizlik Betiği (clean.sh)
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo -e "${BLUE}>> [ParsLinux] live-build çalışma alanı temizleniyor...${NC}"

# Eğer root yetkisi varsa veya sudo ise lb clean çalıştır
if [ "$EUID" -eq 0 ] && command -v lb >/dev/null 2>&1; then
    lb clean --purge || true
elif command -v sudo >/dev/null 2>&1 && command -v lb >/dev/null 2>&1; then
    sudo lb clean --purge || true
fi

# auto/ tarafından oluşturulan statik dosyaları temizle
rm -f config/binary \
      config/bootstrap \
      config/chroot \
      config/common \
      config/source \
      build.log \
      .build_lock

# Chroot kalıntılarını güvenle sil (varsa)
if [ -d "chroot" ]; then
    echo -e "${YELLOW}>> Kalan chroot dizini temizleniyor...${NC}"
    if [ "$EUID" -eq 0 ]; then
        umount -lf chroot/dev/pts 2>/dev/null || true
        umount -lf chroot/dev 2>/dev/null || true
        umount -lf chroot/proc 2>/dev/null || true
        umount -lf chroot/sys 2>/dev/null || true
        rm -rf chroot
    elif command -v sudo >/dev/null 2>&1; then
        sudo umount -lf chroot/dev/pts 2>/dev/null || true
        sudo umount -lf chroot/dev 2>/dev/null || true
        sudo umount -lf chroot/proc 2>/dev/null || true
        sudo umount -lf chroot/sys 2>/dev/null || true
        sudo rm -rf chroot
    fi
fi

echo -e "${GREEN}✓ Çalışma alanı sıfırlandı ve temizlendi.${NC}"
