import Foundation
import SwiftData

@Model
final class Paycheck: Identifiable {
    var id = UUID()
    var name = ""
    var date = Calendar.current.lastDateOfMonth(from: .now) ?? .now
    
    var payGrade = PayGrade.e1
    var yearsOfService = YearsOfService.lessThanOrEqual2
    var basePay: Decimal = PayTables.shared.basePay(
        for: Calendar.current.component(.year, from: .now),
        as: .e1,
        with: .lessThanOrEqual2
    ) ?? 0.00
    
    @Relationship(deleteRule: .cascade, inverse: \LESItem.paycheck) var lesItems: [LESItem]? = []
    var withholdingForm: WithholdingForm? = nil
    var thriftSavingsPlan: ThriftSavingsPlan? = nil
    
    init(
        name: String,
        date: Date,
        payGrade: PayGrade,
        yearsOfService: YearsOfService,
        lesItems: [LESItem]? = nil,
        withholdingForm: WithholdingForm? = nil,
        thriftSavingsPlan: ThriftSavingsPlan? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.date = Calendar.current.lastDateOfMonth(from: date) ?? date
        
        self.payGrade = payGrade
        self.yearsOfService = yearsOfService
        let year = Calendar.current.component(.year, from: date)
        self.basePay = PayTables.shared.basePay(for: year, as: payGrade, with: yearsOfService) ?? 0.00
        
        self.lesItems = lesItems
        self.withholdingForm = withholdingForm
        self.thriftSavingsPlan = thriftSavingsPlan
    }
    
    convenience init() {
        self.init(
            name: "New Paycheck",
            date: .now,
            payGrade: .e1,
            yearsOfService: .lessThanOrEqual2
        )
    }
    
    var grossPay: Decimal {
        guard let lesItems else { return basePay }
        
        return basePay + lesItems.reduce(0.00) {
            if case .entitlement = $1.itemType {
                $0 + $1.amount
            } else {
                $0
            }
        }
    }
    
    var traditionalTSPContribution: Decimal {
        guard let tsp = thriftSavingsPlan else { return 0.00 }
        
        var contribution = basePay * tsp.traditionalBasePay
        guard let lesItems else { return contribution }
        
        contribution += lesItems.reduce(0.00) {
            if case .entitlement(let entitlement) = $1.itemType {
                let rate = switch entitlement {
                case .specialPay:
                    tsp.traditionalSpecialPay
                case .incentivePay:
                    tsp.traditionalIncentivePay
                case .bonusPay:
                    tsp.traditionalBonusPay
                default:
                    Decimal(0.00)
                }
                
                return $0 + $1.amount * rate
            } else {
                return $0
            }
        }
        
        return contribution.rounded(.toNearestOrAwayFromZero, digits: 2)
    }
    
    var rothTSPContribution: Decimal {
        guard let tsp = thriftSavingsPlan else { return 0.00 }
        
        var contribution = basePay * tsp.rothBasePay
        guard let lesItems else { return contribution }
        
        contribution += lesItems.reduce(0.00) {
            if case .entitlement(let entitlement) = $1.itemType {
                let rate = switch entitlement {
                case .specialPay:
                    tsp.rothSpecialPay
                case .incentivePay:
                    tsp.rothIncentivePay
                case .bonusPay:
                    tsp.rothBonusPay
                default:
                    Decimal(0.00)
                }
                
                return $0 + $1.amount * rate
            } else {
                return $0
            }
        }
        
        return contribution.rounded(.toNearestOrAwayFromZero, digits: 2)
    }
    
    var wagePeriod: Decimal {
        var taxableWage = basePay - traditionalTSPContribution
        guard let lesItems else { return taxableWage }
        
        taxableWage += lesItems.reduce(0.00) {
            if case .entitlement(let entitlement) = $1.itemType {
                (entitlement != .allowance) ? $0 + $1.amount : $0
            } else {
                $0
            }
        }
        
        return taxableWage
    }
    
    var federalTaxes: Decimal {
        guard let withholdingForm else { return 0.00 }
        
        return WithholdingTables.shared.calculateWithholding(
            for: Calendar.current.component(.year, from: date),
            wage: wagePeriod,
            using: withholdingForm
        )
    }
    
    var socialSecurity: Decimal {
        WithholdingTables.shared.calculateSocialSecurity(
            for: Calendar.current.component(.year, from: date),
            wage: basePay
        )
    }
    
    var medicare: Decimal {
        WithholdingTables.shared.calculateMedicare(
            for: Calendar.current.component(.year, from: date),
            wage: basePay
        )
    }
    
    var netPay: Decimal {
        var net = grossPay
        net -= traditionalTSPContribution
        net -= rothTSPContribution
        
        if let lesItems {
            net -= lesItems.reduce(0.00) {
                if case .entitlement = $1.itemType {
                    $0
                } else {
                    $0 + $1.amount
                }
            }
        }
        
        net -= federalTaxes
        net -= medicare
        net -= socialSecurity
        
        return net
    }
    
    static let example = Paycheck(
        name: "Example",
        date: DateComponents(calendar: .current, year: 2025, month: 2, day: 28).date!,
        payGrade: .o5,
        yearsOfService: .over20
    )
}
