import Foundation

struct RefundSimplified: Codable, Identifiable {
    let id = UUID()
    let creatorPseudonym: String
    let recipientPseudonym: String
    let refundAmount: Double

    enum CodingKeys: String, CodingKey {
        case creatorPseudonym = "creator_pseudonym"
        case recipientPseudonym = "recipient_pseudonym"
        case refundAmount = "refund_amount"
    }
}

struct RefundRecipient: Codable, Identifiable {
    let id = UUID()
    let recipientPseudonym: String
    let refundAmount: Double

    enum CodingKeys: String, CodingKey {
        case recipientPseudonym = "recipient_pseudonym"
        case refundAmount = "refund_amount"
    }
}

struct RefundDetailed: Codable, Identifiable {
    let id = UUID()
    let expenseId: String
    let groupId: String
    let creatorPseudonym: String
    let expenseTitle: String
    let expenseCategory: String
    let refundRecipients: [RefundRecipient]

    enum CodingKeys: String, CodingKey {
        case expenseId = "expense_id"
        case groupId = "group_id"
        case creatorPseudonym = "creator_pseudonym"
        case expenseTitle = "expense_title"
        case expenseCategory = "expense_category"
        case refundRecipients = "refund_recipients"
    }
}
