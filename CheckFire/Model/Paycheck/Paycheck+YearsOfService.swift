// MARK: - Years of Service
extension Paycheck {
    enum YearsOfService:
        String,
        CaseIterable,
        Codable,
        CustomStringConvertible,
        Identifiable
    {
        case lessThan4Months = "lt_4_months"
        case lessThanOrEqual2 = "le_2"
        case over2 = "gt_2"
        case over3 = "gt_3"
        case over4 = "gt_4"
        case over6 = "gt_6"
        case over8 = "gt_8"
        case over10 = "gt_10"
        case over12 = "gt_12"
        case over14 = "gt_14"
        case over16 = "gt_16"
        case over18 = "gt_18"
        case over20 = "gt_20"
        case over22 = "gt_22"
        case over24 = "gt_24"
        case over26 = "gt_26"
        case over28 = "gt_28"
        case over30 = "gt_30"
        case over32 = "gt_32"
        case over34 = "gt_34"
        case over36 = "gt_36"
        case over38 = "gt_38"
        case over40 = "gt_40"
        
        // MARK: - CustomStringConvertible
        var description: String {
                switch self {
                case .lessThan4Months:
                    return "< 4 Months"
                default:
                    if rawValue.hasPrefix("gt_") {
                        return "Over \(rawValue.dropFirst(3))"
                    } else if rawValue.hasPrefix("le_") {
                        return "\(rawValue.dropFirst(3)) or Less"
                    } else {
                        return rawValue
                    }
                }
            }
        
        // MARK: - Identifiable
        var id: Self { self }
    }
}
