import Foundation

extension Date {
    var year: Int {
        get {
            Calendar.current.component(.year, from: self)
        }
        set {
            let components = DateComponents(year: newValue, month: self.month, day: 1)
            self = Calendar.current.date(from: components) ?? self
        }
    }
    
    var month: Int {
        get {
            Calendar.current.component(.month, from: self)
        }
        set {
            let components = DateComponents(year: self.year, month: newValue, day: 1)
            self = Calendar.current.date(from: components) ?? self
        }
    }
}
