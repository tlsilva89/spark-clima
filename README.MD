# Spark Clima ☀️

Widget minimalista de previsão do tempo para KDE Plasma 6 usando dados brasileiros da API CPTEC/INPE através da BrasilAPI.

![KDE Plasma 6](https://img.shields.io/badge/KDE-Plasma%206-1d99f3?style=flat-square&logo=kde)
![.NET 10.0](https://img.shields.io/badge/.NET-10.0-512BD4?style=flat-square&logo=dotnet)
![License GPL-2.0+](https://img.shields.io/badge/License-GPL--2.0+-green?style=flat-square)

## 📋 Sobre

Spark Clima é um widget minimalista para KDE Plasma 6 que exibe a previsão do tempo de cidades brasileiras. Apresenta design moderno com fundo totalmente transparente, ícones adaptativos (dia/noite) e cores que se ajustam automaticamente ao tema do sistema. O backend em C# consome a BrasilAPI e roda como serviço do usuário via systemd.

## ✨ Características

- **Design Ultra Minimalista**: Apenas temperatura e ícone no painel (70x30px)
- **Fundo Transparente**: Integração perfeita com painéis flutuantes
- **Ícones Dinâmicos**: Adaptação automática entre ícones diurnos e noturnos
- **Tema Adaptativo**: Cores ajustam-se ao tema claro/escuro do Plasma
- **Atualização Automática**: Dados atualizados a cada 10 minutos (configurável)
- **Backend como Serviço**: Inicia automaticamente com o sistema
- **Instalação Automatizada**: Scripts bash para instalar, atualizar e remover
- **Dados Brasileiros**: API oficial do CPTEC/INPE via BrasilAPI

## 🖼️ Preview

### No Painel (Compacto)
- Apenas temperatura + ícone (ex: "27° ☀️")
- Otimizado para painéis de 30px de altura
- Fundo totalmente transparente

### Popup (Expandido)
Clique no widget para expandir:
- Cidade e estado
- Temperatura em destaque (64pt)
- Ícone grande do clima
- Data da última atualização
- Botão de atualizar

## 🛠️ Tecnologias

### Backend
- C# / ASP.NET Core 10.0
- API BrasilAPI (CPTEC v1)
- JSON Source Generation (AOT friendly)
- Self-contained deployment
- Systemd user service

### Frontend
- QML (Qt Quick 6)
- KDE Plasma 6 Components
- Kirigami Framework
- Theme-aware colors

## 📦 Estrutura do Projeto

```
clima-tempo/
├── backend/
│   ├── Program.cs
│   ├── appsettings.json
│   └── appsettings.Development.json
├── frontend/
│   ├── metadata.json
│   └── contents/
│       ├── config/
│       │   ├── config.qml
│       │   └── main.xml
│       └── ui/
│           ├── main.qml
│           └── configGeneral.qml
├── install.sh
├── update.sh
└── uninstall.sh
```

## 🚀 Instalação Rápida

### Requisitos

- **Sistema**: Linux com KDE Plasma 6
- **.NET SDK**: 10.0 (apenas para compilar)
- **Ferramentas**: kpackagetool6, systemctl

```bash
# Arch Linux / Manjaro
sudo pacman -S dotnet-sdk plasma-sdk

# Ubuntu / Debian
sudo apt install dotnet-sdk-10.0 plasma-workspace-dev

# Fedora
sudo dnf install dotnet-sdk-10.0 plasma-workspace-devel
```

### Instalação Automática

```bash
# Clone o repositório
git clone https://github.com/tlsilva89/spark-clima.git
cd spark-clima

# Torne os scripts executáveis
chmod +x install.sh update.sh uninstall.sh

# Execute a instalação
./install.sh
```

O script irá:
1. Compilar o backend (self-contained, ~90MB)
2. Instalar em `~/.services/spark-clima/`
3. Criar serviço systemd do usuário
4. Habilitar inicialização automática
5. Instalar o widget do Plasma

### Adicionar ao Painel

1. Clique direito no painel → **Adicionar Widgets**
2. Procure por "Spark Clima"
3. Arraste para o painel

## ⚙️ Configuração

### Alterar Cidade

Clique direito no widget → **Configurar Spark Clima**

- **Cidade**: Nome da cidade (ex: Porto Alegre, São Paulo)
- **Intervalo de Atualização**: 5 a 120 minutos (padrão: 10)

### Gerenciar Backend

```bash
# Ver status
systemctl --user status sparkclima

# Ver logs em tempo real
journalctl --user -u sparkclima -f

# Parar/Iniciar/Reiniciar
systemctl --user stop sparkclima
systemctl --user start sparkclima
systemctl --user restart sparkclima

# Testar API diretamente
curl "http://localhost:5234/clima?busca=Sao%20Paulo"
```

## 🔄 Atualização

```bash
cd spark-clima
git pull
./update.sh
```

O script:
1. Para o backend
2. Compila nova versão
3. Faz backup da versão anterior
4. Atualiza widget
5. Reinicia o backend

## 🗑️ Desinstalação

```bash
./uninstall.sh
```

Remove:
- Widget do Plasma
- Serviço systemd
- Backend (`~/.services/spark-clima/`)
- Oferece remover backups antigos

## 📡 API Backend

### GET /clima?busca={cidade}

**Parâmetros:**
- `busca`: Nome da cidade ou ID CPTEC

**Resposta (200 OK):**

```json
{
  "cidade": "Porto Alegre",
  "estado": "RS",
  "temperatura": 27,
  "temperatura_min": 21,
  "temperatura_max": 34,
  "condicao": "Parcialmente Nublado",
  "condicao_code": "pn",
  "atualizado": "2025-12-28"
}
```

**Erro (404):**

```json
{
  "erro": "Cidade nao encontrada ou dados indisponiveis"
}
```

## 🎨 Códigos de Condição Climática

| Código | Condição | Ícone Dia | Ícone Noite |
|--------|----------|-----------|-------------|
| ec, c | Céu Claro | ☀️ | 🌙 |
| pn, pc | Parcialmente Nublado | ⛅ | ☁️🌙 |
| n, cm, nv | Nublado | ☁️ | ☁️ |
| pp, pm, ch | Chuva | 🌧️ | 🌧️ |
| t, pt | Tempestade | ⛈️ | ⛈️ |
| s, e | Neve | ❄️ | ❄️ |
| g | Granizo | 🧊 | 🧊 |
| v | Neblina | 🌫️ | 🌫️ |

## 🐛 Resolução de Problemas

### Backend não inicia

```bash
# Verificar porta
ss -tulpn | grep 5234

# Matar processo na porta
killall -9 ClimatempoBackend

# Ver logs de erro
journalctl --user -u sparkclima -n 50

# Testar manualmente
~/.services/spark-clima/ClimatempoBackend
```

### Widget mostra "Falha na conexão"

```bash
# Backend está rodando?
systemctl --user status sparkclima

# Testar API
curl "http://localhost:5234/clima?busca=Sao%20Paulo"

# Reiniciar Plasma
killall plasmashell && kstart5 plasmashell &
```

### Widget não aparece na lista

```bash
# Reinstalar widget
kpackagetool6 -r dev.digitalspark.sparkclima
kpackagetool6 -i frontend

# Reiniciar Plasma
killall plasmashell && kstart5 plasmashell &
```

### Erro "Cidade não encontrada"

- Verifique a grafia (use acentos: "São Paulo" não "Sao Paulo")
- Teste: `curl "http://localhost:5234/clima?busca=Porto%20Alegre"`
- Veja cidades disponíveis: [BrasilAPI CPTEC Cidades](https://brasilapi.com.br/docs#tag/CPTEC)

## 🏗️ Desenvolvimento

### Rodar Backend em Modo Dev

```bash
cd backend
dotnet watch run
```

### Testar Widget sem Instalar

```bash
# No painel horizontal
plasmoidviewer -a frontend -l topedge -f horizontal

# No desktop
plasmoidviewer -a frontend
```

### Compilar Backend para Produção

```bash
cd backend
dotnet publish -c Release -r linux-x64 --self-contained true \
  /p:PublishSingleFile=true -o ./publish
```

## 📂 Localização dos Arquivos

```
~/.services/spark-clima/          # Backend instalado
~/.config/systemd/user/           # Serviço sparkclima.service
~/.local/share/plasma/plasmoids/  # Widget instalado
```

## 📝 Licença

GPL-2.0+ - Software Livre

## 👤 Autor

**Thiago Luciano**

- Email: tlsilva89@icloud.com
- Website: [https://digitalspark.dev](https://digitalspark.dev)
- GitHub: [@tlsilva89](https://github.com/tlsilva89)

## 🙏 Créditos

- **BrasilAPI** - Wrapper da API CPTEC/INPE
- **CPTEC/INPE** - Dados meteorológicos
- **KDE Project** - Framework Plasma 6

## 🤝 Contribuindo

Pull requests são bem-vindos!

1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/NovaFeature`)
3. Commit (`git commit -m 'Adiciona NovaFeature'`)
4. Push (`git push origin feature/NovaFeature`)
5. Abra um Pull Request

---

⭐ Gostou? Dê uma estrela no repositório!