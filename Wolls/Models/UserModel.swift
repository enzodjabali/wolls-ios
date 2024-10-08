struct User: Identifiable, Decodable {
    let id: String
    var pseudonym: String
    let firstname: String?
    let lastname: String?
    let email: String?
    let iban: String?
    let isGoogle: Bool?
    let is_administrator: Bool?
    let has_accepted_invitation: Bool?
    let balance: Float?
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case pseudonym
        case firstname
        case lastname
        case email
        case iban
        case isGoogle
        case is_administrator
        case has_accepted_invitation
        case balance
    }
}

struct UserStatus: Codable, Identifiable {
    let id: String
    let pseudonym: String
    let hasAcceptedInvitation: Bool
    let hasPendingInvitation: Bool
    var is_administrator: Bool
    let balance: Float?

    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case pseudonym
        case hasAcceptedInvitation = "has_accepted_invitation"
        case hasPendingInvitation = "has_pending_invitation"
        case is_administrator
        case balance
    }
}
