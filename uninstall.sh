#!/bin/bash

echo "=== Desinstalação Spark Clima ==="

INSTALL_DIR="$HOME/.services/spark-clima"
SERVICE_FILE="$HOME/.config/systemd/user/sparkclima.service"
WIDGET_ID="dev.digitalspark.sparkclima"

# Remover widget KDE Plasma
echo "1. Removendo widget KDE Plasma..."
kpackagetool6 -t Plasma/Applet -r "$WIDGET_ID" 2>/dev/null || echo "   Widget não estava instalado"

# Parar e desabilitar serviço backend
echo "2. Parando e desabilitando serviço backend..."
systemctl --user stop sparkclima 2>/dev/null || true
systemctl --user disable sparkclima 2>/dev/null || true

# Remover arquivo de serviço
echo "3. Removendo arquivo de serviço..."
rm -f "$SERVICE_FILE"

# Recarregar systemd
systemctl --user daemon-reload

# Remover diretório de instalação do backend
if [ -d "$INSTALL_DIR" ]; then
    echo "4. Removendo $INSTALL_DIR..."
    rm -rf "$INSTALL_DIR"
fi

# Remover backups antigos
BACKUP_COUNT=$(find "$HOME/.services" -maxdepth 1 -name "spark-clima.backup.*" 2>/dev/null | wc -l)
if [ "$BACKUP_COUNT" -gt 0 ]; then
    read -p "Encontrados $BACKUP_COUNT backup(s). Deseja removê-los? (s/N): " resposta
    if [[ "$resposta" =~ ^[Ss]$ ]]; then
        rm -rf "$HOME/.services/spark-clima.backup."*
        echo "   Backups removidos"
    fi
fi

# Remover diretório .services se estiver vazio
if [ -d "$HOME/.services" ] && [ -z "$(ls -A $HOME/.services)" ]; then
    rmdir "$HOME/.services"
fi

# Perguntar sobre reiniciar Plasma Shell
echo ""
read -p "Deseja reiniciar o Plasma Shell agora? (s/N): " resposta
if [[ "$resposta" =~ ^[Ss]$ ]]; then
    killall plasmashell && kstart5 plasmashell &
    echo "Plasma Shell reiniciado"
fi

echo ""
echo "✅ Desinstalação concluída!"
echo ""
