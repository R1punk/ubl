#!/bin/bash

# Warna ANSI untuk tampilan menarik
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
CYAN='\e[36m'
WHITE='\e[97m'
BOLD='\e[1m'
RESET='\e[0m'


# Warna ANSI
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
CYAN='\e[36m'
WHITE='\e[97m'
BOLD='\e[1m'
RESET='\e[0m'
banner() {
	echo -e "${BOLD}${CYAN}"
	echo ".             ██████╗ ██╗██████╗ ██╗   ██╗███╗   ██╗██╗  ██╗" 
 	echo ".             ██╔══██╗██║██╔══██╗██║   ██║████╗  ██║██║ ██╔╝"
 	echo ".             ██████╔╝██║██████╔╝██║   ██║██╔██╗ ██║█████╔╝ "
 	echo ".             ██╔══██╗██║██╔═══╝ ██║   ██║██║╚██╗██║██╔═██╗ "
	echo ".             ██║  ██║██║██║     ╚██████╔╝██║ ╚████║██║  ██╗"
 	echo ".             ╚═╝  ╚═╝╚═╝╚═╝      ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝ "
    echo -e "                   ${YELLOW}Unlock Bootloader Xiaomi via Termux${RESET}"
    echo ""
}

# URL unduhan
URL_GET_TOKEN="https://raw.githubusercontent.com/RohitVerma882/termux-miunlock/refs/heads/main/get_token.jar"
URL_ADB_FASTBOOT="https://raw.githubusercontent.com/nohajc/nohajc.github.io/master/dists/termux/extras/binary-aarch64"
URL_LIBPROTOBUF="${URL_ADB_FASTBOOT}/libprotobuf-tadb-core_2%3A25.1-2_aarch64.deb"
URL_TERMUX_ADB="${URL_ADB_FASTBOOT}/termux-adb_0.2.3_aarch64.deb"
URL_TERMUX_API="https://f-droid.org/repo/com.termux.api_51.apk"
#libprotobuf_pkg="libprotobuf-tadb-core_2%3A25.1-2_${arch}.deb"
#adb_pkg="termux-adb_0.2.2-2_${arch}.deb"
YOUTUBE_URL="https://www.youtube.com/c/Ripunk"

# Fungsi cek koneksi internet
check_internet() {
    echo -e "${CYAN}🌐 Memeriksa koneksi internet...${RESET}"
    if ! ping -c 1 google.com &> /dev/null; then
        echo -e "${RED}❌ Tidak ada koneksi internet. Periksa koneksi Anda!${RESET}"
        exit 1
    fi
    echo -e "${GREEN}✅ Koneksi internet tersedia!${RESET}"
}

# Fungsi pemberitahuan suara/pop-up
notify() {
    local message="$1"
    if [[ "$PREFIX" == "/data/data/com.termux/files/usr" ]]; then
        termux-notification --title "Ripunk MiUnlock" --content "$message"
        termux-vibrate
    else
        if command -v notify-send &> /dev/null; then
            notify-send "Ripunk MiUnlock" "$message"
        fi
        paplay /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null || echo -e "\a"
    fi
}

# Fungsi download dengan progress bar dan retry
download_with_retry() {
    local url="$1"
    local output="$2"
    local max_retries=5
    local delay=5

    for ((i=1; i<=max_retries; i++)); do
        echo -e "${YELLOW}📥 Mengunduh ${WHITE}pakage pendukung ${YELLOW}(Percobaan: $i/$max_retries)...${RESET}"
        if curl -L --progress-bar -o "$output" "$url" > /dev/null; then 
            if [[ -s "$output" && $(stat -c%s "$output") -gt 1000 ]]; then
                echo -e "${GREEN}✅ pakage pendukung berhasil diunduh!${RESET}"
                return 0
            else
                echo -e "${RED}❌ File pakage pendukung rusak atau tidak valid.${RESET}"
                rm -f "$output"
            fi
        fi
        echo -e "${RED}❌ Gagal mengunduh pakage pendukung. Mencoba lagi dalam $delay detik...${RESET}"
        sleep "$delay"
    done

    echo -e "${RED}❌ Gagal mengunduh pakage pendukung setelah $max_retries percobaan.${RESET}"
    exit 1
}
# Fungsi cek dan install termux-api CLI di Termux
install_termux_api_cli() {
    if ! command -v termux-notification &> /dev/null; then
        echo -e "${CYAN}📦 Menginstal termux-api CLI...${RESET}"
        apt install termux-api -y
        echo -e "${GREEN}✅ termux-api CLI terinstal!${RESET}"
        notify "termux-api CLI siap digunakan!"
    else
        echo -e "${GREEN}✅ termux-api CLI sudah terpasang!${RESET}"
    fi
}

