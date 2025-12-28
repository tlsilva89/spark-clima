import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root
    
    property string cidade: plasmoid.configuration.cidade || "São José dos Campos"
    property int intervaloAtualizacao: plasmoid.configuration.intervaloAtualizacao || 10
    
    property string cidadeNome: ""
    property string estado: ""
    property int temperatura: 0
    property int sensacaoTermica: 0
    property int temperaturaMin: 0
    property int temperaturaMax: 0
    property string condicao: ""
    property string condicaoCode: ""
    property string atualizado: ""
    property bool carregando: true
    property string erro: ""
    
    function isDayTime() {
        var hora = new Date().getHours()
        return hora >= 6 && hora < 18
    }
    
    function formatarDataHora(dataStr) {
        if (!dataStr) return ""
        var partes = dataStr.split("-")
        if (partes.length === 3) {
            return partes[2] + "/" + partes[1] + "/" + partes[0].substring(2)
        }
        return dataStr
    }
    
    function getWeatherIcon(code) {
        var isDia = isDayTime()
        var cleanCode = code.toLowerCase().replace(/^[np]+/, "")
        
        if (cleanCode.includes("c") || cleanCode === "l" || cleanCode === "i") {
            return isDia ? "weather-clear" : "weather-clear-night"
        }
        
        if (cleanCode.includes("pn") || cleanCode.includes("ec") || cleanCode.includes("pc")) {
            return isDia ? "weather-few-clouds" : "weather-few-clouds-night"
        }
        
        if (cleanCode.includes("n") || cleanCode.includes("cm") || cleanCode.includes("nv")) {
            return isDia ? "weather-clouds" : "weather-clouds-night"
        }
        
        if (cleanCode.includes("pp") || cleanCode.includes("pm") || cleanCode.includes("psc") || cleanCode.includes("ch")) {
            return isDia ? "weather-showers-scattered" : "weather-showers-scattered-night"
        }
        
        if (cleanCode.includes("t") || cleanCode.includes("pt")) {
            return "weather-storm"
        }
        
        if (cleanCode.includes("s") || cleanCode.includes("e")) {
            return "weather-snow"
        }
        
        if (cleanCode.includes("g")) {
            return "weather-freezing-rain"
        }
        
        if (cleanCode.includes("v") || code.toLowerCase() === "n") {
            return "weather-fog"
        }
        
        return isDia ? "weather-clouds" : "weather-clouds-night"
    }
    
    compactRepresentation: Item {
        Layout.minimumWidth: 50
        Layout.minimumHeight: 24
        Layout.preferredWidth: 70
        Layout.preferredHeight: 30
        Layout.maximumHeight: 30
        
        Rectangle {
            anchors.fill: parent
            color: "transparent"
        }
        
        MouseArea {
            anchors.fill: parent
            onClicked: root.expanded = !root.expanded
        }
        
        RowLayout {
            anchors.centerIn: parent
            spacing: 4
            
            PlasmaComponents.Label {
                visible: !root.carregando && !root.erro
                text: root.temperatura + "°"
                font.pointSize: 11
                font.weight: Font.Bold
                color: PlasmaCore.Theme.textColor
            }
            
            Kirigami.Icon {
                visible: !root.carregando && !root.erro
                source: getWeatherIcon(root.condicaoCode)
                Layout.preferredWidth: 18
                Layout.preferredHeight: 18
            }
            
            PlasmaComponents.Label {
                visible: root.carregando
                text: "..."
                font.pointSize: 9
                color: PlasmaCore.Theme.textColor
            }
            
            PlasmaComponents.Label {
                visible: root.erro
                text: "!"
                font.pointSize: 12
                color: PlasmaCore.Theme.negativeTextColor
            }
        }
    }
    
    fullRepresentation: Item {
        Layout.minimumWidth: 240
        Layout.minimumHeight: 320
        Layout.preferredWidth: 280
        Layout.preferredHeight: 360
        
        Rectangle {
            anchors.fill: parent
            color: "transparent"
        }
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 0
            
            PlasmaComponents.Label {
                text: root.cidadeNome + " - " + root.estado
                font.pointSize: 13
                font.weight: Font.Medium
                color: PlasmaCore.Theme.textColor
                opacity: 0.7
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }
            
            Item { 
                Layout.preferredHeight: 20
            }
            
            RowLayout {
                visible: !root.carregando && !root.erro
                Layout.alignment: Qt.AlignHCenter
                spacing: 10
                
                PlasmaComponents.Label {
                    text: root.temperatura + "°"
                    font.pointSize: 64
                    font.weight: Font.Bold
                    color: PlasmaCore.Theme.textColor
                }
                
                Kirigami.Icon {
                    source: getWeatherIcon(root.condicaoCode)
                    Layout.preferredWidth: 56
                    Layout.preferredHeight: 56
                    opacity: 0.7
                }
            }
            
            PlasmaComponents.Label {
                visible: !root.carregando && !root.erro && root.sensacaoTermica !== root.temperatura
                text: "Sensação térmica " + root.sensacaoTermica + "°"
                font.pointSize: 10
                color: PlasmaCore.Theme.textColor
                opacity: 0.6
                Layout.alignment: Qt.AlignHCenter
            }
            
            Item { 
                Layout.preferredHeight: 10
            }
            
            RowLayout {
                visible: !root.carregando && !root.erro
                Layout.alignment: Qt.AlignHCenter
                spacing: 20
                
                PlasmaComponents.Label {
                    text: "↓ " + root.temperaturaMin + "°"
                    font.pointSize: 11
                    color: PlasmaCore.Theme.textColor
                    opacity: 0.7
                }
                
                PlasmaComponents.Label {
                    text: "↑ " + root.temperaturaMax + "°"
                    font.pointSize: 11
                    color: PlasmaCore.Theme.textColor
                    opacity: 0.7
                }
            }
            
            PlasmaComponents.Label {
                visible: root.carregando
                text: "Carregando..."
                font.pointSize: 12
                color: PlasmaCore.Theme.textColor
                opacity: 0.7
                Layout.alignment: Qt.AlignCenter
                Layout.fillWidth: true
                Layout.fillHeight: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            ColumnLayout {
                visible: root.erro
                Layout.alignment: Qt.AlignCenter
                Layout.fillHeight: true
                spacing: 10
                
                PlasmaComponents.Label {
                    text: "⚠️"
                    font.pointSize: 28
                    Layout.alignment: Qt.AlignHCenter
                }
                
                PlasmaComponents.Label {
                    text: root.erro
                    font.pointSize: 10
                    color: PlasmaCore.Theme.textColor
                    opacity: 0.7
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }
                
                PlasmaComponents.Button {
                    text: "Tentar novamente"
                    onClicked: buscarClima()
                    Layout.alignment: Qt.AlignHCenter
                }
            }
            
            Item { 
                Layout.fillHeight: true
            }
            
            RowLayout {
                Layout.fillWidth: true
                
                PlasmaComponents.Label {
                    visible: !root.carregando && !root.erro
                    text: formatarDataHora(root.atualizado)
                    font.pointSize: 7
                    color: PlasmaCore.Theme.textColor
                    opacity: 0.3
                }
                
                Item { Layout.fillWidth: true }
                
                PlasmaComponents.Button {
                    visible: !root.carregando
                    icon.name: "view-refresh"
                    text: ""
                    flat: true
                    onClicked: buscarClima()
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                }
            }
        }
    }
    
    Timer {
        id: atualizacaoTimer
        interval: root.intervaloAtualizacao * 60 * 1000
        running: true
        repeat: true
        onTriggered: buscarClima()
    }
    
    Component.onCompleted: {
        buscarClima()
    }
    
    function buscarClima() {
        root.carregando = true
        root.erro = ""
        
        var xhr = new XMLHttpRequest()
        var url = "http://localhost:5234/clima?busca=" + encodeURIComponent(root.cidade)
        
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                root.carregando = false
                
                if (xhr.status === 200) {
                    try {
                        var dados = JSON.parse(xhr.responseText)
                        
                        if (dados.erro) {
                            root.erro = dados.erro
                        } else {
                            root.cidadeNome = dados.cidade
                            root.estado = dados.estado
                            root.temperatura = dados.temperatura
                            root.sensacaoTermica = dados.sensacao_termica
                            root.temperaturaMin = dados.temperatura_min
                            root.temperaturaMax = dados.temperatura_max
                            root.condicao = dados.condicao
                            root.condicaoCode = dados.condicao_code
                            root.atualizado = dados.atualizado
                        }
                    } catch (e) {
                        root.erro = "Erro ao processar dados"
                    }
                } else {
                    root.erro = "Falha na conexão"
                }
            }
        }
        
        xhr.open("GET", url)
        xhr.send()
    }
    
    onCidadeChanged: {
        buscarClima()
    }
}
