struct Expense: Identifiable, Decodable {
    let id: String // Assuming _id in JSON is a String
    let title: String
    let amount: Double
    let date: String // Assuming date is in String format
    let creator_id: String
    let creator_pseudonym: String
    let group_id: String
    let category: String
    let refund_recipients: [String]
    let isRefunded: Bool
    let __v: Int
    
    // You can add additional properties if needed
    
    // Define CodingKeys enum to map JSON keys to Swift properties
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
    
    // Implement custom decoding to handle specific cases, if necessary
    // If the date format is not standard, you may need to implement custom date decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        amount = try container.decode(Double.self, forKey: .amount)
        date = try container.decode(String.self, forKey: .date)
        creator_id = try container.decode(String.self, forKey: .creator_id)
        creator_pseudonym = try container.decode(String.self, forKey: .creator_pseudonym)
        group_id = try container.decode(String.self, forKey: .group_id)
        category = try container.decode(String.self, forKey: .category)
        refund_recipients = try container.decode([String].self, forKey: .refund_recipients)
        isRefunded = try container.decode(Bool.self, forKey: .isRefunded)
        __v = try container.decode(Int.self, forKey: .__v)
    }
}
