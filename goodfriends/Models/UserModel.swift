//struct User: Decodable, Identifiable {
//    let _id: String
//    let pseudonym: String
//    let firstname: String?
//    let lastname: String?
//    let email: String?
//    let iban: String?

//    var id: String { _id } // Using _id as the identifier
//}

struct User: Identifiable, Decodable {
    let id: String
    var pseudonym: String
    let firstname: String?
    let lastname: String?
    let email: String?
    let iban: String?
    let is_administrator: Bool?
    let has_accepted_invitation: Bool?
    
   // var id: String { _id } // Using _id as the identifier
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case pseudonym
        case firstname
        case lastname
        case email
        case iban
        case is_administrator
        case has_accepted_invitation
    }
}
