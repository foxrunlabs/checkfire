import SwiftUI

struct PaycheckDatePicker: View {
    private let title: String
    @Binding private var selection: Date
    private let yearRange: ClosedRange<Int>
    
    @State private var showPicker = false
    
    init(_ title: String, selection: Binding<Date>, in yearRange: ClosedRange<Int>) {
        self.title = title
        self._selection = selection
        self.yearRange = yearRange
    }
    
    var body: some View {
        LabeledContent {
            Button(selection.formatted(.dateTime.month().year())) {
                showPicker.toggle()
            }
            .buttonStyle(.borderless)
            .popover(isPresented: $showPicker, arrowEdge: .top) {
                PickerView(selection: $selection, in: yearRange)
                    .presentationCompactAdaptation(.popover)
            }
        } label: {
            Text(title)
        }
    }
}

fileprivate struct PickerView: View {
    @Binding private var selection: Date
    private let yearRange: ClosedRange<Int>
    
    init(selection: Binding<Date>, in yearRange: ClosedRange<Int>) {
        self._selection = selection
        self.yearRange = yearRange
    }
    
    var body: some View {
        VStack {
            YearStepper(selection: $selection, in: yearRange)
            
            Grid {
                GridRow {
                    MonthPicker(.january, selection: $selection)
                    MonthPicker(.february, selection: $selection)
                    MonthPicker(.march, selection: $selection)
                }
                
                GridRow {
                    MonthPicker(.april, selection: $selection)
                    MonthPicker(.may, selection: $selection)
                    MonthPicker(.june, selection: $selection)
                }
                
                GridRow {
                    MonthPicker(.july, selection: $selection)
                    MonthPicker(.august, selection: $selection)
                    MonthPicker(.september, selection: $selection)
                }
                
                GridRow {
                    MonthPicker(.october, selection: $selection)
                    MonthPicker(.november, selection: $selection)
                    MonthPicker(.december, selection: $selection)
                }
            }
        }
        .padding()
    }
}

fileprivate struct YearStepper: View {
    @Binding private var selection: Date
    private let yearRange: ClosedRange<Int>
    
    private var selectionYear: Int {
        get {
            Calendar.current.component(.year, from: selection)
        }
        nonmutating set {
            let components = DateComponents(year: newValue, month: selectionMonth, day: 1)
            selection = Calendar.current.date(from: components)!
        }
    }
    
    private var selectionMonth: Int {
            Calendar.current.component(.month, from: selection)
    }
    
    init(selection: Binding<Date>, in yearRange: ClosedRange<Int>) {
        self._selection = selection
        self.yearRange = yearRange
    }
    
    var body: some View {
        HStack {
            Button {
                selectionYear = max(yearRange.lowerBound, selectionYear - 1)
            } label: {
                Image(systemName: "chevron.left")
                    .bold()
            }
            .disabled(selectionYear == yearRange.lowerBound)
            
            Text(selection.formatted(.dateTime.year()))
                .foregroundStyle(.primary)
                .bold()
            
            Button {
                selectionYear = min(selectionYear + 1, yearRange.upperBound)
            } label: {
                Image(systemName: "chevron.right")
                    .bold()
            }
            .disabled(selectionYear == yearRange.upperBound)
        }
    }
}

fileprivate enum Month: Int, CustomStringConvertible {
    case january = 1
    case february, march, april, may, june, july, august, september, october, november, december
    
    var description: String {
        switch self {
        case .january: "Jan"
        case .february: "Feb"
        case .march: "Mar"
        case .april: "Apr"
        case .may: "May"
        case .june: "Jun"
        case .july: "Jul"
        case .august: "Aug"
        case .september: "Sep"
        case .october: "Oct"
        case .november: "Nov"
        case .december: "Dec"
        }
    }
}

fileprivate struct MonthPicker: View {
    private let month: Month
    @Binding private var selection: Date
    
    init(_ month: Month, selection: Binding<Date>) {
        self.month = month
        self._selection = selection
    }
    
    var body: some View {
        Text(month.description)
            .frame(width: 50, height: 35)
            .bold(selection.month == month.rawValue)
            .foregroundStyle(selection.month == month.rawValue ? Color.accentColor : .primary)
            .background(selection.month == month.rawValue ? Color.accentColor.opacity(0.25) : .clear)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .onTapGesture {
                selection.month = month.rawValue
            }
    }
}

#Preview {
    @Previewable @State var date: Date = .now
    
    Form {
        PaycheckDatePicker(
            "Pay Date",
            selection: $date,
            in: TaxYears.shared.years.first!...TaxYears.shared.years.last!
        )
    }
}
