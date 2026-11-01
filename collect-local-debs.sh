#!/usr/bin/env bash
set -e

# ==============================================================================
# ParsLinux Yerel Paket Toplama Betiği (collect-local-debs.sh)
# Komşu dizinlerdeki ParsLinux meta ve sistem paketlerini tarar, derlenmiş
# .deb paketlerini bularak 'config/packages.chroot/' dizinine kopyalar.
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$SCRIPT_DIR/config/packages.chroot"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"

mkdir -p "$TARGET_DIR"

echo -e "${BLUE}==========================================================${NC}"
echo -e "${BLUE}>> [ParsLinux] Yerel .deb Paketleri Taranıyor...${NC}"
echo -e "   Hedef Dizin : ${GREEN}$TARGET_DIR${NC}"
echo -e "${BLUE}==========================================================${NC}"

# Taranacak kritik paketler listesi
PROJECTS=(
    "pars-desktop-gnome"
    "pars-base"
    "pars-branding"
    "pars-setup"
    "pars-Kurulum-Sihirbazı"
    "parslinux-gnome-settings"
    "parslinux-gnome-greeter"
    "parslinux-about"
    "parslinux-mycomputer"
    "parslinux-shortcuts"
    "parslinux-menus"
    "parslinux-grub-theme"
    "parslinux-software"
    "parslinux-imagewriter"
    "parslinux-formatter"
    "parslinux-package-installer"
    "parslinux-boot-repair"
    "parslinux-nvidia-installer"
    "parslinux-Update"
    "parslinux-welcome"
)

FOUND_COUNT=0

for proj in "${PROJECTS[@]}"; do
    proj_path="$PARENT_DIR/$proj"
    if [ -d "$proj_path" ]; then
        # Dizinde veya build alt dizininde .deb ara
        deb_files=$(find "$proj_path" -maxdepth 3 -type f -name "*.deb" 2>/dev/null || true)
        if [ -n "$deb_files" ]; then
            for deb in $deb_files; do
                echo -e "  [+] Bulundu: ${GREEN}$(basename "$deb")${NC} (Kaynak: $proj)"
                cp -f "$deb" "$TARGET_DIR/"
                FOUND_COUNT=$((FOUND_COUNT + 1))
            done
        else
            echo -e "  [-] ${YELLOW}$proj${NC}: Henüz derlenmiş .deb paketi bulunamadı (APT deposu veya debian/package.sh ile derlenebilir)."
        fi
    fi
done

echo -e "${BLUE}==========================================================${NC}"
if [ "$FOUND_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✓ Toplam $FOUND_COUNT adet yerel .deb paketi başarıyla kopyalandı!${NC}"
    echo -e "  Bu paketler 'lb build' sırasında doğrudan chroot ortamına yüklenecektir."
else
    echo -e "${YELLOW}ℹ Yerel .deb paketi kopyalanmadı. Paketler 'config/archives/parslinux.list.chroot' üzerinden APT deposundan indirilecektir.${NC}"
fi
echo -e "${BLUE}==========================================================${NC}"
