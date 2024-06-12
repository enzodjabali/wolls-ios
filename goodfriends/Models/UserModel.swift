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
    }
}

// This is used for the delete account
enum UserDeletionError: Error {
    case network(Error)
    case ownsGroups([Group])
    case unknown
}

struct UserStatus: Codable {
    let id: String
    let pseudonym: String
    let hasAcceptedInvitation: Bool
    let hasPendingInvitation: Bool

    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case pseudonym
        case hasAcceptedInvitation = "has_accepted_invitation"
        case hasPendingInvitation = "has_pending_invitation"
    }
}
