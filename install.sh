#!/bin/bash

set -e

echo "=== Instalação Spark Clima Backend ==="

# Diretório de instalação
INSTALL_DIR="$HOME/.services/spark-clima"
SERVICE_DIR="$HOME/.config/systemd/user"

# Publicar aplicação
echo "1. Publicando aplicação..."
cd backend
dotnet publish -c Release -r linux-x64 --self-contained true \
  /p:PublishSingleFile=true /p:PublishTrimmed=true -o ./publish

# Criar diretório de instalação
echo "2. Criando diretório $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
cp -r publish/* "$INSTALL_DIR/"
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

echo ""
echo "✅ Instalação concluída!"
echo ""
echo "📂 Instalado em: $INSTALL_DIR"
echo ""
echo "Comandos úteis:"
echo "  Status:    systemctl --user status sparkclima"
echo "  Logs:      journalctl --user -u sparkclima -f"
echo "  Parar:     systemctl --user stop sparkclima"
echo "  Reiniciar: systemctl --user restart sparkclima"
echo "  Desativar: systemctl --user disable sparkclima"
echo ""
echo "🌐 Backend disponível em: http://localhost:5234"
echo ""
