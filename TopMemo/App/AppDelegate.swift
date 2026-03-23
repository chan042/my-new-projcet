import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var popoverCoordinator: PopoverCoordinator?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        let notesViewModel = NotesViewModel(store: NotesStore())
        let statusBarController = StatusBarController()
        popoverCoordinator = PopoverCoordinator(
            statusBarController: statusBarController,
            viewModel: notesViewModel
        )
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
