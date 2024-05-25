import SwiftUI

struct InvitationsView: View {
    @ObservedObject var groupMembershipController = GroupMembershipController.shared
    @State private var invitations: [Group] = []
    
    var body: some View {
        VStack {
            List(invitations, id: \.id) { group in
                InvitationRow(group: group) { accept in
                    // Respond to invitation
                    self.respondToInvitation(group: group, accept: accept)
                }
            }
            .onAppear {
                // Fetch invitations when the view appears
                self.fetchInvitations()
            }
        }
        .navigationTitle("Invitations")
    }
    
    private func fetchInvitations() {
        groupMembershipController.fetchInvitations { result in
            switch result {
            case .success(let groups):
                self.invitations = groups
            case .failure(let error):
                // Handle error
                print("Error fetching invitations: \(error.localizedDescription)")
            }
        }
    }
    
    private func respondToInvitation(group: Group, accept: Bool) {
        groupMembershipController.respondToInvitation(groupId: group.id, accept: accept) { result in
            switch result {
            case .success:
                // Refresh invitations after responding
                self.fetchInvitations()
            case .failure(let error):
                // Handle error
                print("Error responding to invitation: \(error.localizedDescription)")
            }
        }
    }
}

struct InvitationRow: View {
    let group: Group
    let respondAction: (Bool) -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("You've been invited you to join ")
                    .font(.body)
                    + Text(group.name)
                    .font(.body)
                    .bold()
                
                HStack(spacing: 20) {
                    Button(action: {
                        self.respondAction(true)
                    }) {
                        Text("Accept")
                            .foregroundColor(Color.white)
                            .padding(4)
                            .frame(width: 80)
                            .background(Color.blue)
                            .cornerRadius(20)
                    }
                    .padding(.top, 5) // Add padding above the button

                    Button(action: {
                        self.respondAction(false)
                    }) {
                        Text("Decline")
                            .foregroundColor(Color.blue)
                            .padding(4)
                            .frame(width: 80)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                            .background(Color.white)
                            .cornerRadius(20)
                    }
                    .padding(.top, 5) // Add padding above the button
                }
            }
            Spacer() // Add spacer to push buttons to the left
        }
    }
}
