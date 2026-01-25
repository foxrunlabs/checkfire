import Foundation
import SwiftData

@Model
final class Paycheck {
    typealias Year = Int
    
    enum TSPType {
        case traditional
        case roth
    }
    
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


// MARK: - Pay Grade
extension Paycheck {
    enum PayGrade:
        String,
        CaseIterable,
        Codable,
        CustomStringConvertible,
        Identifiable
    {
        case o10 = "o10", o9 = "o9", o8 = "o8", o7 = "o7", o6 = "o6", o5 = "o5", o4 = "o4", o3 = "o3", o2 = "o2", o1 = "o1"
        case o3e = "o3e", o2e = "o2e", o1e = "o1e"
        case w5 = "w5", w4 = "w4", w3 = "w3", w2 = "w2", w1 = "w1"
        case e9 = "e9", e8 = "e8", e7 = "e7", e6 = "e6", e5 = "e5", e4 = "e4", e3 = "e3", e2 = "e2", e1 = "e1"
        
        // MARK: - Properties
        static let officers: [Self] = [.o10, .o9, .o8, .o7, .o6, .o5, .o4, .o3, .o2, .o1]
        static let priorEnlisted: [Self] = [.o3e, .o2e, .o1e]
        static let warrants: [Self] = [.w5, .w4, .w3, .w2, .w1]
        static let enlisted: [Self] = [.e9, .e8, .e7, .e6, .e5, .e4, .e3, .e2, .e1]
        var isEnlisted: Bool { Self.enlisted.contains(self) }
        
        // MARK: - CustomStringConvertible
        var description: String {
            switch self {
            case .o1e: return "O-1E"
            case .o2e: return "O-2E"
            case .o3e: return "O-3E"
            default:
                let letter = rawValue.prefix(1).uppercased()
                let number = rawValue.dropFirst()
                return "\(letter)-\(number)"
            }
        }

        // MARK: - Identifiable
        var id: Self { self }
    }
}


// MARK: - Years of Service
extension Paycheck {
    enum YearsOfService:
        String,
        CaseIterable,
        Codable,
        CustomStringConvertible,
        Identifiable
    {
        case lessThan4Months = "lt_4_months"
        case lessThanOrEqual2 = "le_2"
        case over2 = "gt_2"
        case over3 = "gt_3"
        case over4 = "gt_4"
        case over6 = "gt_6"
        case over8 = "gt_8"
        case over10 = "gt_10"
        case over12 = "gt_12"
        case over14 = "gt_14"
        case over16 = "gt_16"
        case over18 = "gt_18"
        case over20 = "gt_20"
        case over22 = "gt_22"
        case over24 = "gt_24"
        case over26 = "gt_26"
        case over28 = "gt_28"
        case over30 = "gt_30"
        case over32 = "gt_32"
        case over34 = "gt_34"
        case over36 = "gt_36"
        case over38 = "gt_38"
        case over40 = "gt_40"
        
        // MARK: - CustomStringConvertible
        var description: String {
                switch self {
                case .lessThan4Months:
                    return "< 4 Months"
                default:
                    if rawValue.hasPrefix("gt_") {
                        return "Over \(rawValue.dropFirst(3))"
                    } else if rawValue.hasPrefix("le_") {
                        return "\(rawValue.dropFirst(3)) or Less"
                    } else {
                        return rawValue
                    }
                }
            }
        
        // MARK: - Identifiable
        var id: Self { self }
    }
}


// MARK: - LES Item
extension Paycheck {
    struct LESItem: Codable, Identifiable {
        var id: UUID = UUID()
        var name: String
        var amount: Decimal
        var category: Category
        
        // MARK: - Initializer
        init(_ name: String, amount: Decimal, category: Category) {
            self.name = name
            self.amount = amount
            self.category = category
        }
        
        // MARK: - Computed Properties
        var isEntitlement: Bool { Category.entitlementCases.contains(category) }
        var isTaxable: Bool { isEntitlement && category != .allowance }
    }
}


// MARK: - LES Item Category
extension Paycheck.LESItem {
    enum Category: String, CaseIterable, Codable, CustomStringConvertible, Identifiable {
        case specialPay
        case incentivePay
        case bonusPay
        case allowance
        case deduction
        case allotment
        
        // MARK: - Properties
        static let entitlementCases: [Self] = [.specialPay, .incentivePay, .bonusPay, .allowance]
        
        // MARK: - CustomStringConvertible
        var description: String {
            switch self {
            case .specialPay:
                "Special Pay"
            case .incentivePay:
                "Incentive Pay"
            case .bonusPay:
                "Bonus Pay"
            case .allowance:
                "Allowance"
            case .deduction:
                "Deduction"
            case .allotment:
                "Allotment"
            }
        }
        
        // MARK: - Identifiable
        var id: Self { self }
    }
}


// MARK: - Withholding Form
extension Paycheck {
    struct WithholdingForm: Codable {
        var maritalStatus: MaritalStatus = .single
        var multipleJobs = false
        var childDependents = 0
        var otherDependents = 0
        var otherIncome: Decimal = 0.00
        var deductions: Decimal = 0.00
        var extraWithholding: Decimal = 0.00
        
        // MARK: - Example
        static let example = WithholdingForm(
            maritalStatus: .marriedFilingJointly,
            multipleJobs: true,
            childDependents: 2
        )
    }
}

// MARK: - Thrift Savings Plan Contribution Rates
extension Paycheck {
    struct ThriftSavingsPlan: Codable {
        var basicPayRate: Decimal = 0.00
        var specialPayRate: Decimal = 0.00
        var incentivePayRate: Decimal = 0.00
        var bonusPayRate: Decimal = 0.00
    }
}

