import Foundation
import SwiftData
import Testing
@testable import CheckFire

@Suite @MainActor
struct PaycheckPersistenceTests {
    @Test func saveFetchEditAndDelete() throws {
        let container = try ModelContainer(for: Paycheck.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let writer = ModelContext(container)
        writer.autosaveEnabled = false
        let p = paycheck(money("2345.67"))
        p.name = "Persisted"
        p.payGrade = .o3e
        p.yearsOfService = .over10
        p.lesItems = [.init("Bonus", amount: money("123.45"), category: .bonusPay),
                      .init("Allotment", amount: money("12.34"), category: .allotment)]
        p.withholdingForm = .init(maritalStatus: .headOfHousehold, multipleJobs: true, childDependents: 2,
                                  otherDependents: 1, otherIncome: 1200, deductions: 600, extraWithholding: money("7.89"))
        p.traditionalTSP = .init(basicPayRate: money("0.1"), specialPayRate: money("0.2"), incentivePayRate: money("0.3"), bonusPayRate: money("0.4"))
        p.rothTSP = .init(basicPayRate: money("0.05"), specialPayRate: money("0.06"), incentivePayRate: money("0.07"), bonusPayRate: money("0.08"))
        let system = PaySystem(tables: [fixture()])
        let before = try system.calculate(p)
        writer.insert(p)
        try writer.save()

        // A separate context forces decoding from the store rather than testing the same object.
        let reader = ModelContext(container)
        reader.autosaveEnabled = false
        let loaded = try #require(reader.fetch(FetchDescriptor<Paycheck>()).first)
        #expect(loaded !== p)
        #expect(loaded.name == p.name && loaded.date == p.date && loaded.basicPay == p.basicPay)
        #expect(loaded.payGrade == .o3e && loaded.yearsOfService == .over10)
        #expect(loaded.lesItems.map(\.name) == p.lesItems.map(\.name))
        #expect(loaded.lesItems.map(\.amount) == p.lesItems.map(\.amount))
        #expect(loaded.lesItems.map(\.category) == p.lesItems.map(\.category))
        #expect(loaded.lesItems.map(\.id) == p.lesItems.map(\.id))
        #expect(loaded.withholdingForm.maritalStatus == .headOfHousehold && loaded.withholdingForm.multipleJobs)
        #expect(loaded.withholdingForm.childDependents == 2 && loaded.withholdingForm.otherDependents == 1)
        #expect(loaded.withholdingForm.otherIncome == 1200 && loaded.withholdingForm.deductions == 600)
        #expect(loaded.withholdingForm.extraWithholding == money("7.89"))
        #expect(loaded.traditionalTSP.basicPayRate == money("0.1") && loaded.traditionalTSP.specialPayRate == money("0.2"))
        #expect(loaded.traditionalTSP.incentivePayRate == money("0.3") && loaded.traditionalTSP.bonusPayRate == money("0.4"))
        #expect(loaded.rothTSP.basicPayRate == money("0.05") && loaded.rothTSP.specialPayRate == money("0.06"))
        #expect(loaded.rothTSP.incentivePayRate == money("0.07") && loaded.rothTSP.bonusPayRate == money("0.08"))
        #expect(try system.calculate(loaded).netPay == before.netPay)

        loaded.basicPay = 3000
        loaded.lesItems[0].amount = 500
        loaded.withholdingForm.extraWithholding = 20
        loaded.traditionalTSP.basicPayRate = money("0.2")
        try reader.save()
        let verifier = ModelContext(container)
        let edited = try #require(verifier.fetch(FetchDescriptor<Paycheck>()).first)
        #expect(edited.basicPay == 3000 && edited.lesItems[0].amount == 500)
        #expect(edited.withholdingForm.extraWithholding == 20 && edited.traditionalTSP.basicPayRate == money("0.2"))
        #expect(try system.calculate(edited).netPay != before.netPay)
        verifier.delete(edited)
        try verifier.save()
        #expect(try ModelContext(container).fetchCount(FetchDescriptor<Paycheck>()) == 0)
    }

    @Test func diskStoreSurvivesContainerRecreation() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appendingPathComponent("Paychecks.store")
        func write() throws {
            let container = try ModelContainer(for: Paycheck.self, configurations: ModelConfiguration(url: url))
            let context = ModelContext(container)
            let p = paycheck(3000)
            p.lesItems = [.init("Special", amount: 500, category: .specialPay)]
            p.withholdingForm.extraWithholding = 25
            p.traditionalTSP.basicPayRate = money("0.1")
            context.insert(p)
            try context.save()
        }
        try write()
        let reopened = try ModelContainer(for: Paycheck.self, configurations: ModelConfiguration(url: url))
        let context = ModelContext(reopened)
        let records = try context.fetch(FetchDescriptor<Paycheck>())
        #expect(records.count == 1)
        let p = try #require(records.first)
        #expect(p.basicPay == 3000 && p.lesItems[0].amount == 500)
        #expect(p.withholdingForm.extraWithholding == 25 && p.traditionalTSP.basicPayRate == money("0.1"))
        // 3500 gross - 300 TSP - 365 federal - 186 Social Security - 43.50 Medicare.
        #expect(try PaySystem(tables: [fixture()]).calculate(p).netPay == money("2605.50"))
    }

