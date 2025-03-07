#!/bin/bash
# Renk tanımlamaları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Renk sıfırlama

# run_block fonksiyonu: Her bloğu açıklama, onay ve komut yürütme ile işler.
run_block() {
    local description="$1"
    local commands="$2"
    local explanation="$3"

    echo -e "${BLUE}------------------------------------------------------${NC}"
    echo -e "${BLUE}Blok: ${YELLOW}$description${NC}"
    echo -e "${GREEN}Çalıştırılacak komut(lar):${NC}"
    echo -e "${GREEN}$commands${NC}"
    echo -e "Çalıştırmak için [y] veya Enter, atlamak için [n], neden yapıldığını görmek için [e] tuşlayın."
    read -r -p "Seçiminiz: " choice

    if [[ "$choice" == "e" ]]; then
        echo -e "${YELLOW}Açıklama: $explanation${NC}"
        read -r -p "Çalıştırmak için [y] veya Enter, atlamak için [n] tuşlayın: " choice
    fi

    if [[ -z "$choice" || "$choice" == "y" ]]; then
        echo -e "${GREEN}Çalıştırılıyor...${NC}"
        # Komutları satır satır çalıştırıyoruz
        while IFS= read -r line; do
            # Boş satırları veya yorum satırlarını atla
            [[ -z "$line" || "$line" =~ ^# ]] && continue
            echo -e "${BLUE}Çalıştırılıyor: ${NC}$line"
            eval "$line"
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Başarılı.${NC}"
            else
                echo -e "${RED}Hata oluştu.${NC}"
            fi
        done <<< "$commands"
    else
        echo -e "${RED}Blok atlandı: $description${NC}"
    fi
    echo -e "${BLUE}------------------------------------------------------${NC}"
    echo ""
}

# -------------------------------
# Diğer sistemsel işlemleri içeren bloklar
# (ör. AppArmor, sistem güncelleme, firmware, Nvidia sürücü güncelleme, Snap/Flatpak işlemleri vs.)
# 1. AppArmor'ı kalıcı olarak devre dışı bırakma
run_block "AppArmor'ı Devre Dışı Bırak" \
"sudo systemctl disable apparmor" \
"Bu komut, AppArmor güvenlik modülünü kalıcı olarak devre dışı bırakır. Bazı uyumluluk veya performans nedenleriyle tercih edilebilir."

# 2. Sistem güncelleme ve bozuk paketleri onarma
run_block "Sistem Güncelleme ve Onarım" \
"sudo apt update
sudo apt upgrade -y
sudo apt install -f
sudo dpkg --configure -a" \
"Bu komutlar; paket listelerini günceller, mevcut güncellemeleri uygular ve paket yapılandırma sorunlarını giderir."

# 3. Firmware güncelleme
run_block "Firmware Güncelleme" \
"sudo apt update
sudo apt install --reinstall linux-firmware" \
"Bu komut, sisteminizdeki firmware paketini yeniden yükleyerek donanımınızın en güncel firmware'ine sahip olmasını sağlar."

# 4. Nvidia sürücülerini güncelleme
run_block "Nvidia Sürücülerini Güncelleme" \
"sudo apt purge nvidia-*
sudo apt install nvidia-driver-XXX" \
"Bu komutlar mevcut Nvidia sürücülerini kaldırıp, sisteminiz için uygun olan sürücüyü yükler. 'nvidia-driver-XXX' kısmını uygun sürüm numarası ile değiştirin."

# 5. Snap paketlerini listeleme ve kaldırma
run_block "Snap Paketlerini Kaldırma (Liste ve Tek Tek)" \
"snap list
sudo snap remove --purge firefox
sudo snap remove --purge gnome-42-2204
sudo snap remove --purge gtk-common-themes
sudo snap remove --purge snap-store
sudo snap remove --purge snapd-desktop-integration
sudo snap remove --purge bare
sudo snap remove --purge core22" \
"Bu komutlar, yüklü Snap paketlerini listeler ve belirli Snap paketlerini sistemden kaldırır."

# 6. Snapd ve bağımlılıklarını kaldırma
run_block "Snapd'yi ve Bağımlılıklarını Kaldırma" \
"sudo apt purge snapd -y
sudo rm -rf /var/snap /snap ~/snap" \
"Bu komutlar Snapd paket yöneticisini ve ilişkili dizinleri sistemden kaldırır."

# 7. Snap ile ilgili systemd servislerini durdurma ve devre dışı bırakma
run_block "Snap Servislerini Durdurma ve Devre Dışı Bırakma" \
"sudo systemctl stop snap-bare-5.mount
sudo systemctl stop snap-core22-1612.mount
sudo systemctl stop snapd.mounts-pre.target
sudo systemctl disable snap-bare-5.mount
sudo systemctl disable snap-core22-1612.mount
sudo systemctl disable snapd.mounts-pre.target
sudo systemctl stop snapd.socket
sudo systemctl stop snapd.service
sudo systemctl disable snapd.socket
sudo systemctl disable snapd.service" \
"Bu komutlar, Snap ile ilişkili systemd servislerini durdurarak otomatik başlatılmalarını engeller."

# 8. Ek Snap kaldırma işlemleri
run_block "Ek Snap Temizliği" \
"sudo apt purge snapd -y
sudo rm -rf /var/snap
sudo rm -rf /snap" \
"Bu komutlar, Snap paket sistemini ve ilişkili dizinleri tamamen temizler."

# 9. Snap'in yeniden kurulmasını engellemek için apt tercihi oluşturma
run_block "Snap Yeniden Kurulumunu Engelle" \
"sudo tee /etc/apt/preferences.d/no-snap.pref > /dev/null <<EOF
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF" \
"Bu komut, /etc/apt/preferences.d/ dizininde no-snap.pref dosyasını oluşturur ve Snapd paketinin yeniden kurulmasını engelleyecek öncelik ayarlarını yapar."

# 10. Kullanıcı dizinindeki Snap klasörünü kaldırma, gereksiz bağımlılıkları temizleme ve sistemi güncelleme
run_block "Snap Klasörlerini Temizleme ve Sistem Güncelleme" \
"sudo rm -rf ~/snap
sudo apt autoremove -y
sudo apt update
sudo apt upgrade -y" \
"Bu komutlar, kullanıcı dizinindeki Snap klasörünü siler, kullanılmayan paketleri temizler ve sistemi günceller."

# 11. Flatpak kurulumu ve Flathub deposunu ekleme
run_block "Flatpak Kurulumu ve Flathub Ekleme" \
"sudo apt install flatpak -y
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo" \
"Bu komutlar, Flatpak paket yöneticisini kurar ve popüler Flathub deposunu ekler."

# -------------------------------
# Arayüz Seçimi
echo -e "${BLUE}------------------------------------------------------${NC}"
echo -e "${BLUE}Hangi arayüzü kullanmak istersiniz?${NC}"
echo -e "${GREEN}[1] Ubuntu GNOME Masaüstü (Varsayılan)${NC}"
echo -e "${GREEN}[2] Eski Ubuntu Arayüzü (Güncelleme ve gnome-software kurulumu)${NC}"
read -r -p "Seçiminiz (1/2): " interface_choice
echo -e "${BLUE}------------------------------------------------------${NC}"
echo ""

if [[ "$interface_choice" == "2" ]]; then
    # Eski Ubuntu arayüzü seçilmişse
    run_block "Eski Ubuntu Arayüzü Kurulumu" \
    "sudo apt update
     sudo apt install --install-suggests gnome-software" \
    "Bu komutlar, sistem paketlerini günceller ve eski Ubuntu arayüzünü (GNOME Software üzerinden) kullanabilmek için gerekli gnome-software paketini kurar."
else
    # Varsayılan olarak GNOME masaüstü kurulumu çalışsın
    run_block "Ubuntu GNOME Masaüstü Kurulumu" \
    "sudo apt update
     sudo apt install ubuntu-gnome-desktop" \
    "Bu komutlar, Ubuntu GNOME masaüstü ortamını sisteminize kurar."
    
    run_block "GNOME Core Kurulumu" \
    "sudo apt install gnome-core" \
    "Bu komut, GNOME masaüstünün temel bileşenlerini kurar."
    
    run_block "GNOME Tweaks ve Uzantıları" \
    "sudo apt install gnome-tweaks gnome-shell-extensions" \
    "Bu komutlar, GNOME için ek düzenleme araçlarını ve shell uzantılarını yükler."
    
    run_block "Ek GNOME Tema ve İkon Paketleri" \
    "sudo apt install adwaita-icon-theme-full gnome-themes-extra gtk2-engines-pixbuf -y" \
    "Bu komut, GNOME masaüstü için ek tema, ikon ve grafik motoru paketlerini kurar."
fi

echo -e "${BLUE}Tüm bloklar tamamlandı.${NC}"
echo ""

# Ubuntu Pro Temizleme İşlemleri
echo -e "${BLUE}------------------------------------------------------${NC}"
echo -e "${BLUE}Bilgisayarınızda Ubuntu Pro kullanıyor musunuz?${NC}"
echo -e "${GREEN}[1] Evet, Ubuntu Pro kullanıyorum.${NC}"
echo -e "${GREEN}[2] Hayır, kullanmıyorum.${NC}"
read -r -p "Seçiminiz (1/2): " ubuntu_pro_choice
echo -e "${BLUE}------------------------------------------------------${NC}"
echo ""

if [[ "$ubuntu_pro_choice" == "1" ]]; then
    run_block "Ubuntu Pro Temizleme" \
    "sudo apt purge ubuntu-advantage-tools -y
sudo rm -rf /var/lib/ubuntu-advantage/ubuntu_pro_esm_cache
echo -e \"\${YELLOW}Lütfen /etc/apt/sources.list dosyasını açın ve 'esm' veya 'ubuntu-pro' içeren satırları manuel olarak kaldırın. İşlemi tamamladıktan sonra Enter'a basın.\"
read -r -p \"Devam etmek için Enter'a basın...\" 
sudo rm /etc/apt/sources.list.d/ubuntu-pro-*.list
sudo apt update
sudo apt autoremove --purge -y
ls -l /var/lib/update-notifier
sudo rm -r /var/lib/update-notifier
sudo apt install --reinstall ubuntu-release-upgrader-core -y
sudo apt purge ubuntu-release-upgrader-core -y
sudo apt autoremove --purge -y" \
    "Ubuntu Pro, gereksizdir ve diğer paketlerle uyumsuzluk yaratabilir. Özellikle 'ubuntu-advantage-tools' ve ilgili cache dosyaları sistemde sorunlara neden olabilmektedir. Bu adımlarla Ubuntu Pro ile ilgili araçlar ve ek dosyalar temizlenir."
else
    echo -e "${GREEN}Ubuntu Pro temizleme işlemi atlandı.${NC}"
fi

echo -e "${BLUE}Script tamamlandı. Sisteminiz güncellendi ve tercihleriniz uygulanmıştır.${NC}"
