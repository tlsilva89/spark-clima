#!/bin/bash

set -e

echo "=== Atualização Spark Clima Backend ==="

INSTALL_DIR="$HOME/.services/spark-clima"

# Verificar se está instalado
if [ ! -d "$INSTALL_DIR" ]; then
    echo "❌ Spark Clima não está instalado em $INSTALL_DIR"
    echo "Execute ./install.sh primeiro"
    exit 1
fi

# Parar serviço
echo "1. Parando serviço..."
systemctl --user stop sparkclima

# Publicar nova versão
echo "2. Publicando nova versão..."
cd backend
dotnet publish -c Release -r linux-x64 --self-contained true \
  /p:PublishSingleFile=true /p:PublishTrimmed=true -o ./publish

# Fazer backup da versão atual
echo "3. Fazendo backup..."
BACKUP_DIR="$INSTALL_DIR.backup.$(date +%Y%m%d_%H%M%S)"
cp -r "$INSTALL_DIR" "$BACKUP_DIR"
echo "   Backup salvo em: $BACKUP_DIR"

# Atualizar arquivos
echo "4. Atualizando arquivos..."
cp -r publish/* "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/ClimatempoBackend"

# Reiniciar serviço
echo "5. Reiniciando serviço..."
systemctl --user start sparkclima

echo ""
echo "✅ Atualização concluída!"
echo ""
echo "Status: systemctl --user status sparkclima"
echo ""
