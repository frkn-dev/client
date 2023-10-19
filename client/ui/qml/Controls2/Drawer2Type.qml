import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Shapes

Item {
    id: root

    Connections {
        target: PageController

        function onForceCloseDrawer() {
            if (root.opened()) {
                close()
                return
            }

            if (root.expanded()) {
                collapse()
            }
        }
    }

    signal drawerClosed
    signal collapsedEntered
    signal collapsedExited
    signal collapsedEnter
    signal collapsedPressChanged


    visible: false

    property bool needCloseButton: true

    property string defaultColor: "#1C1D21"
    property string borderColor: "#2C2D30"
    property string semitransparentColor: "#90000000"

    property bool needCollapsed: false

    property int contentHeight: 0
    property Item contentParent: contentArea

    property bool dragActive: dragArea.drag.active

    /** Initial height of button content */
    property int collapsedHeight: 0

    property bool fullMouseAreaVisible: true
    property MouseArea drawerDragArea: dragArea

    state: "closed"

    Rectangle {
        id: draw2Background

        anchors.fill: parent
        height: parent.height
        width: parent.width
        radius: 16
        color: "transparent"
        border.color: "transparent"
        border.width: 1
        visible: true

        MouseArea {
            id: fullMouseArea
            anchors.fill: parent
            enabled: (root.opened() || root.expanded())
            hoverEnabled: true
            visible: fullMouseAreaVisible

            onClicked: {
                if (root.opened()) {
                    close()
                    return
                }

                if (root.expanded()) {
                    collapse()
                }
            }
        }

        Rectangle {
            id: placeAreaHolder
            height: (!root.opened())  ? 0 :  parent.height - contentHeight
            anchors.right: parent.right
            anchors.left: parent.left
            visible: true
            color: "transparent"

            Drag.active: dragArea.drag.active
        }


        Rectangle {
            id: contentArea

            anchors.top: placeAreaHolder.bottom
            height: contentHeight
            radius: 16
            color: root.defaultColor
            border.width: 1
            border.color: root.borderColor
            width: parent.width
            visible: true

            Rectangle {
                width: parent.radius
                height: parent.radius
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.left: parent.left
                color: parent.color
            }

            MouseArea {
                id: dragArea

                anchors.fill: parent

                cursorShape: root.collapsed() ? Qt.PointingHandCursor : Qt.ArrowCursor // ?
                hoverEnabled: true

                drag.target: placeAreaHolder
                drag.axis: Drag.YAxis
                drag.maximumY: (root.collapsed() || root.expanded()) ? (root.height - collapsedHeight) : root.height
                drag.minimumY: (root.collapsed() || root.expanded()) ? (root.height - root.height * 0.9) : (root.height - root.height)

                /** If drag area is released at any point other than min or max y, transition to the other state */
                onReleased: {
                    if (root.closed() && placeAreaHolder.y < root.height * 0.9) {
                        root.state = "opened"
                        return
                    }

                    if (root.opened() && placeAreaHolder.y > (root.height - root.height * 0.9)) {
                        close()
                        return
                    }


                    if (root.collapsed() && placeAreaHolder.y < (root.height - collapsedHeight)) {
                        root.state = "expanded"
                        return
                    }

                    if (root.expanded() && placeAreaHolder.y > (root.height - root.height * 0.9)) {
                        root.state = "collapsed"
                        return
                    }


                    if (root.opened()) {
                        placeAreaHolder.y = 0
                    }
                }

                onClicked: {
                    if (root.opened()) {
                        close()
                        return
                    }

                    if (root.expanded()) {
                        collapse()
                        return
                    }

                    if (root.collapsed()) {
                        root.state = "expanded"
                    }
                }

                onExited: {
                    collapsedExited()
                }

                onEntered: {
                    collapsedEnter()
                }

                onPressedChanged: {
                    collapsedPressChanged()
                }
            }
        }

    }

    onStateChanged: {
        if (root.closed() || root.collapsed()) {
            var initialPageNavigationBarColor = PageController.getInitialPageNavigationBarColor()
            if (initialPageNavigationBarColor !== 0xFF1C1D21) {
                PageController.updateNavigationBarColor(initialPageNavigationBarColor)
            }

            if (needCloseButton) {
                PageController.drawerClose()
            }

            drawerClosed()

            return
        }

        if (root.opened() || root.expanded()) {
            if (PageController.getInitialPageNavigationBarColor() !== 0xFF1C1D21) {
                PageController.updateNavigationBarColor(0xFF1C1D21)
            }

            if (needCloseButton) {
                PageController.drawerOpen()
            }

            return
        }
    }

    /** Two states of buttonContent, great place to add any future animations for the drawer */
    states: [
        State {
            name: "closed"
            PropertyChanges {
                target: placeAreaHolder
                y: root.height
            }
        },

        State {
            name: "opened"
            PropertyChanges {
                target: placeAreaHolder
                y: dragArea.drag.minimumY
            }
        },

        State {
            name: "collapsed"
            PropertyChanges {
                target: placeAreaHolder
                y: root.height - collapsedHeight
            }
        },

        State {
            name: "expanded"
            PropertyChanges {
                target: placeAreaHolder
                y: root.height - root.height * 0.9
            }
        }
    ]

    transitions: [
        Transition {
            from: "opened"
            to: "closed"
            PropertyAnimation {
                target: placeAreaHolder
                properties: "y"
                duration: 200
            }

            onRunningChanged: {
                if (!running) {
                    fullMouseArea.visible = false
                }
            }
        },

        Transition {
            from: "closed"
            to: "opened"
            PropertyAnimation {
                target: placeAreaHolder
                properties: "y"
                duration: 200
            }
        },

        Transition {
            from: "expanded"
            to: "collapsed"
            PropertyAnimation {
                target: placeAreaHolder
                properties: "y"
                duration: 200
            }

            onRunningChanged: {
                if (!running) {
                    draw2Background.color = "transparent"
                    fullMouseArea.visible = false
                }
            }
        },

        Transition {
            from: "collapsed"
            to: "expanded"
            PropertyAnimation {
                target: placeAreaHolder
                properties: "y"
                duration: 200
            }

            onRunningChanged: {
                if (!running) {
                    draw2Background.color = semitransparentColor
                    fullMouseArea.visible = true
                }
            }
        }
    ]

    NumberAnimation {
        id: animationVisible
        target: placeAreaHolder
        property: "y"
        from: parent.height
        to: 0
        duration: 200
    }

    function open() {
        if (root.opened()) {
            return
        }

        draw2Background.color = semitransparentColor
        fullMouseArea.visible = true

        root.y = 0
        root.state = "opened"
        root.visible = true
        root.height = parent.height

        contentArea.height = contentHeight

        placeAreaHolder.height =  root.height - contentHeight
        placeAreaHolder.y = root.height - root.height

        dragArea.drag.maximumY =  root.height
        dragArea.drag.minimumY =  0

        animationVisible.running = true
    }

    function close() {
        draw2Background.color = "transparent"
        root.state = "closed"
    }

    function collapse() {
        draw2Background.color = "transparent"
        root.state = "collapsed"
    }

    function expand() {
        draw2Background.color = semitransparentColor
        root.state = "expanded"
    }

    function opened() {
        return root.state === "opened" ? true : false
    }

    function expanded() {
        return root.state === "expanded" ? true : false
    }

    function closed() {
        return root.state === "closed" ? true : false
    }

    function collapsed() {
        return root.state === "collapsed" ? true : false
    }


    onVisibleChanged: {
        // e.g cancel, ......
        if (!visible) {
            if (root.opened()) {
                if (needCloseButton) {
                    PageController.drawerClose()
                }

                close()
            }
        }
    }
}
