import QtQuick
import QtQml
import ".."

Item {
    id: section

    default property alias content: row.data
    property alias spacing: row.spacing

    width: row.implicitWidth
    height: row.implicitHeight

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Style.moduleGap
    }
}
