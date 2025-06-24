import SwiftData
import SwiftUI

struct NetPayView: View {
    private let paycheck: Paycheck
    
    @Query private var withholdingForms: [WithholdingForm]
    @Query private var thriftSavingsPlans: [ThriftSavingsPlan]
    
    init(for paycheck: Paycheck) {
        self.paycheck = paycheck
        
        let paycheckDate = paycheck.date
        self._withholdingForms = Query(
            filter: #Predicate<WithholdingForm> { $0.date <= paycheckDate },
            sort: \.date
        )
        
        self._thriftSavingsPlans = Query(
            filter: #Predicate<ThriftSavingsPlan> { $0.date <= paycheckDate },
            sort: \.date
        )
    }
    
    private var grossPay: Decimal {
        if let lesItems = paycheck.lesItems {
            paycheck.basePay + lesItems.reduce(0.00) {
                if case .entitlement = $1.itemType {
                    $0 + $1.amount
                } else {
                    $0
                }
            }
        } else {
            paycheck.basePay
        }
    }
    
    private var traditionalTSPContribution: Decimal {
        guard let tsp = thriftSavingsPlans.last else { return 0.00 }
        
        var contribution = paycheck.basePay * tsp.traditionalBasePay
        guard let lesItems = paycheck.lesItems else {
            return contribution.rounded(.toNearestOrAwayFromZero, digits: 2)
        }
        
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
        guard let tsp = thriftSavingsPlans.last else { return 0.00 }
        
        var contribution = paycheck.basePay * tsp.rothBasePay
        guard let lesItems = paycheck.lesItems else {
            return contribution.rounded(.toNearestOrAwayFromZero, digits: 2)
        }
        
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
        var taxableWage = paycheck.basePay - traditionalTSPContribution
        guard let lesItems = paycheck.lesItems else { return taxableWage }
        
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
        guard let withholdingForm = withholdingForms.last else { return 0.00 }
        let year = Calendar.current.component(.year, from: paycheck.date)
        
        return WithholdingTables.shared.calculateWithholding(
            for: year,
            wage: wagePeriod,
            using: withholdingForm
        )
    }
    
    var socialSecurity: Decimal {
        WithholdingTables.shared.calculateSocialSecurity(
            for: Calendar.current.component(.year, from: paycheck.date),
            wage: paycheck.basePay
        )
    }
    
    var medicare: Decimal {
        WithholdingTables.shared.calculateMedicare(
            for: Calendar.current.component(.year, from: paycheck.date),
            wage: paycheck.basePay
        )
    }
    
    var netPay: Decimal {
        var net = grossPay
        net -= traditionalTSPContribution
        net -= rothTSPContribution
        
        if let lesItems = paycheck.lesItems {
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
    
    private var withholdingFormDate: String {
        withholdingForms.last?.date.formatted(.dateTime.month().year()) ?? "No Data"
    }
    
    private var tspDate: String {
        thriftSavingsPlans.last?.date.formatted(.dateTime.month().year()) ?? "No Data"
    }
    
    var body: some View {
        List {
            Group {
                Section {
                    LabeledCurrency("Gross Pay", value: grossPay)
                    LabeledCurrency("Wage Period", value: wagePeriod)
                }
                
                Section {
                    LabeledCurrency("Traditional TSP", value: traditionalTSPContribution)
                    LabeledCurrency("Roth TSP", value: rothTSPContribution)
                }
                
                Section {
                    LabeledCurrency("Federal Taxes", value: federalTaxes)
                    LabeledCurrency("Social Security", value: socialSecurity)
                    LabeledCurrency("Medicare", value: medicare)
                }
                
                Section {
                    LabeledCurrency("Net Pay", value: netPay)
                }
                
                Section {
                    LabeledContent("Withholding Form") {
                        Text(withholdingFormDate)
                    }
                    
                    LabeledContent("Thrift Savings Plan") {
                        Text(tspDate)
                    }
                }
            }
        }
    }
    
    private struct LabeledCurrency: View {
        private let label: String
        private let value: Decimal
        
        init(_ label: String, value: Decimal) {
            self.label = label
            self.value = value
        }
        
        var body: some View {
            LabeledContent {
                Text(value.formatted(.currency(code: "USD")))
            } label: {
                Text(label)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var paycheck = Paycheck.example
    
    NavigationStack {
        NetPayView(for: paycheck)
    }
    .modelContainer(PreviewController.container)
}
