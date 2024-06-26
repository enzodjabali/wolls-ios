import SwiftUI
import Combine
import Foundation
import SocketIO

struct GroupChatView: View {
    @ObservedObject var viewModel: GroupChatViewModel

    var body: some View {
        
        VStack {
            ScrollView {
                ScrollViewReader { scrollView in
                    ForEach(viewModel.messages) { message in
                        HStack {
                            if message.isSentByCurrentUser {
                                Spacer()
                                Text(message.content)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            } else {
                                Text(message.content)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .foregroundColor(.black)
                                    .cornerRadius(10)
                                Spacer()
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 5)
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        if let lastMessage = viewModel.messages.last {
                            scrollView.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            .padding(.top)

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
            viewModel.connect()
        }
        .onDisappear {
            viewModel.disconnect()
        }
    }
}


class GroupChatViewModel: ObservableObject {
    @Published var messages: [MessageGroup] = []
    @Published var messageText: String = ""
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
                  let content = messageData["content"] as? String else { return }

            print(messageData)
            let message = MessageGroup(id: id, senderId: senderId, content: content, isSentByCurrentUser: senderId == self.currentUserId)
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

    private var currentUserId: String? {
        return UserSession.shared.userId
    }
}
