struct MessageGroup: Identifiable, Decodable {
    var id: String        // Rename this property to match the JSON key "_id"
    var senderId: String
    var groupId: String?   // Add this property for groupId
    var content: String
    var timestamp: String?   // Add this property for timestamp, make sure to decode it correctly
    var __v: Int?          // Add this property for __v
    
    // Map "_id" from JSON to id in Swift
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case senderId
        case groupId
        case content
        case timestamp
        case __v
    }
}
