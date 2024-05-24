struct User: Decodable, Identifiable {
    let _id: String
    let pseudonym: String
    let firstname: String?
    let lastname: String?
    let email: String?
    let iban: String?

    var id: String { _id } // Using _id as the identifier
}
