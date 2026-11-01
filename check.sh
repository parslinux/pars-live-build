#!/usr/bin/env bash
set -e

# ==============================================================================
# ParsLinux live-build Bütünlük ve Sözdizimi Denetim Betiği (check.sh)
# Tüm live-build yapılandırmasının, betiklerin ve paket listelerinin eksiksizliğini test eder.
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ERRORS=0

echo -e "${BLUE}==========================================================${NC}"
echo -e "${BLUE}  🐆 ParsLinux live-build Yapılandırma Denetimi (Check)   ${NC}"
echo -e "${BLUE}==========================================================${NC}"

# 1. auto/ Betikleri Denetimi
echo -e "\n${BLUE}=== [1/5] auto/ Betikleri ve Çalıştırılabilirlik Denetimi ===${NC}"
AUTO_SCRIPTS=("auto/clean" "auto/config" "auto/build")
for script in "${AUTO_SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        if sh -n "$script" 2>/dev/null; then
            echo -e "  [✓] $script sözdizimi geçerli."
        else
            echo -e "  [✗] ${RED}$script dosyasında sözdizimi hatası var!${NC}"
            ERRORS=$((ERRORS + 1))
        fi
        chmod +x "$script"
    else
        echo -e "  [✗] ${RED}$script dosyası bulunamadı!${NC}"
        ERRORS=$((ERRORS + 1))
    fi
done

# 2. Paket Listeleri Denetimi
echo -e "\n${BLUE}=== [2/5] config/package-lists/ Denetimi ===${NC}"
PKG_LIST_DIR="config/package-lists"
if [ -d "$PKG_LIST_DIR" ]; then
    echo -e "  [✓] $PKG_LIST_DIR dizini mevcut."
    if [ -f "$PKG_LIST_DIR/pars-desktop-gnome.list.chroot" ]; then
        echo -e "  [✓] pars-desktop-gnome.list.chroot mevcut."
        if grep -q "^pars-desktop-gnome" "$PKG_LIST_DIR/pars-desktop-gnome.list.chroot"; then
            echo -e "  [✓] 'pars-desktop-gnome' meta paketi başarıyla bağlanmış."
        else
            echo -e "  [✗] ${RED}'pars-desktop-gnome' meta paketi listede bulunamadı!${NC}"
            ERRORS=$((ERRORS + 1))
        fi
    else
        echo -e "  [✗] ${RED}pars-desktop-gnome.list.chroot bulunamadı!${NC}"
        ERRORS=$((ERRORS + 1))
    fi
    for list in "$PKG_LIST_DIR"/*.list.chroot; do
        if [ -f "$list" ]; then
            count=$(grep -v "^#" "$list" | grep -v "^$" | wc -l)
            echo -e "      -> $(basename "$list"): $count paket tanımlı."
        fi
    done
else
    echo -e "  [✗] ${RED}$PKG_LIST_DIR dizini bulunamadı!${NC}"
    ERRORS=$((ERRORS + 1))
fi

# 3. Kancalar (Hooks) Denetimi
echo -e "\n${BLUE}=== [3/5] config/hooks/live/ Kancaları Denetimi ===${NC}"
HOOK_DIR="config/hooks/live"
if [ -d "$HOOK_DIR" ]; then
    for hook in "$HOOK_DIR"/*.hook.chroot; do
        if [ -f "$hook" ]; then
            if sh -n "$hook" 2>/dev/null; then
                echo -e "  [✓] $(basename "$hook") sözdizimi geçerli."
            else
                echo -e "  [✗] ${RED}$(basename "$hook") sözdizimi hatalı!${NC}"
                ERRORS=$((ERRORS + 1))
            fi
            chmod +x "$hook"
        fi
    done
else
    echo -e "  [✗] ${RED}$HOOK_DIR bulunamadı!${NC}"
    ERRORS=$((ERRORS + 1))
fi

# 4. config/includes.chroot/ ve config/includes.binary/ Denetimi
echo -e "\n${BLUE}=== [4/5] Chroot ve Binary Katmanları Denetimi ===${NC}"
REQUIRED_FILES=(
    "config/includes.chroot/etc/os-release"
    "config/includes.chroot/etc/issue"
    "config/includes.chroot/etc/hostname"
    "config/includes.chroot/etc/hosts"
    "config/includes.chroot/etc/live/config.conf.d/01-parslinux.conf"
    "config/includes.chroot/etc/sudoers.d/99-parslinux-live"
    "config/includes.chroot/etc/polkit-1/rules.d/99-parslinux-live.rules"
    "config/includes.chroot/etc/gdm3/daemon.conf"
    "config/includes.chroot/etc/skel/Desktop/org.parslinux.setup.desktop"
    "config/includes.binary/.disk/info"
    "config/includes.binary/.disk/cd_type"
    "config/includes.binary/README.txt"
    "config/bootloaders/grub-pc/grub.cfg"
    "config/bootloaders/isolinux/menu.cfg"
)

for req in "${REQUIRED_FILES[@]}"; do
    if [ -f "$req" ]; then
        echo -e "  [✓] $req mevcut."
    else
        echo -e "  [✗] ${RED}$req eksik!${NC}"
        ERRORS=$((ERRORS + 1))
    fi
done

# 5. Derleme Yardımcı Betikleri Denetimi
echo -e "\n${BLUE}=== [5/5] Yardımcı Araçlar ve Derleme Betikleri Denetimi ===${NC}"
TOOL_SCRIPTS=("build.sh" "docker-build.sh" "clean.sh" "collect-local-debs.sh")
for tool in "${TOOL_SCRIPTS[@]}"; do
    if [ -f "$tool" ]; then
        if bash -n "$tool" 2>/dev/null; then
            echo -e "  [✓] $tool sözdizimi geçerli."
        else
            echo -e "  [✗] ${RED}$tool betiğinde hata var!${NC}"
            ERRORS=$((ERRORS + 1))
        fi
        chmod +x "$tool"
    else
        echo -e "  [✗] ${RED}$tool bulunamadı!${NC}"
        ERRORS=$((ERRORS + 1))
    fi
done

echo -e "\n${BLUE}==========================================================${NC}"
if [ "$ERRORS" -eq 0 ]; then
    echo -e "${GREEN}✓ TÜM YAPILANDIRMA VE SÖZDİZİMİ TESTLERİ BAŞARIYLA GEÇTİ!${NC}"
    echo -e "  live-build altyapısı ParsLinux için eksiksiz hazırlandı."
    echo -e "${BLUE}==========================================================${NC}"
    exit 0
else
    echo -e "${RED}✗ Toplam $ERRORS hata tespit edildi. Lütfen yukarıdaki maddeleri kontrol edin.${NC}"
    echo -e "${BLUE}==========================================================${NC}"
    exit 1
fi