# Fungsi cek install jaba
install_java() {
    if ! command -v java &> /dev/null; then
        echo -e "${CYAN}📦 Menginstal java...${RESET}"
        apt install openjdk-17 -y
        echo -e "${GREEN}✅ java terinstal!${RESET}"
        notify "java siap digunakan!"
    else
        echo -e "${GREEN}✅ java sudah terpasang!${RESET}"
    fi
}

#Fungsi install package pendukung di Termux
install_termux_dependencies() {
    echo -e "${CYAN}📦 Memeriksa package pendukung di Termux...${RESET}"
    #pkg update -y
    
    for pkg in curl wget  ; do
        if ! command -v "$pkg" &> /dev/null; then
            echo -e "${YELLOW}📦 Menginstal $pkg...${RESET}"
            apt install "$pkg" -y
        else
            echo -e "${GREEN}✅ $pkg sudah terpasang.${RESET}"
        fi
    done
}

# Fungsi install package pendukung di Termux
iinstall_termux_dependencies() {
    echo -e "${CYAN}📦 Menginstal package pendukung di Termux...${RESET}"
    pkg update -y
    pkg install -y curl wget openjdk-17 termux-api
}

# Fungsi install package pendukung di Linux
install_linux_dependencies() {
    echo -e "${CYAN}📦 Menginstal package pendukung di Linux...${RESET}"
    sudo apt update
    sudo apt install -y curl wget openjdk-17-jdk android-tools-fastboot adb
}

# Fungsi instalasi get_token.jar
install_get_token() {
    local jar_path="$PREFIX/bin/get_token.jar"

    if [[ ! -f "$jar_path" || $(stat -c%s "$jar_path") -lt 1000 ]]; then
        echo -e "${CYAN}📥 Mengunduh pakage pendukung ...${RESET}"
        download_with_retry "$URL_GET_TOKEN" "$jar_path"
        chmod +x "$jar_path"
    fi

    # Membuat symlink untuk mempermudah eksekusi
    local symlink_path="$PREFIX/bin/get_token"
    echo -e '#!/bin/bash\njava -jar "'$jar_path'" "$@"' > "$symlink_path"
    chmod +x "$symlink_path"
}

# Fungsi instalasi mi-fastboot di Termux
install_adb_fastboot_termux() {
  if ! command -v adb &> /dev/null; then
    echo -e "${CYAN}📥 Mengunduh dan menginstal adb-fastboot...${RESET}"
    
    #download_with_retry "$URL_LIBPROTOBUF" "libprotobuf.deb"
    #dpkg --force-overwrite -i "libprotobuf.deb"
    #apt --fix-broken install -y
    #rm -f "libprotobuf.deb"

    download_with_retry "$URL_TERMUX_ADB" "termux-adb.deb"
    dpkg --force-overwrite -i "termux-adb.deb"
    apt --fix-broken install -y
    rm -f "termux-adb.deb"

    # Membuat alias untuk adb dan fastboot
    ln -sf "$PREFIX/bin/termux-adb" "$PREFIX/bin/adb"
    ln -sf "$PREFIX/bin/termux-fastboot" "$PREFIX/bin/fastboot"

    if adb version &> /dev/null; then
        echo -e "${GREEN}✅ ADB dan Fastboot berhasil diinstal!${RESET}"
    else
        echo -e "${RED}❌ Gagal menginstal ADB dan Fastboot!${RESET}"
        exit 1
    fi
  else
            echo -e "${GREEN}✅ adb-fastboot sudah terpasang...${RESET}"
   fi
}
# Fungsi cek dan install Termux API APK
install_termux_api_apk() {
echo -e "${CYAN}📲 Memeriksa aplikasi Termux:API di perangkat...${RESET}"
    
    # Menjalankan termux-battery-status dengan timeout 5 detik
    if timeout 5s termux-battery-status &> /dev/null; then
        echo -e "${GREEN}✅ Termux:API.apk sudah terpasang dan berfungsi!${RESET}"
        return 0
    else
        echo -e "${YELLOW}⚠️ Termux:API.apk tidak terpasang atau tidak berfungsi!${RESET}"
        
        # Mengunduh dan membuka APK menggunakan xdg-open
        echo -e "${CYAN}📥 Membuka halaman unduhan Termux:API.apk...${RESET}"
        xdg-open "$URL_TERMUX_API" &> /dev/null
        
        # Konfirmasi manual setelah instalasi APK
        while true; do
            echo -e "${YELLOW}❓ Apakah Anda sudah menginstal Termux:API.apk? (y/n)${RESET}"
            read -r -p "Pilihan Anda: " answer
            case "$answer" in
                [Yy]* ) 
                    echo -e "${CYAN}🔄 Mengulangi pengecekan Termux:API...${RESET}"
                    install_termux_api_apk
                    break
                    ;;
                [Nn]* ) 
                    echo -e "${RED}❌ Proses dihentikan. Silakan pasang Termux:API.apk terlebih dahulu!${RESET}"
                    exit 1
                    ;;
                * ) 
                    echo -e "${RED}❗ Masukkan 'y' untuk Ya atau 'n' untuk Tidak.${RESET}"
                    ;;
            esac
        done
    fi
}

