import Foundation

enum PayComponent: Hashable {
    typealias Year = Int
    
    case paycheck(Paycheck)
    case withholdingForm(WithholdingForm)
    case thriftSavingsPlan(ThriftSavingsPlan)
    case basicPay(Year)
    case bah(Year)
    case bas(Year)
}
