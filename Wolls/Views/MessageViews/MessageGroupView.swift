import SwiftUI
import Combine
import Foundation
import SocketIO

var limit = 0

struct MessageGroupView: View {
    @ObservedObject var viewModel: GroupChatViewModel

    var body: some View {
        VStack {
            ScrollView {
                ScrollViewReader { scrollView in
                    VStack {
                        if limit < viewModel.messageCount {
                            Text("Pull down to load more messages")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .padding(.top, 10)
                        }

                        ForEach(Array(viewModel.messages.enumerated()), id: \.element.id) { index, message in
                            let isSameSenderAsPrevious = index > 0 && viewModel.messages[index - 1].senderId == message.senderId

                            HStack {
                                if message.senderId == UserSession.shared.userId {
                                    Spacer()
                                    Text(message.content)
                                        .padding(.horizontal, 13)
                                        .padding(.vertical, 8)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(17)
                                } else {
                                    Text(message.content)
                                        .padding(.horizontal, 13)
                                        .padding(.vertical, 8)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(17)
                                    Spacer()
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, isSameSenderAsPrevious ? -5 : 5)
                        }
                    }
                    // Scroll to bottom when any change is made (new message, fetch more messages, etc...)
                    .onChange(of: viewModel.messages.count) { _ in
                        if let lastMessage = viewModel.messages.last {
                            scrollView.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                    // Scroll to bottom when arrive on the page
                    .onAppear {
                        if let lastMessage = viewModel.messages.last {
                            scrollView.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            .padding(.top)
            .refreshable {
                viewModel.fetchMessages()
            }

            HStack {
                TextField("Type a message...", text: $viewModel.messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 30)

                Button(action: {
                    viewModel.sendMessage()
                }) {
                    Text("Send")
                        .bold()
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(viewModel.messageText.isEmpty)
            }
            .padding()
        }
        .navigationBarTitle("Group Chat", displayMode: .inline)
        .onAppear {
            limit = 50
            viewModel.fetchMessages() // Fetch messages on appear
            viewModel.connect()
            viewModel.fetchMessageCount() // Fetch message count on appear
        }
        .onDisappear {
            viewModel.disconnect()
        }
    }
}

class GroupChatViewModel: ObservableObject {
    @Published var messages: [MessageGroup] = []
    @Published var messageText: String = ""
    @Published var messageCount: Int = 0
    private var manager: SocketManager
    private var socket: SocketIOClient
    private var groupId: String

    init(groupId: String) {
        self.groupId = groupId
        self.manager = SocketManager(socketURL: URL(string: "http://localhost:3002")!, config: [.log(true), .compress])
        self.socket = manager.defaultSocket

        socket.on(clientEvent: .connect) { data, ack in
            print("Socket connected")
            self.socket.emit("join_room", self.groupId)
        }

        socket.on("group_message") { data, ack in
            guard let messageData = data[0] as? [String: Any],
                  let id = messageData["_id"] as? String,
                  let senderId = messageData["senderId"] as? String,
                  let pseudonym = messageData["pseudonym"] as? String,
                  let content = messageData["content"] as? String else { return }

            print(messageData)
            let message = MessageGroup(id: id, senderId: senderId, pseudonym: pseudonym, content: content)
            DispatchQueue.main.async {
                self.messages.append(message)
            }
        }

        socket.on(clientEvent: .disconnect) { data, ack in
            print("Socket disconnected")
        }
    }

    func connect() {
        socket.connect()
    }
    
    func disconnect() {
        socket.disconnect()
    }

    func sendMessage() {
        let content = messageText
        messageText = ""

        MessageController.shared.sendMessage(groupId: groupId, content: content) { result in
            switch result {
            case .success():
                print("Message sent successfully")
            case .failure(let error):
                print("Failed to send message: \(error.localizedDescription)")
            }
        }
    }
    
    // Function to fetch messages on demand
    func fetchMessages() {
        MessageController.shared.fetchMessages(groupId: self.groupId, offset: 0, limit: limit) { result in
            switch result {
            case .success(let messages):
                DispatchQueue.main.async {
                    self.messages = messages
                }
                print("MESSAGES HISTORY:")
                print(messages)
                limit += 10
            case .failure(let error):
                print("Failed to fetch messages: \(error.localizedDescription)")
            }
        }
    }

    func fetchMessageCount() {
        MessageController.shared.getMessageCount(groupId: self.groupId) { result in
            switch result {
            case .success(let count):
                DispatchQueue.main.async {
                    self.messageCount = count
                }
            case .failure(let error):
                print("Failed to fetch message count: \(error.localizedDescription)")
            }
        }
    }

    private var currentUserId: String? {
        return UserSession.shared.userId
    }
}
