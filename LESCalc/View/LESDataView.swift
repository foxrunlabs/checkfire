import SwiftUI

struct LESDataView: View {
    @Bindable var paycheck: Paycheck
    
    @State private var lesData = LESData()
    @State private var editAllotments = false
    
    private var dateRange: ClosedRange<Date> {
        let startDate = DateComponents(
            calendar: .current,
            year: TaxYears.shared.years.first!,
            month: 1, day: 1
        ).date!
        
        let lastDate = DateComponents(
            calendar: .current,
            year: TaxYears.shared.years.last!,
            month: 12,
            day: 31
        ).date!
        
        return startDate...lastDate
    }
    
    var body: some View {
        Form {
            DatePicker("Pay Date",
                selection: $paycheck.date,
                in: dateRange,
                displayedComponents: .date
            )
            
            Section("Entitlements") {
                LabeledContent("Base Pay") {
                    TextField(
                        "Base Pay",
                        value: $lesData.basePay,
                        format: .currency(code: "USD")
                    )
                    .multilineTextAlignment(.trailing)
                    .onSubmit {
                        paycheck.lesData.basePay = lesData.basePay
                    }
                }
                
                ForEach($lesData.specialPays) { $specialPay in
                    LabeledContent(specialPay.name) {
                        TextField(
                            specialPay.name,
                            value: $specialPay.amount,
                            format: .currency(code: "USD")
                        )
                        .multilineTextAlignment(.trailing)
                        .onSubmit {
                            paycheck.lesData.specialPays = lesData.specialPays
                        }
                    }
                }
                
                ForEach($lesData.allowances) { $allowance in
                    LabeledContent(allowance.name) {
                        TextField(
                            allowance.name,
                            value: $allowance.amount,
                            format: .currency(code: "USD")
                        )
                        .multilineTextAlignment(.trailing)
                        .onSubmit {
                            paycheck.lesData.allowances = lesData.allowances
                        }
                    }
                }
            }
            
            Section("Deductions") {
                ForEach($lesData.deductions) { $deduction in
                    LabeledContent(deduction.name) {
                        TextField(
                            deduction.name,
                            value: $deduction.amount,
                            format: .currency(code: "USD")
                        )
                        .multilineTextAlignment(.trailing)
                        .onSubmit {
                            paycheck.lesData.deductions = lesData.deductions
                        }
                    }
                }
            }
            
            Section {
                ForEach($lesData.allotments) { $allotment in
                    LabeledContent {
                        TextField(
                            allotment.name,
                            value: $allotment.amount,
                            format: .currency(code: "USD")
                        )
                        .multilineTextAlignment(.trailing)
                        .onSubmit {
                            paycheck.lesData.allotments = lesData.allotments
                        }
                    } label: {
                       HStack {
                           if editAllotments {
                               Button(role: .destructive) {
                                   withAnimation {
                                       lesData.allotments.removeAll { $0.id == allotment.id }
                                   }
                                   
                                   paycheck.lesData.allotments = lesData.allotments
                               } label: {
                                   Image(systemName: "trash")
                               }
                               .buttonStyle(.borderless)
                           }
                           
                           TextField("Name", text: $allotment.name)
                               .disabled(editAllotments == false)
                       }
                   }
                }
            } header: {
                HStack {
                    Text("Allotments")
                    
                    Spacer()
                    
                    if editAllotments == false {
                        Button {
                            withAnimation { editAllotments.toggle() }
                        } label: {
                            Text("Edit")
                                .font(.body.smallCaps())
                        }
                    } else {
                        Button {
                            let newLESItem = LESItem(name: "New Allotment", amount: 0.00)
                            
                            withAnimation {
                                lesData.allotments.append(newLESItem)
                            }
                            
                            paycheck.lesData.allotments = lesData.allotments
                        } label: {
                            Image(systemName: "plus")
                                .font(.body.smallCaps())
                        }
                        
                        Button {
                            withAnimation { editAllotments.toggle() }
                        } label: {
                            Text("Done")
                                .font(.body.smallCaps())
                        }
                    }
                }
            }
        }
        .onAppear {
            lesData = paycheck.lesData
        }
        .onDisappear {
            lesData = LESData()
        }
    }
}

#Preview {
    @Previewable @State var paycheck = Paycheck.example
    LESDataView(paycheck: paycheck)
}
