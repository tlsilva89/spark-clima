import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: generalPage
    
    property alias cfg_cidade: cidadeField.text
    property alias cfg_intervaloAtualizacao: intervaloSpinBox.value
    
    TextField {
        id: cidadeField
        Kirigami.FormData.label: "Cidade:"
        placeholderText: "Ex: Porto Alegre, São Paulo"
    }
    
    SpinBox {
        id: intervaloSpinBox
        Kirigami.FormData.label: "Atualizar a cada (minutos):"
        from: 5
        to: 120
        stepSize: 5
    }
}
