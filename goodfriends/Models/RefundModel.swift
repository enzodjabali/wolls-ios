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
