struct Group: Identifiable, Decodable {
    let _id: String
    let name: String
    let description: String?
    let theme: String?
    let createdAt: String?
    var administrators: [String]?

    var id: String { _id }
}
