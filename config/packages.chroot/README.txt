# ==============================================================================
# config/packages.chroot/ Dizin Rehberi
# ==============================================================================

Bu dizin, harici bir depoya yüklemeden doğrudan canlı ISO içerisine gömmek istediğiniz 
tüm yerel Debian paketleri (.deb) içindir.

Örnek olarak şu yerel paketler buraya kopyalandığında canlı sisteme otomatik kurulur:
- pars-desktop-gnome_*.deb
- pars-base_*.deb
- pars-branding_*.deb
- pars-setup_*.deb
- parslinux-gnome-settings_*.deb
- parslinux-about_*.deb
- parslinux-mycomputer_*.deb
- vb.

İpucu: Bu kopyalamayı projenin ana dizinindeki './collect-local-debs.sh' betiği ile 
tek tıkla otomatik olarak gerçekleştirebilirsiniz!
