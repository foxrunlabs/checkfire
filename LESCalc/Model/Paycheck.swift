import Foundation
import SwiftData

@Model
final class Paycheck: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var year: Int
    var myPayData: MyPayData
    var lesData: LESData
    
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
    ///   - myPayData: myPay data for paycheck.
    ///   - lesData: LES data for paycheck.
    init(name: String, year: Int, myPayData: MyPayData = MyPayData(), lesData: LESData = LESData()) {
        self.id = UUID()
        self.name = name
        self.year = year
        self.myPayData = myPayData
        self.lesData = lesData
    }
    
    static let example = Paycheck(
        name: "Example",
        year: TaxYears.shared.years.last!,
        myPayData: MyPayData.example,
        lesData: LESData.example
    )
}
