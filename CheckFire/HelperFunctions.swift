import UIKit

/// Requests that the current first responder resign, dismissing the keyboard.
///
/// Sends the resign-first-responder action through the responder chain without
/// targeting a specific view. Call this function on the main thread.
func dismissKeyboard() {
    UIApplication.shared.sendAction(
        #selector(UIResponder.resignFirstResponder),
        to: nil,
        from: nil,
        for: nil
    )
}
