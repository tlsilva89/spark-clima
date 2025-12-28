#!/bin/bash

echo "=== Desinstalação Spark Clima Backend ==="

INSTALL_DIR="$HOME/.services/spark-clima"
SERVICE_FILE="$HOME/.config/systemd/user/sparkclima.service"

# Parar e desabilitar serviço
systemctl --user stop sparkclima 2>/dev/null || true
systemctl --user disable sparkclima 2>/dev/null || true

# Remover arquivo de serviço
rm -f "$SERVICE_FILE"

# Recarregar systemd
systemctl --user daemon-reload

# Remover diretório de instalação
if [ -d "$INSTALL_DIR" ]; then
    echo "Removendo $INSTALL_DIR..."
    rm -rf "$INSTALL_DIR"
fi

# Remover diretório .services se estiver vazio
if [ -d "$HOME/.services" ] && [ -z "$(ls -A $HOME/.services)" ]; then
    rmdir "$HOME/.services"
fi

echo ""
echo "✅ Desinstalação concluída!"
echo ""
