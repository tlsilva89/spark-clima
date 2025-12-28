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
        Layout.minimumWidth: 100
        Layout.minimumHeight: 60
        Layout.preferredWidth: 120
        Layout.preferredHeight: 70
        
        MouseArea {
            anchors.fill: parent
            onClicked: root.expanded = !root.expanded
        }
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 2
            
            PlasmaComponents.Label {
                text: root.carregando ? "..." : (root.erro ? "Erro" : root.cidadeNome + " - " + root.estado)
                font.pointSize: 6
                font.weight: Font.Medium
                color: "#FFFFFF"
                opacity: 0.6
                Layout.alignment: Qt.AlignHCenter
                elide: Text.ElideRight
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }
            
            Item { Layout.fillHeight: true }
            
            RowLayout {
                visible: !root.carregando && !root.erro
                Layout.alignment: Qt.AlignHCenter
                spacing: 6
                
                PlasmaComponents.Label {
                    text: root.temperatura + "°"
                    font.pointSize: 20
                    font.weight: Font.Bold
                    color: "#FFFFFF"
                }
                
                Kirigami.Icon {
                    source: getWeatherIcon(root.condicaoCode)
                    Layout.preferredWidth: 22
                    Layout.preferredHeight: 22
                    color: "#FFFFFF"
                    opacity: 0.8
                }
            }
            
            Item { Layout.fillHeight: true }
        }
    }
    
    fullRepresentation: Item {
        Layout.minimumWidth: 240
        Layout.minimumHeight: 280
        Layout.preferredWidth: 280
        Layout.preferredHeight: 320
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 0
            
            PlasmaComponents.Label {
                text: root.cidadeNome + " - " + root.estado
                font.pointSize: 13
                font.weight: Font.Medium
                color: "#FFFFFF"
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
                    color: "#FFFFFF"
                }
                
                Kirigami.Icon {
                    source: getWeatherIcon(root.condicaoCode)
                    Layout.preferredWidth: 56
                    Layout.preferredHeight: 56
                    color: "#FFFFFF"
                    opacity: 0.7
                }
            }
            
            PlasmaComponents.Label {
                visible: root.carregando
                text: "Carregando..."
                font.pointSize: 12
                color: "#FFFFFF"
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
                    color: "#FFFFFF"
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
                Layout.preferredHeight: 20
            }
            
            RowLayout {
                Layout.fillWidth: true
                
                PlasmaComponents.Label {
                    visible: !root.carregando && !root.erro
                    text: formatarDataHora(root.atualizado)
                    font.pointSize: 7
                    color: "#FFFFFF"
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
