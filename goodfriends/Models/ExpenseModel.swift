struct Expense: Identifiable, Decodable {
    let id: String
    let title: String
    let amount: Double
    let date: String
    let creator_id: String
    let creator_pseudonym: String?
    let group_id: String
    let category: String
    let refund_recipients: [String]
    let isRefunded: Bool
    let __v: Int
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case amount
        case date
        case creator_id
        case creator_pseudonym
        case group_id
        case category
        case refund_recipients
        case isRefunded
        case __v
    }
}