    @Test func copyHasIndependentValuesAndFreshItemIDs() {
        let original = paycheck()
        original.lesItems = [.init("Allowance", amount: 100, category: .allowance)]
        original.withholdingForm.childDependents = 2
        original.traditionalTSP.basicPayRate = money("0.1")
        original.rothTSP.basicPayRate = money("0.2")
        let copy = Paycheck(original)
        #expect(copy !== original && copy.date == original.date && copy.name == original.name)
        #expect(copy.basicPay == original.basicPay && copy.payGrade == original.payGrade && copy.yearsOfService == original.yearsOfService)
        #expect(copy.lesItems[0].id != original.lesItems[0].id)
        #expect(copy.lesItems[0].amount == 100 && copy.lesItems[0].category == .allowance)
        copy.lesItems[0].amount = 200
        copy.withholdingForm.childDependents = 0
        copy.traditionalTSP.basicPayRate = 0
        copy.rothTSP.basicPayRate = 0
        #expect(original.lesItems[0].amount == 100 && original.withholdingForm.childDependents == 2)
        #expect(original.traditionalTSP.basicPayRate == money("0.1") && original.rothTSP.basicPayRate == money("0.2"))
    }

    @Test(arguments: [2024, 2025])
    func dateNormalizesToEndOfMonth(year: Int) {
        let date = Calendar.current.date(from: DateComponents(year: year, month: 2, day: 3))!
        let p = Paycheck(date: date)
        #expect(Calendar.current.component(.day, from: p.date) == (year == 2024 ? 29 : 28))
        #expect(p.year == year)
    }

    @Test(arguments: Paycheck.TSPType.allCases)
    func zeroBasicRateClearsOtherRates(type: Paycheck.TSPType) {
        let p = paycheck()
        let plan = Paycheck.ThriftSavingsPlan(basicPayRate: money("0.1"), specialPayRate: money("0.2"), incentivePayRate: money("0.3"), bonusPayRate: money("0.4"))
        p.traditionalTSP = plan
        p.rothTSP = plan
        switch type {
        case .traditional: p.traditionalTSP.basicPayRate = 0
        case .roth: p.rothTSP.basicPayRate = 0
        }
        let cleared = type == .traditional ? p.traditionalTSP : p.rothTSP
        #expect(cleared.specialPayRate == 0 && cleared.incentivePayRate == 0 && cleared.bonusPayRate == 0)
        let other = type == .traditional ? p.rothTSP : p.traditionalTSP
        #expect(other.specialPayRate == money("0.2"))
    }
}
