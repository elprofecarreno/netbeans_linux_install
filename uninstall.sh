#!/bin/bash

echo "UNINSTALLING APACHE NETBEANS..."

# Eliminar carpeta de instalación
if [ -d "$HOME/netbeans" ]; then
    echo "REMOVING: $HOME/netbeans"
    rm -rf "$HOME/netbeans"
else
    echo "SKIPPED: $HOME/netbeans not found"
fi

# Eliminar carpeta de configuración y caché
if [ -d "$HOME/.netbeans" ]; then
    echo "REMOVING: $HOME/.netbeans"
    rm -rf "$HOME/.netbeans"
else
    echo "SKIPPED: $HOME/.netbeans not found"
fi

if [ -d "$HOME/.cache/netbeans" ]; then
    echo "REMOVING: $HOME/.cache/netbeans"
    rm -rf "$HOME/.cache/netbeans"
fi

# Eliminar ícono de escritorio
desktop_file="$HOME/.local/share/applications/netbeans.desktop"
if [ -f "$desktop_file" ]; then
    echo "REMOVING: $desktop_file"
    rm -f "$desktop_file"
else
    echo "SKIPPED: $desktop_file not found"
fi

# Actualizar base de datos de íconos del escritorio
echo "UPDATE DESKTOP ICONS"
update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null || true

echo "APACHE NETBEANS UNINSTALLED SUCCESSFULLY."
