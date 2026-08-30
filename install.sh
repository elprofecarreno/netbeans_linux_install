#!/bin/bash
# Apache NetBeans Linux Installer with Oracle JDK

detect_package_manager() {
    if command -v apt-get >/dev/null 2>&1; then
        echo "apt"
    elif command -v dnf >/dev/null 2>&1; then
        echo "dnf"
    elif command -v yum >/dev/null 2>&1; then
        echo "yum"
    elif command -v pacman >/dev/null 2>&1; then
        echo "pacman"
    elif command -v zypper >/dev/null 2>&1; then
        echo "zypper"
    elif command -v apk >/dev/null 2>&1; then
        echo "apk"
    else
        echo "unknown"
    fi
}

install_dependencies_if_missing() {
    missing_pkgs=()
    if ! command -v curl >/dev/null 2>&1; then
        missing_pkgs+=("curl")
    fi
    if ! command -v unzip >/dev/null 2>&1; then
        missing_pkgs+=("unzip")
    fi

    if [ ${#missing_pkgs[@]} -eq 0 ]; then
        return 0
    fi

    pkg_manager=$(detect_package_manager)
    echo "Dependencias faltantes: ${missing_pkgs[*]}. Instalando con: $pkg_manager"

    if [ "$(id -u)" -eq 0 ]; then
        SUDO_CMD=""
    else
        SUDO_CMD="sudo"
    fi

    case "$pkg_manager" in
        apt)
            $SUDO_CMD apt-get update && $SUDO_CMD apt-get install -y "${missing_pkgs[@]}"
            ;;
        dnf)
            $SUDO_CMD dnf install -y "${missing_pkgs[@]}"
            ;;
        yum)
            $SUDO_CMD yum install -y "${missing_pkgs[@]}"
            ;;
        pacman)
            $SUDO_CMD pacman -Sy --noconfirm "${missing_pkgs[@]}"
            ;;
        zypper)
            $SUDO_CMD zypper --non-interactive install "${missing_pkgs[@]}"
            ;;
        apk)
            $SUDO_CMD apk add --no-cache "${missing_pkgs[@]}"
            ;;
        *)
            echo "No se detecto un gestor de paquetes soportado. Instala ${missing_pkgs[*]} manualmente y vuelve a ejecutar el script."
            return 1
            ;;
    esac
}

# LOAD CONFIGURATION
if [ -f "./config.env" ]; then
    . ./config.env
else
    echo "ERROR: config.env no encontrado en el directorio actual."
    exit 1
fi

install_dependencies_if_missing || exit 1

if [ -z "$URL_NETBEANS" ]; then
    echo "ERROR: URL_NETBEANS no esta definida en config.env"
    exit 1
fi

if [ -z "$URL_JDK" ]; then
    echo "ERROR: URL_JDK no esta definida en config.env"
    exit 1
fi

echo "CLEANING PREVIOUS INSTALL TEMPORARY FILES & DESTINATION"
rm -rf netbeans.zip jdk.tar.gz netbeans jdk-*
rm -rf "$HOME/netbeans"

echo "START DOWNLOAD NETBEANS: $URL_NETBEANS"
curl -L -S -o netbeans.zip "$URL_NETBEANS"
echo "FINISH DOWNLOAD NETBEANS"

if [ ! -f "netbeans.zip" ]; then
    echo "ERROR: DOWNLOADING NETBEANS FAILED"
    exit 1
fi

echo "UNZIP NETBEANS"
unzip -q netbeans.zip

if [ ! -d "netbeans" ]; then
    echo "ERROR: UNZIP NETBEANS FAILED"
    exit 1
fi

echo "MOVING NETBEANS TO $HOME/netbeans"
mv netbeans "$HOME/netbeans"

echo "START DOWNLOAD JDK: $URL_JDK"
curl -L -S -o jdk.tar.gz "$URL_JDK"
echo "FINISH DOWNLOAD JDK"

if [ ! -f "jdk.tar.gz" ]; then
    echo "ERROR: DOWNLOADING JDK FAILED"
    exit 1
fi

echo "EXTRACTING JDK"
tar -xzf jdk.tar.gz
jdk_dir=$(tar -tf jdk.tar.gz | head -1 | cut -f1 -d"/")

if [ -z "$jdk_dir" ] || [ ! -d "$jdk_dir" ]; then
    echo "ERROR EXTRACTING JDK"
    exit 1
fi

echo "MOVING JDK ($jdk_dir) TO $HOME/netbeans/"
mv "$jdk_dir" "$HOME/netbeans/"
echo "JDK COPIED SUCCESSFULLY"

conf_file="$HOME/netbeans/etc/netbeans.conf"
jdk_path="\$HOME/netbeans/$jdk_dir"

if [ -f "$conf_file" ]; then
    echo "CONFIGURING JDK HOME IN $conf_file"
    if grep -q "^#*netbeans_jdkhome=" "$conf_file"; then
        sed -i "s|^#*netbeans_jdkhome=.*|netbeans_jdkhome=\"$jdk_path\"|" "$conf_file"
    else
        echo "netbeans_jdkhome=\"$jdk_path\"" >> "$conf_file"
    fi
    echo "netbeans.conf UPDATED"
else
    echo "WARNING: $conf_file NOT FOUND"
fi

echo "CREATING DESKTOP SHORTCUT"
if [ -f "netbeans.desktop.template" ]; then
    cp netbeans.desktop.template netbeans.desktop
    sed -i "s|\$HOME|$HOME|g" netbeans.desktop
    mkdir -p "$HOME/.local/share/applications"
    mv netbeans.desktop "$HOME/.local/share/applications/netbeans.desktop"
    chmod +x "$HOME/.local/share/applications/netbeans.desktop"
    update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null || true
    echo "DESKTOP SHORTCUT INSTALLED TO $HOME/.local/share/applications/netbeans.desktop"
else
    echo "ERROR: netbeans.desktop.template NOT FOUND"
fi

echo "CLEANING UP ARCHIVES"
rm -f netbeans.zip jdk.tar.gz

echo "APACHE NETBEANS INSTALLATION COMPLETED SUCCESSFULLY!"
