#!/bin/bash

set -e

echo "=== Atualização Spark Clima ==="

INSTALL_DIR="$HOME/.services/spark-clima"
WIDGET_DIR="$(pwd)/frontend"

# Verificar se está instalado
if [ ! -d "$INSTALL_DIR" ]; then
    echo "❌ Spark Clima backend não está instalado em $INSTALL_DIR"
    echo "Execute ./install.sh primeiro"
    exit 1
fi

# Verificar se o frontend existe
if [ ! -d "$WIDGET_DIR" ]; then
    echo "❌ Erro: Diretório frontend não encontrado"
    exit 1
fi

# Parar serviço
echo "1. Parando serviço backend..."
systemctl --user stop sparkclima

# Publicar nova versão do backend
echo "2. Publicando nova versão do backend..."
cd backend
dotnet publish -c Release -r linux-x64 --self-contained true \
  /p:PublishSingleFile=true /p:PublishTrimmed=true -o ./publish
cd ..

# Fazer backup da versão atual
echo "3. Fazendo backup do backend..."
BACKUP_DIR="$INSTALL_DIR.backup.$(date +%Y%m%d_%H%M%S)"
cp -r "$INSTALL_DIR" "$BACKUP_DIR"
echo "   Backup salvo em: $BACKUP_DIR"

# Atualizar arquivos do backend
echo "4. Atualizando arquivos do backend..."
cp -r backend/publish/* "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/ClimatempoBackend"

# Atualizar widget
echo "5. Atualizando widget KDE Plasma..."
kpackagetool6 -t Plasma/Applet -u "$WIDGET_DIR"

# Reiniciar serviço
echo "6. Reiniciando serviço backend..."
systemctl --user start sparkclima

# Reiniciar plasmashell para recarregar widget
echo "7. Reiniciando Plasma Shell..."
read -p "Deseja reiniciar o Plasma Shell agora? (s/N): " resposta
if [[ "$resposta" =~ ^[Ss]$ ]]; then
    killall plasmashell && kstart5 plasmashell &
    echo "   Plasma Shell reiniciado"
else
    echo "   ⚠ Reinicie o Plasma Shell manualmente para aplicar mudanças no widget"
    echo "   Comando: killall plasmashell && kstart5 plasmashell"
fi

echo ""
echo "✅ Atualização concluída!"
echo ""
echo "Status: systemctl --user status sparkclima"
echo ""
