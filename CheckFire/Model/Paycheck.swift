import Foundation
import SwiftData

@Model
final class Paycheck: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var lesData: LESData
    var federalWithholdingData: FederalWithholdingData
    var tspData: TSPData
    
    private var year: Int { Calendar.current.component(.year, from: lesData.date) }
    
    var traditionalTspContribution: Decimal {
        // TODO: Compute other contributions
        lesData.basePay.amount * Decimal(tspData.traditionalBasePay)
    }
    
    var rothTspContribution: Decimal {
        // TODO: Compute other contributions
        lesData.basePay.amount * Decimal(tspData.rothBasePay)
    }
    
    var wagePeriod: Decimal {
        let taxableEntitlements = lesData.entitlements.filter { $0.itemType != .allowance }
        return lesData.basePay.amount + taxableEntitlements.reduce(0.00) { $0 + $1.amount } -
            traditionalTspContribution
    }

    var federalTaxes: Decimal {
        guard let taxData = TaxYears.shared.taxData(for: year) else {
            fatalError("No tax data found for \(year.description)")
        }
        
        return taxData.calculateWithholding(for: wagePeriod, using: federalWithholdingData)
    }
    
    var medicare: Decimal {
        guard let taxData = TaxYears.shared.taxData(for: year) else {
            fatalError("No tax data found for \(year.description)")
        }
        
        let medicateOwed = lesData.basePay.amount * taxData.medicareRate
        return medicateOwed.rounded(.toNearestOrAwayFromZero, digits: 2)
    }
    
    var socialSecurity: Decimal {
        guard let taxData = TaxYears.shared.taxData(for: year) else {
            fatalError("No tax data found for \(year.description)")
        }
        
        let socialSecurityOwed = lesData.basePay.amount * taxData.socialSecurityRate
        return socialSecurityOwed.rounded(.toNearestOrAwayFromZero, digits: 2)
    }
    
    var netPay: Decimal {
        var net = lesData.grossPay
        net -= traditionalTspContribution + rothTspContribution
        net -= lesData.deductions.reduce(0.00) { $0 + $1.amount }
        net -= lesData.allotments.reduce(0.00) { $0 + $1.amount }
        net -= federalTaxes
        net -= medicare + socialSecurity
        
        return net
    }
    
    /// Create a new paycheck.
    /// - Parameters:
    ///   - name: Name of paycheck.
    ///   - federalWithholdingData: Federal withholding data for paycheck.
    ///   - tspData: TSP data for paycheck.
    ///   - lesData: LES data for paycheck.
    init(
        name: String,
        lesData: LESData = LESData(),
        federalWithholdingData: FederalWithholdingData = FederalWithholdingData(),
        tspData: TSPData = TSPData(),
    ) {
        self.id = UUID()
        self.name = name
        self.lesData = lesData
        self.federalWithholdingData = federalWithholdingData
        self.tspData = tspData
    }
    
    /// Creates a new paycheck from another paycheck.
    /// - Parameter paycheck: Paycheck to copy.
    convenience init(_ other: Paycheck) {
        // deliberate copy of LESData due to UUIDs in LESItem.
        var lesData = LESData()
        lesData.date = other.lesData.date
        lesData.basePay = LESItem(
            name: "Base Pay",
            amount: other.lesData.basePay.amount,
            itemType: .basePay
        )
        lesData.entitlements = other.lesData.entitlements.map {
            LESItem(name: $0.name, amount: $0.amount, itemType: $0.itemType)
        }
        lesData.deductions = other.lesData.deductions.map {
            LESItem(name: $0.name, amount: $0.amount, itemType: .deduction)
        }
        lesData.allotments = other.lesData.allotments.map {
            LESItem(name: $0.name, amount: $0.amount, itemType: .allotment)
        }
        
        self.init(
            name: other.name,
            lesData: lesData,
            federalWithholdingData: other.federalWithholdingData,
            tspData: other.tspData
        )
    }
    
    static let example = Paycheck(
        name: "Example",
        lesData: LESData.example,
        federalWithholdingData: FederalWithholdingData.example,
        tspData: TSPData.example
    )
}
