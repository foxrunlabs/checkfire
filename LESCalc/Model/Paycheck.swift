import Foundation
import SwiftData

@Model
final class Paycheck: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var date: Date
    var myPayData: MyPayData
    var lesData: LESData
    
    private var year: Int { Calendar.current.component(.year, from: date) }
    
    var traditionalTspContribution: Decimal {
        lesData.basePay * Decimal(myPayData.traditionalTspPercentage)
    }
    
    var rothTspContribution: Decimal {
        lesData.basePay * Decimal(myPayData.rothTspPercentage)
    }
    
    var wagePeriod: Decimal {
        lesData.basePay + lesData.specialPays - traditionalTspContribution
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
        
        return (lesData.basePay * taxData.medicareRate).rounded(.toNearestOrAwayFromZero, digits: 2)
    }
    
    var socialSecurity: Decimal {
        guard let taxData = TaxYears.shared.taxData(for: year) else {
            fatalError("No tax data found for \(year.description)")
        }
        
        return (lesData.basePay * taxData.socialSecurityRate).rounded(.toNearestOrAwayFromZero, digits: 2)
    }
    
    var netPay: Decimal {
        var net = lesData.grossPay
        net -= traditionalTspContribution + rothTspContribution
        net -= lesData.otherDeductions + lesData.allotments
        net -= federalTaxes
        net -= medicare + socialSecurity
        
        return net
    }
    
    /// Creates a new paycheck.
    /// - Parameters:
    ///   - name: Name of paycheck.
    ///   - date: Date of paycheck.
    ///   - myPayData: myPay data for paycheck.
    ///   - lesData: LES data for paycheck.
    init(name: String, date: Date, myPayData: MyPayData = MyPayData(), lesData: LESData = LESData()) {
        self.id = UUID()
        self.name = name
        self.date = date
        self.myPayData = myPayData
        self.lesData = lesData
    }
    
    static let example = Paycheck(
        name: "Example",
        date: DateComponents(calendar: Calendar.current, year: 2025, month: 1, day: 1).date!,
        myPayData: MyPayData.example,
        lesData: LESData.example
    )
}
