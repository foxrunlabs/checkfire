import SwiftData
import SwiftUI

struct NetPayView: View {
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
    
    private let paycheck: Paycheck
    
    @Query private var withholdingForms: [WithholdingForm]
    @Query private var thriftSavingsPlans: [ThriftSavingsPlan]
    
    private var grossPay: Decimal {
        var gross = paycheck.basicPay + paycheck.bas + paycheck.bah
        gross += paycheck.lesItems?.reduce(0.00) { sum, item in
            item.type.isEntitlement ? sum + item.amount : sum
        } ?? 0.00
        return gross
    }
    
    private var traditionalTSPContribution: Decimal? {
        guard let tsp = thriftSavingsPlans.last else { return nil }
        
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
    
    var rothTSPContribution: Decimal? {
        guard let tsp = thriftSavingsPlans.last else { return nil }
        
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
    
    var wagePeriod: Decimal? {
        guard let traditionalTSPContribution else { return nil }
        var taxableWage = paycheck.basicPay - traditionalTSPContribution
        guard let lesItems = paycheck.lesItems else { return taxableWage }
        
        taxableWage += lesItems.reduce(0.00) { sum, item in
            (item.type.isEntitlement && item.type != .allowance) ? sum + item.amount : sum
        }
        
        return taxableWage
    }
    
    var federalTaxes: Decimal? {
        guard let withholdingForm = withholdingForms.last else { return nil }
        guard let wagePeriod else { return nil }
        
        return WithholdingTables.shared.calculateWithholding(
            for: paycheck.year,
            wage: wagePeriod,
            using: withholdingForm
        )
    }
    
    var socialSecurity: Decimal? {
        WithholdingTables.shared.calculateSocialSecurity(
            for: paycheck.year,
            wage: paycheck.basicPay
        )
    }
    
    var medicare: Decimal? {
        WithholdingTables.shared.calculateMedicare(
            for: paycheck.year,
            wage: paycheck.basicPay
        )
    }
    
    var netPay: Decimal? {
        guard let traditionalTSPContribution else { return nil }
        guard let rothTSPContribution else { return nil }
        guard let federalTaxes = federalTaxes else { return nil }
        guard let medicare = medicare else { return nil }
        guard let socialSecurity = socialSecurity else { return nil }
        
        var netPay = grossPay
        netPay -= traditionalTSPContribution
        netPay -= rothTSPContribution
        
        netPay -= paycheck.lesItems?.reduce(0.00) { sum, item in
            item.type.isEntitlement ? sum : sum + item.amount
        } ?? 0.00
        
        netPay -= federalTaxes
        netPay -= medicare
        netPay -= socialSecurity
        
        return netPay
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
                        if let withholdingForm = withholdingForms.last {
                            Text(withholdingForm.date, format: .dateTime.month().year())
                        } else {
                            HStack {
                                Image(systemName: "exclamationmark.triangle")
                                Text("Missing Form")
                            }
                        }
                    }
                    
                    LabeledContent("Thrift Savings Plan") {
                        if let tsp = thriftSavingsPlans.last {
                            Text(tsp.date, format: .dateTime.month().year())
                        } else {
                            HStack {
                                Image(systemName: "exclamationmark.triangle")
                                Text("Missing Plan")
                            }
                        }
                    }
                }
            }
        }
    }
    
    private struct LabeledCurrency: View {
        init(_ label: String, value: Decimal?) {
            self.label = label
            self.value = value
        }
        
        private let label: String
        private let value: Decimal?
        
        var body: some View {
            LabeledContent {
                if let value {
                    Text(value.formatted(.currency(code: "USD")))
                } else {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                        Text("Missing Data")
                    }
                }
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
