import Foundation
import SwiftData

@Model
final class Paycheck: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var lesData: LESData
    var myPayData: MyPayData
    var tspData: TSPData
    
    private var year: Int { Calendar.current.component(.year, from: lesData.date) }
    
    var traditionalTspContribution: Decimal {
        lesData.basePay.amount * Decimal(tspData.traditionalTspPercentage)
    }
    
    var rothTspContribution: Decimal {
        lesData.basePay.amount * Decimal(tspData.rothTspPercentage)
    }
    
    var wagePeriod: Decimal {
        lesData.basePay.amount + lesData.specialPays.reduce(0.00) { $0 + $1.amount } - traditionalTspContribution
    }

    var federalTaxes: Decimal {
        guard let taxData = TaxYears.shared.taxData(for: year) else {
            fatalError("No tax data found for \(year.description)")
        }
        
        return taxData.calculateWithholding(for: wagePeriod, using: myPayData)
    }
    
    var medicare: Decimal {
        guard let taxData = TaxYears.shared.taxData(for: year) else {
            fatalError("No tax data found for \(year.description)")
        }
        
        return (lesData.basePay.amount * taxData.medicareRate).rounded(.toNearestOrAwayFromZero, digits: 2)
    }
    
    var socialSecurity: Decimal {
        guard let taxData = TaxYears.shared.taxData(for: year) else {
            fatalError("No tax data found for \(year.description)")
        }
        
        return (lesData.basePay.amount * taxData.socialSecurityRate).rounded(.toNearestOrAwayFromZero, digits: 2)
    }
    
    var netPay: Decimal {
        var net = lesData.grossPay
        net -= traditionalTspContribution + rothTspContribution
        net -= lesData.deductions.reduce(0.00) { $0 + $1.amount } + lesData.allotments.reduce(0.00) { $0 + $1.amount }
        net -= federalTaxes
        net -= medicare + socialSecurity
        
        return net
    }
    
    /// Creates a new paycheck.
    /// - Parameters:
    ///   - name: Name of paycheck.
    ///   - myPayData: myPay data for paycheck.
    ///   - tspData: TSP data for paycheck.
    ///   - lesData: LES data for paycheck.
    init(
        name: String,
        lesData: LESData = LESData(),
        myPayData: MyPayData = MyPayData(),
        tspData: TSPData = TSPData(),
    ) {
        self.id = UUID()
        self.name = name
        self.lesData = lesData
        self.myPayData = myPayData
        self.tspData = tspData
    }
    
    /// Creates a new paycheck from another paycheck.
    /// - Parameter paycheck: Paycheck to copy.
    convenience init(_ other: Paycheck) {
        var lesData = LESData()
        lesData.date = other.lesData.date
        lesData.basePay = LESItem(
            name: other.lesData.basePay.name,
            amount: other.lesData.basePay.amount
        )
        lesData.allowances = other.lesData.allowances.map { LESItem(name: $0.name, amount: $0.amount) }
        lesData.specialPays = other.lesData.specialPays.map { LESItem(name: $0.name, amount: $0.amount) }
        lesData.deductions = other.lesData.deductions.map { LESItem(name: $0.name, amount: $0.amount) }
        lesData.allotments = other.lesData.allotments.map { LESItem(name: $0.name, amount: $0.amount) }
        
        self.init(name: other.name, lesData: lesData, myPayData: other.myPayData, tspData: other.tspData)
    }
    
    static let example = Paycheck(
        name: "Example",
        lesData: LESData.example,
        myPayData: MyPayData.example,
        tspData: TSPData.example
    )
}
