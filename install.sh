#!/bin/bash

set -e

echo "=== Instalação Spark Clima ==="

# Diretórios
INSTALL_DIR="$HOME/.services/spark-clima"
SERVICE_DIR="$HOME/.config/systemd/user"
WIDGET_DIR="$(pwd)/frontend"

# Verificar se o frontend existe
if [ ! -d "$WIDGET_DIR" ]; then
    echo "❌ Erro: Diretório frontend não encontrado"
    exit 1
fi

# Verificar se porta 5234 está livre
if ss -tulpn | grep -q ":5234"; then
    echo "❌ Erro: Porta 5234 já está em uso"
    echo "Execute: killall -9 dotnet"
    echo "Ou: lsof -i :5234 para ver o processo"
    exit 1
fi

# Publicar aplicação backend
echo "1. Publicando backend..."
cd backend
dotnet publish -c Release -r linux-x64 --self-contained true \
  /p:PublishSingleFile=true -o ./publish
cd ..

# Criar diretório de instalação
echo "2. Criando diretório $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
cp -r backend/publish/* "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/ClimatempoBackend"

# Criar diretório para serviços do usuário
echo "3. Criando diretório de serviços do usuário..."
mkdir -p "$SERVICE_DIR"

# Instalar serviço systemd do usuário
echo "4. Instalando serviço systemd..."
cat > "$SERVICE_DIR/sparkclima.service" <<EOF
[Unit]
Description=Spark Clima Backend API
After=network.target

[Service]
Type=exec
WorkingDirectory=$INSTALL_DIR
ExecStart=$INSTALL_DIR/ClimatempoBackend
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=sparkclima
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=ASPNETCORE_URLS=http://localhost:5234

[Install]
WantedBy=default.target
EOF

# Recarregar systemd do usuário
echo "5. Recarregando systemd..."
systemctl --user daemon-reload

# Habilitar serviço
echo "6. Habilitando serviço..."
systemctl --user enable sparkclima.service

# Iniciar serviço com timeout
echo "7. Iniciando serviço (pode levar alguns segundos)..."
systemctl --user start sparkclima.service

# Aguardar 5 segundos
echo "8. Aguardando inicialização..."
sleep 5

# Verificar se está rodando
if systemctl --user is-active --quiet sparkclima; then
    echo "   ✓ Backend iniciado com sucesso"
else
    echo "   ⚠ Backend não está rodando"
    echo "   Ver logs: journalctl --user -u sparkclima"
    systemctl --user status sparkclima --no-pager
fi

# Habilitar lingering
loginctl enable-linger $USER 2>/dev/null || true

# Instalar widget KDE Plasma
echo "9. Instalando widget KDE Plasma..."
kpackagetool6 -t Plasma/Applet -i "$WIDGET_DIR" 2>/dev/null || \
kpackagetool6 -t Plasma/Applet -u "$WIDGET_DIR"

echo ""
echo "✅ Instalação concluída!"
echo ""
echo "📂 Backend: $INSTALL_DIR"
echo "🎨 Widget: Spark Clima"
echo ""
echo "Comandos úteis:"
echo "  Status:    systemctl --user status sparkclima"
echo "  Logs:      journalctl --user -u sparkclima -f"
echo "  Parar:     systemctl --user stop sparkclima"
echo "  Reiniciar: systemctl --user restart sparkclima"
echo "  Testar:    curl http://localhost:5234/clima?busca=Sao%20Paulo"
echo ""
echo "Widget: Adicionar Widgets → Spark Clima"
echo ""
