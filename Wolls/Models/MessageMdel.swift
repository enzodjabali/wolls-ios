struct MessageGroup: Identifiable {
    var id: String
    var senderId: String
    var content: String
    var isSentByCurrentUser: Bool
}