# Fungsi membuka YouTube
open_youtube() {
    echo -e "${BOLD}${WHITE}🎬 JANGAN LUPA SUBSCRIBE DULU. BANTU 10K SUBSCRIBE!${RESET}"
    sleep 5
    echo -e "${CYAN}🎬 Membuka YouTube...${RESET}"
    xdg-open "$YOUTUBE_URL" 
    notify "SUBCRIBE RIPUNK!"
}

# Pengecekan dan instalasi otomatis sesuai lingkungan
check_and_install() {
    #check_internet
    arch=$(dpkg --print-architecture)
    echo -e "\nArsitektur terdeteksi: $arch"
    if [[ "$PREFIX" == "/data/data/com.termux/files/usr" ]]; then
        echo -e "${BLUE}📱 Deteksi: Termux${RESET}"
        install_termux_dependencies
	     install_termux_api_cli
        install_termux_api_apk
       install_java
        install_get_token
        install_adb_fastboot_termux
    else
        echo -e "${BLUE}💻 Deteksi: Linux${RESET}"
        install_linux_dependencies
        install_get_token
    fi

    open_youtube
}

# Eksekusi instalasi otomatis
check_and_install
sleep 5
clear
banner
#==========================================================#


set -e  # Hentikan skrip jika ada error fatal (kecuali dalam perulangan manual)

DATAFILE="miunlockdata.json"

save_data() {
    echo "$1" > "$DATAFILE"
}

remove_key() {
    echo "❌ Invalid $1"
    jq "del(.$1)" "$DATAFILE" > tmp.json && mv tmp.json "$DATAFILE"
}

