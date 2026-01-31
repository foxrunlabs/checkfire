import Foundation
import SwiftData

@Model
final class Paycheck {
    typealias Year = Int
    
    // MARK: - Properties
    var name: String = "New Paycheck"
    var date: Date = Calendar.current.lastDateOfMonth(from: .now) ?? .now
    var payGrade: PayGrade = PayGrade.e1
    var yearsOfService: YearsOfService = YearsOfService.lessThanOrEqual2
    var basicPay: Decimal = 0.00
    var lesItems: [LESItem] = []
    var withholdingForm: WithholdingForm = WithholdingForm()
    var traditionalTSP: ThriftSavingsPlan = ThriftSavingsPlan()
    var rothTSP: ThriftSavingsPlan = ThriftSavingsPlan()
    
    // MARK: - Initializers
    init(
        name: String = "New Paycheck",
        date: Date = .now,
        payGrade: PayGrade = .e1,
        yearsOfService: YearsOfService = .lessThanOrEqual2,
        basicPay: Decimal = 0.00,
        lesItems: [LESItem] = [],
        withholdingForm: WithholdingForm = WithholdingForm(),
        traditionalTSP: ThriftSavingsPlan = ThriftSavingsPlan(),
        rothTSP: ThriftSavingsPlan = ThriftSavingsPlan()
    ) {
        self.name = name
        self.date = Calendar.current.lastDateOfMonth(from: date) ?? date
        self.payGrade = payGrade
        self.yearsOfService = yearsOfService
        self.basicPay = basicPay
        self.lesItems = lesItems
        self.withholdingForm = withholdingForm
        self.traditionalTSP = traditionalTSP
        self.rothTSP = rothTSP
    }
    
    convenience init(_ other: Paycheck) {
        let copiedLESItems = other.lesItems.map { lesItem in
            LESItem(lesItem.name, amount: lesItem.amount, category: lesItem.category)
        }
        
        self.init(
            name: other.name,
            date: other.date,
            payGrade: other.payGrade,
            yearsOfService: other.yearsOfService,
            basicPay: other.basicPay,
            lesItems: copiedLESItems,
            withholdingForm: other.withholdingForm,
            traditionalTSP: other.traditionalTSP,
            rothTSP: other.rothTSP
        )
    }
    
    // MARK: - Computed Properties
    var year: Year { Calendar.current.component(.year, from: date) }
    var ficaWages: Decimal { basicPay }
    var grossPay: Decimal { basicPay + lesItems.filter { $0.isEntitlement }.sum(\.amount) }
    
    var wagePeriod: Decimal {
        var taxableWage = basicPay - tspContribution(.traditional)
        taxableWage += lesItems.filter { $0.isTaxable }.sum(\.amount)
        return taxableWage
    }
    
    // MARK: - Methods
    func tspContribution(_ tspType: TSPType) -> Decimal {
        let plan = switch tspType {
        case .traditional:
            traditionalTSP
        case .roth:
            rothTSP
        }
        
        var contribution = basicPay * plan.basicPayRate
        let entitlements = lesItems.filter { $0.isEntitlement }
        contribution += entitlements.reduce(0.00) { sum, entitlement in
            let rate = switch entitlement.category {
            case .specialPay:
                plan.specialPayRate
            case .incentivePay:
                plan.incentivePayRate
            case .bonusPay:
                plan.bonusPayRate
            default:
                Decimal.zero
            }
            
            return sum + entitlement.amount * rate
        }
        
        return contribution.rounded(.toNearestOrAwayFromZero, digits: 2)
    }
    
    func netPay(taxes: (federal: Decimal, socialSecurity: Decimal, medicare: Decimal)) -> Decimal {
        var net = grossPay
        net -= tspContribution(.traditional)
        net -= tspContribution(.roth)
        net -= taxes.federal
        net -= taxes.socialSecurity
        net -= taxes.medicare
        net -= lesItems.filter { $0.isEntitlement == false }.sum(\.amount)
        return net
    }
    
    // MARK: - Example
    static let example = Paycheck(
        name: "Example",
        date: DateComponents(calendar: .current, year: 2025, month: 2, day: 28).date!,
        payGrade: .o5,
        yearsOfService: .over20,
        basicPay: 11592.30,
        lesItems: [
            LESItem("BAS", amount: 320.78, category: .allowance),
            LESItem("BAH", amount: 4485.00, category: .allowance),
            LESItem("Fly Pay", amount: 840.00, category: .incentivePay),
            LESItem("SGLI", amount: 31.00, category: .deduction),
            LESItem("SGLI Family/Spouse", amount: 10.00, category: .deduction),
            LESItem("TRICARE Dental", amount: 29.98, category: .allotment),
        ],
        withholdingForm: .example,
        traditionalTSP: ThriftSavingsPlan(basicPayRate: 0.11),
        rothTSP: ThriftSavingsPlan()
    )
}
