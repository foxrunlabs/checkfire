import SwiftUI

extension UIDevice {
    static var isiPad: Bool { Self.current.userInterfaceIdiom == .pad }
}
