import SwiftData
import SwiftUI

struct NetPayView: View {
    let paycheck: Paycheck
    
    init(for paycheck: Paycheck) {
        self.paycheck = paycheck
        
        self.grossPay = {
            var gross = paycheck.basicPay + paycheck.bas + paycheck.bah
            gross += paycheck.lesItems?.reduce(0.00) { sum, item in
                item.type.isEntitlement ? sum + item.amount : sum
            } ?? 0.00
            return gross
        }()
        
        self.socialSecurity = WithholdingTables.shared.calculateSocialSecurity(
            for: paycheck.year,
            wage: paycheck.basicPay
        ) ?? 0.00
        
        self.medicare = WithholdingTables.shared.calculateMedicare(
            for: paycheck.year,
            wage: paycheck.basicPay
        ) ?? 0.00
        
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
    
    private let grossPay: Decimal
    private let socialSecurity: Decimal
    private let medicare: Decimal
    
    @Query private var withholdingForms: [WithholdingForm]
    @Query private var thriftSavingsPlans: [ThriftSavingsPlan]
    
    private var missingDataDescription: String {
        if withholdingForms.isEmpty && thriftSavingsPlans.isEmpty {
            "Missing Withholding Form and Thrift Savings Plan"
        } else {
            if withholdingForms.isEmpty {
                "Missing Withholding Form"
            } else if thriftSavingsPlans.isEmpty {
                "Missing Thrift Savings Plan"
            } else {
                ""
            }
        }
    }
    
    var body: some View {
        if let withholdingForm = withholdingForms.last, let tsp = thriftSavingsPlans.last {
            List {
                Group {
                    Section {
                        LabeledContent("Gross Pay") {
                            Text(grossPay, format: .currency(code: "USD"))
                        }
                        
                        LabeledContent("Wage Period") {
                            Text(wagePeriod(tsp: tsp), format: .currency(code: "USD"))
                        }
                    }
                    
                    Section {
                        LabeledContent("Traditional TSP") {
                            Text(
                                traditionalTSPContribution(using: tsp),
                                format: .currency(code: "USD")
                            )
                        }
                        
                        LabeledContent("Roth TSP") {
                            Text(rothTSPContribution(using: tsp), format: .currency(code: "USD"))
                        }
                    }
                    
                    Section {
                        LabeledContent("Federal Taxes") {
                            Text(
                                federalTaxes(using: withholdingForm, tsp: tsp),
                                format: .currency(code: "USD")
                            )
                        }
                        
                        LabeledContent("Social Security") {
                            Text(socialSecurity, format: .currency(code: "USD"))
                        }
                        
                        LabeledContent("Medicare") {
                            Text(medicare, format: .currency(code: "USD"))
                        }
                    }
                    
                    Section {
                        LabeledContent("Net Pay") {
                            Text(
                                netPay(withholdingForm: withholdingForm, tsp: tsp),
                                format: .currency(code: "USD")
                            )
                        }
                    }
                    
                    Section {
                        LabeledContent("Withholding Form") {
                            Text(withholdingForm.date, format: .dateTime.month().year())
                        }
                        
                        LabeledContent("Thrift Savings Plan") {
                            Text(tsp.date, format: .dateTime.month().year())
                        }
                    }
                }
            }
        } else {
            ContentUnavailableView(
                "Unable to Compute Net Pay",
                systemImage: "exclamationmark.triangle",
                description: Text(missingDataDescription)
            )
        }
    }
    
    // MARK: - Computation Functions
    private func traditionalTSPContribution(using tsp: ThriftSavingsPlan) -> Decimal {
        var contribution = paycheck.basicPay * tsp.traditionalBasicPay
        guard let lesItems = paycheck.lesItems else {
            return contribution.rounded(.toNearestOrAwayFromZero, digits: 2)
        }
        
        contribution += lesItems.reduce(0.00) { sum, item in
            if item.type.isEntitlement {
                let rate: Decimal = switch item.type {
                case .specialPay:
                    tsp.traditionalSpecialPay
                case .incentivePay:
                    tsp.traditionalIncentivePay
                case .bonusPay:
                    tsp.traditionalBonusPay
                default:
                    0.00
                }
                
                return sum + item.amount * rate
            } else {
                return sum
            }
        }
        
        return contribution.rounded(.toNearestOrAwayFromZero, digits: 2)
    }
    
    private func rothTSPContribution(using tsp: ThriftSavingsPlan) -> Decimal {
        var contribution = paycheck.basicPay * tsp.rothBasicPay
        guard let lesItems = paycheck.lesItems else {
            return contribution.rounded(.toNearestOrAwayFromZero, digits: 2)
        }
        
        contribution += lesItems.reduce(0.00) { sum, item in
            if item.type.isEntitlement {
                let rate: Decimal = switch item.type {
                case .specialPay:
                    tsp.rothSpecialPay
                case .incentivePay:
                    tsp.rothIncentivePay
                case .bonusPay:
                    tsp.rothBonusPay
                default:
                    0.00
                }
                
                return sum + item.amount * rate
            } else {
                return sum
            }
        }
        
        return contribution.rounded(.toNearestOrAwayFromZero, digits: 2)
    }
    
    private func wagePeriod(tsp: ThriftSavingsPlan) -> Decimal {
        var taxableWage = paycheck.basicPay - traditionalTSPContribution(using: tsp)
        guard let lesItems = paycheck.lesItems else { return taxableWage }
        
        taxableWage += lesItems.reduce(0.00) { sum, item in
            (item.type.isEntitlement && item.type != .allowance) ? sum + item.amount : sum
        }
        
        return taxableWage
    }
    
    private func federalTaxes(using withholdingForm: WithholdingForm, tsp: ThriftSavingsPlan)-> Decimal {
        return WithholdingTables.shared.calculateWithholding(
            for: paycheck.year,
            wage: wagePeriod(tsp: tsp),
            using: withholdingForm
        ) ?? 0.00
    }
    
    private func netPay(withholdingForm: WithholdingForm, tsp: ThriftSavingsPlan) -> Decimal {
        var netPay = grossPay
        netPay -= traditionalTSPContribution(using: tsp)
        netPay -= rothTSPContribution(using: tsp)
        
        netPay -= paycheck.lesItems?.reduce(0.00) { sum, item in
            item.type.isEntitlement ? sum : sum + item.amount
        } ?? 0.00
        
        netPay -= federalTaxes(using: withholdingForm, tsp: tsp)
        netPay -= medicare
        netPay -= socialSecurity
        
        return netPay
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
