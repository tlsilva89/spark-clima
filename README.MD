# Spark Clima ☀️

Widget de previsão do tempo para KDE Plasma usando dados brasileiros da API CPTEC/INPE através da BrasilAPI.

![KDE Plasma 6](https://img.shields.io/badge/KDE-Plasma%206-1d99f3?style=flat-square&logo=kde)
![.NET 10.0](https://img.shields.io/badge/.NET-10.0-512BD4?style=flat-square&logo=dotnet)
![License GPL-2.0+](https://img.shields.io/badge/License-GPL--2.0+-green?style=flat-square)

## 📋 Sobre

Spark Clima é um widget minimalista para KDE Plasma que exibe a previsão do tempo de cidades brasileiras com design moderno e interface clean. O projeto utiliza um backend em C# que consome a BrasilAPI e um frontend em QML otimizado para Plasma 6.

## ✨ Características

- **Design Minimalista**: Interface limpa com fundo transparente
- **Ícones Dinâmicos**: Adaptação automática entre ícones diurnos e noturnos baseado no horário local
- **Atualização Automática**: Dados atualizados a cada 10 minutos
- **Configurável**: Escolha sua cidade através do painel de configurações
- **Leve e Rápido**: Backend otimizado com cache local
- **Dados Brasileiros**: Utiliza API oficial do CPTEC/INPE

## 🖼️ Preview

- **Representação Compacta**: Ícone de clima + temperatura em formato pequeno (120x70px)
- **Representação Expandida**: Vista completa com cidade, temperatura grande, ícone climático e última atualização (280x320px)

## 🛠️ Tecnologias

### Backend
- C# / ASP.NET Core 10.0
- API BrasilAPI (CPTEC v1)
- CORS habilitado
- HttpClient Factory

### Frontend
- QML (Qt Quick)
- KDE Plasma 6 Components
- Kirigami Framework
- Plasma Widget API

## 📦 Estrutura do Projeto

```
clima-tempo/
├── backend/
│   ├── Program.cs
│   ├── ClimatempoBackend.csproj
│   ├── ClimatempoBackend.sln
│   ├── appsettings.json
│   └── appsettings.Development.json
└── frontend/
    ├── metadata.json
    └── contents/
        ├── config/
        │   ├── config.qml
        │   └── main.xml
        └── ui/
            ├── main.qml
            └── configGeneral.qml
```

## 🚀 Instalação

### Requisitos

- **Sistema Operacional**: Linux com KDE Plasma 6
- **.NET SDK**: 10.0 ou superior
- **Plasma SDK**: plasma-sdk instalado

### Instalando Dependências

```bash
# Arch Linux / Manjaro
sudo pacman -S dotnet-sdk plasma-sdk

# Ubuntu / Debian
sudo apt install dotnet-sdk-10.0 plasma-sdk

# Fedora
sudo dnf install dotnet-sdk-10.0 plasma-sdk
```

### Backend

```bash
cd backend
dotnet restore
dotnet run
```

O backend estará disponível em `http://localhost:5234`

### Frontend (Widget)

```bash
cd frontend
kpackagetool6 -i . -t Plasma/Applet
```

Para atualizar o widget:

```bash
kpackagetool6 -u . -t Plasma/Applet
```

Para desinstalar:

```bash
kpackagetool6 -r dev.digitalspark.sparkclima
```

## 🧪 Testando o Widget

Para testar o widget sem instalá-lo:

```bash
# Desktop widget
plasmoidviewer -a /caminho/para/frontend

# Widget no painel (horizontal)
plasmoidviewer -a /caminho/para/frontend -l topedge -f horizontal

# Widget no painel (vertical)
plasmoidviewer -a /caminho/para/frontend -l leftedge -f vertical
```

## ⚙️ Configuração

### Alterando a Cidade Padrão

Clique com botão direito no widget → **Configurar Spark Clima** → Aba **Geral**

Opções disponíveis:
- **Cidade**: Nome da cidade brasileira (ex: São Paulo, Rio de Janeiro)
- **Atualizar a cada**: Intervalo de atualização em minutos (padrão: 10 min)

### Backend como Serviço Systemd

Crie o arquivo `/etc/systemd/system/sparkclima-backend.service`:

```ini
[Unit]
Description=Spark Clima Backend API
After=network.target

[Service]
Type=notify
User=seu-usuario
WorkingDirectory=/caminho/para/backend
ExecStart=/usr/bin/dotnet run --urls "http://localhost:5234"
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Habilite o serviço:

```bash
sudo systemctl daemon-reload
sudo systemctl enable sparkclima-backend.service
sudo systemctl start sparkclima-backend.service
```

## 📡 API Endpoints

### GET /clima?busca={cidade}

Retorna dados climáticos da cidade especificada.

**Parâmetros:**
- `busca`: Nome da cidade ou ID numérico do CPTEC

**Resposta de Sucesso (200):**

```json
{
  "cidade": "São José dos Campos",
  "estado": "SP",
  "temperatura": 27,
  "temperatura_min": 21,
  "temperatura_max": 34,
  "condicao": "Parcialmente Nublado",
  "condicao_code": "pn",
  "atualizado": "2025-12-28"
}
```

**Resposta de Erro (404):**

```json
{
  "erro": "Cidade nao encontrada ou dados indisponiveis"
}
```

## 🎨 Personalização

### Alterando Cores

Edite `frontend/contents/ui/main.qml` nas seções de `PlasmaComponents.Label`:

```qml
color: "#FFFFFF"  // Cor do texto
opacity: 0.7      // Transparência
```

### Modificando Tamanhos

```qml
font.pointSize: 64              // Tamanho da fonte
Layout.preferredWidth: 280      // Largura
Layout.preferredHeight: 320     // Altura
```

## 🐛 Resolução de Problemas

### Backend não inicia

- Verifique se a porta 5234 está disponível: `netstat -tlnp | grep 5234`
- Confirme se o .NET 10.0 está instalado: `dotnet --version`

### Widget não aparece

- Reinstale: `kpackagetool6 -u frontend -t Plasma/Applet`
- Verifique logs: `journalctl -f | grep plasmashell`

### Erro "Cidade não encontrada"

- Confirme a grafia correta da cidade
- Teste o endpoint diretamente: `curl "http://localhost:5234/clima?busca=Sao%20Paulo"`

### Ícones não aparecem

- Verifique se o tema de ícones Breeze está instalado
- Instale: `sudo pacman -S breeze-icons` (Arch) ou `sudo apt install breeze-icon-theme` (Ubuntu)

## 📝 Licença

GPL-2.0+ - Veja o arquivo LICENSE para detalhes.

## 👤 Autor

**Thiago Luciano**

- Email: tlsilva89@icloud.com
- Website: [https://digitalspark.dev](https://digitalspark.dev)
- GitHub: [@tlsilva89](https://github.com/tlsilva89)

## 🙏 Créditos

- **BrasilAPI**: Dados meteorológicos do CPTEC/INPE
- **KDE Project**: Framework Plasma e Kirigami
- **CPTEC/INPE**: Centro de Previsão de Tempo e Estudos Climáticos

## 🤝 Contribuindo

Contribuições são bem-vindas! Sinta-se livre para:

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/MinhaFeature`)
3. Commit suas mudanças (`git commit -m 'Adiciona MinhaFeature'`)
4. Push para a branch (`git push origin feature/MinhaFeature`)
5. Abra um Pull Request

---

⭐ Se este projeto foi útil para você, considere dar uma estrela no repositório!