while true; do
    if [[ -f "$DATAFILE" ]]; then
        DATA=$(cat "$DATAFILE")
    else
        DATA="{}"
    fi

    USER=$(echo "$DATA" | jq -r '.user // empty')
    PWD=$(echo "$DATA" | jq -r '.pwd // empty')
    WB_ID=$(echo "$DATA" | jq -r '.wb_id // empty')

    # Input Username
    while [[ -z "$USER" ]]; do
        read -p "👤 Xiaomi Account (Email/Phone): " USER
        if [[ -z "$USER" ]]; then
            echo "❌ Username tidak boleh kosong!"
        else
            DATA=$(echo "$DATA" | jq --arg user "$USER" '. + {user: $user}')
            save_data "$DATA"
        fi
    done

    # Input Password
    while [[ -z "$PWD" ]]; do
        read -s -p "🔑 Enter password: " PWD
        echo
        if [[ -z "$PWD" ]]; then
            echo "❌ Password tidak boleh kosong!"
        else
            DATA=$(echo "$DATA" | jq --arg pwd "$PWD" '. + {pwd: $pwd}')
            save_data "$DATA"
        fi
    done

    LOGIN_URL="https://account.xiaomi.com/pass/serviceLogin?sid=unlockApi&checkSafeAddress=true"

    # Input WB_ID jika belum ada
    if [[ -z "$WB_ID" ]]; then
        echo -e "\n🔵 Silakan login di browser untuk mendapatkan WB_ID..."
        xdg-open "$LOGIN_URL"
	clear
	banner
        read -p "🌏 Masukkan URL lengkap setelah login: " LOGIN_RESPONSE_URL

        WB_ID=$(echo "$LOGIN_RESPONSE_URL" | grep -o 'd=wb_[^&]*' | cut -d'=' -f2)

        if [[ -z "$WB_ID" ]]; then
            echo "❌ WB_ID tidak ditemukan! Pastikan URL yang dimasukkan benar."
            continue  # Mengulang login jika WB_ID tidak ditemukan
        fi

        echo "✅ WB_ID berhasil diekstrak: $WB_ID"

        DATA=$(echo "$DATA" | jq --arg wb_id "$WB_ID" '. + {wb_id: $wb_id}')
        save_data "$DATA"
    fi

    PWD_HASH=$(echo -n "$PWD" | md5sum | awk '{print toupper($1)}')

    # Mencoba login
    echo "🔄 Mencoba login ke Xiaomi..."
    LOGIN_RESPONSE=$(curl -s -X POST "https://account.xiaomi.com/pass/serviceLoginAuth2?sid=unlockApi&_json=true" \
        -d "user=$USER&hash=$PWD_HASH" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -b "deviceId=$WB_ID")

    CLEAN_RESPONSE=$(echo "$LOGIN_RESPONSE" | sed 's/&&&START&&&//g')

    USER_ID=$(echo "$CLEAN_RESPONSE" | jq -r '.userId // empty')
    SSECURITY=$(echo "$CLEAN_RESPONSE" | jq -r '.ssecurity // empty')
    PASS_TOKEN=$(echo "$CLEAN_RESPONSE" | jq -r '.passToken // empty')
    LOCATION=$(echo "$CLEAN_RESPONSE" | jq -r '.location // empty')

    device_id=$(echo "$LOCATION" | awk -F'd=' '{print $2}' | awk -F'&' '{print $1}')

    NONCE=$(echo "$CLEAN_RESPONSE" | jq -r '.nonce | tostring')

    if [[ -z "$PASS_TOKEN" ]]; then
        echo "❌ Login gagal! Periksa kembali akun Anda atau password mungkin salah."
        echo "ℹ️ Respons Server: $(echo "$CLEAN_RESPONSE" | jq -r '.description // "Tidak ada deskripsi error"')"
        continue  # Mengulang login jika gagal
    fi

    echo "✅ Login berhasil! User ID: $USER_ID"

    CLIENT_SIGN=$(echo -n "nonce=$NONCE&$SSECURITY" | sha1sum | awk '{print $1}' | base64)

    echo "🔄 Meminta serviceToken..."
    SERVICE_RESPONSE=$(curl -s -L "${LOCATION}&clientSign=${CLIENT_SIGN}" -c cookies.txt)

    SERVICE_TOKEN=$(cat cookies.txt | grep "serviceToken" | awk '{print $7}')

    if [[ -z "$SERVICE_TOKEN" ]]; then
        echo "❌ Gagal mendapatkan serviceToken. Pastikan login Anda valid."
        continue  # Mengulang login jika serviceToken gagal
    fi

    echo "✅ serviceToken berhasil didapatkan!"

    if ! mi-fastboot devices | grep -qE 'fastboot$'; then
        echo "❌ Perangkat tidak terdeteksi dalam mode Fastboot!"
        continue  # Mengulang jika perangkat tidak dalam mode fastboot
    fi

    echo "🔍 Mengambil informasi perangkat..."
    product=$(mi-fastboot getvar product 2>&1 | grep 'product:' | cut -d ' ' -f2)

    if [[ -n $product ]]; then
        token=$(mi-fastboot getvar token 2>&1 | grep token: | sed 's|.*token: ||g' | tr -d '\n')

        if [[ -z $token ]]; then
            token=$(mi-fastboot oem get_token 2>&1 | grep token: | sed 's|.*token: ||g' | tr -d '\n')
        fi
    fi

    SoC="Mediatek"
    [[ -n "$token" ]] && SoC="Qualcomm"

    echo -e "\n✅ **Device Info**"
    echo "⚙ SoC: $SoC"
    echo "📱 Product: $product"
    echo "🔑 Token: $token"

    data=$(jq -cn --arg passToken "$PASS_TOKEN" --arg userId "$USER_ID" --arg deviceId "$device_id" \
      '{"passToken":$passToken, "userId":$userId, "deviceId":$deviceId}' | xxd -p | tr -d '\n')

    javaOutput=$(java -jar get_token.jar --region=global --product="$product" --token="$token" "$data" 2>&1)

    unlockToken=$(echo "$javaOutput" | grep "Unlock device token:" | sed 's|.*Unlock device token: ||g')
    error=$(echo "$javaOutput" | grep -E -w "SEVERE: | Server description:")

    if [[ -z $unlockToken ]]; then
        echo "❌ Gagal mendapatkan unlock token."
        echo "ℹ️ Error: $error"
	exit
#        continue  # Mengulang jika unlockToken gagal
    fi

    echo "$unlockToken" | xxd -r -p > ~/.cache/token.bin
    mi-fastboot stage ~/.cache/token.bin
    mi-fastboot oem unlock

    break  # Keluar dari perulangan setelah proses selesai
done
