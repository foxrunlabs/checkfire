extension WithholdingTable {
    enum Schedule: String, Decodable, CodingKeyRepresentable {
        case standard
        case multipleJobs
    }
}
