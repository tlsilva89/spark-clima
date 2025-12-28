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

# Publicar aplicação backend
echo "1. Publicando backend..."
cd backend
dotnet publish -c Release -r linux-x64 --self-contained true \
  /p:PublishSingleFile=true /p:PublishTrimmed=true -o ./publish
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
Type=notify
WorkingDirectory=$INSTALL_DIR
ExecStart=$INSTALL_DIR/ClimatempoBackend
Restart=always
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=sparkclima
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=ASPNETCORE_URLS=http://localhost:5234

[Install]
WantedBy=default.target
EOF

# Recarregar systemd do usuário
echo "5. Habilitando e iniciando serviço..."
systemctl --user daemon-reload
systemctl --user enable sparkclima.service
systemctl --user start sparkclima.service

# Habilitar lingering (serviço inicia no boot sem login)
loginctl enable-linger $USER

# Instalar widget KDE Plasma
echo "6. Instalando widget KDE Plasma..."
kpackagetool6 -t Plasma/Applet -i "$WIDGET_DIR" 2>/dev/null || \
kpackagetool6 -t Plasma/Applet -u "$WIDGET_DIR"

# Verificar se o backend está rodando
echo "7. Verificando backend..."
sleep 2
if systemctl --user is-active --quiet sparkclima; then
    echo "   ✓ Backend está rodando"
else
    echo "   ⚠ Backend não está rodando, verificar logs"
fi

echo ""
echo "✅ Instalação concluída!"
echo ""
echo "📂 Backend instalado em: $INSTALL_DIR"
echo "🎨 Widget instalado: Spark Clima"
echo ""
echo "Comandos úteis (Backend):"
echo "  Status:    systemctl --user status sparkclima"
echo "  Logs:      journalctl --user -u sparkclima -f"
echo "  Parar:     systemctl --user stop sparkclima"
echo "  Reiniciar: systemctl --user restart sparkclima"
echo ""
echo "Widget:"
echo "  Adicione o widget 'Spark Clima' ao painel ou desktop"
echo "  Clique com botão direito → Adicionar Widgets → Spark Clima"
echo ""
echo "🌐 Backend disponível em: http://localhost:5234"
echo ""
