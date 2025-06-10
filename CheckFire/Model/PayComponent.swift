import Foundation

enum PayComponent: Hashable {
    case paycheck(Paycheck)
    case withholdingForm(WithholdingForm)
    case thriftSavingsPlan(ThriftSavingsPlan)
}
