struct Group: Identifiable, Decodable {
    let _id: String
    let name: String
    let description: String

    var id: String { _id }
}
