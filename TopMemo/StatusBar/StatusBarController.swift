import AppKit

final class StatusBarController {
    let statusItem: NSStatusItem

    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        configureButton()
    }

    var button: NSStatusBarButton? {
        statusItem.button
    }

    private func configureButton() {
        guard let button = statusItem.button else {
            return
        }

        let image = NSImage(
            systemSymbolName: "note.text",
            accessibilityDescription: "TopMemo"
        ) ?? NSImage()
        image.isTemplate = true

        button.image = image
        button.imagePosition = .imageOnly
        button.toolTip = "TopMemo"
    }
}
