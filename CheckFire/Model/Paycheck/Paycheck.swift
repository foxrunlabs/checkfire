import Foundation
import SwiftData

@Model
final class Paycheck {
    static let wageFrequency: Decimal = 12
    
    // MARK: - Properties
    
    var name: String = "New Paycheck"
    var year: Int = 2023
    var month: Month = Month.january
    var payGrade: PayGrade = PayGrade.e1
    var yearsOfService: YearsOfService = YearsOfService.lessThanOrEqual2
    var basicPay: Decimal = 0.00
    var lesItems: [LESItem] = []
    var withholdingForm: WithholdingForm = WithholdingForm()
    var traditionalTSP: ThriftSavingsPlan = ThriftSavingsPlan()
    var rothTSP: ThriftSavingsPlan = ThriftSavingsPlan()
    
    // MARK: - Computed Properties
    
    var payPeriod: PayPeriod {
        get { PayPeriod(year: year, month: month) }
        set {
            self.year = newValue.year
            self.month = newValue.month
        }
    }
    
    var entitlements: [LESItem] { lesItems.filter { $0.isEntitlement } }
    var taxableLESItems: [LESItem] { lesItems.filter { $0.isTaxable } }
    var adjustments: [LESItem] { lesItems.filter { !$0.isEntitlement } }
    
    var tspEligibleEntitlements: [LESItem] {
        lesItems.filter { lesItem in
            lesItem.isEntitlement && lesItem.category != .allowance
        }
    }
    
    // MARK: - Initializers
    
    init(
        name: String = "New Paycheck",
        year: Int = 2023,
        month: Month = .january,
        payGrade: PayGrade = .e1,
        yearsOfService: YearsOfService = .lessThanOrEqual2,
        basicPay: Decimal = 0.00,
        lesItems: [LESItem] = [],
        withholdingForm: WithholdingForm = .init(),
        traditionalTSP: ThriftSavingsPlan = .init(),
        rothTSP: ThriftSavingsPlan = .init()
    ) {
        self.name = name
        self.year = year
        self.month = month
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
            year: other.year,
            month: other.month,
            payGrade: other.payGrade,
            yearsOfService: other.yearsOfService,
            basicPay: other.basicPay,
            lesItems: copiedLESItems,
            withholdingForm: other.withholdingForm,
            traditionalTSP: other.traditionalTSP,
            rothTSP: other.rothTSP
        )
    }
    
    // MARK: - Methods
    
    func lesItems(_ category: LESItem.Category) -> [LESItem] {
        lesItems.filter { $0.category == category }
    }
    
    // MARK: - Example
    
    static let example = Paycheck(
        name: "Example",
        year: 2025,
        month: .february,
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
