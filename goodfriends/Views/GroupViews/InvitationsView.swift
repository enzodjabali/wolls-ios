import SwiftUI

struct InvitationsView: View {
    @ObservedObject var groupMembershipController = GroupMembershipController.shared
    @State private var invitations: [Group] = []
    
    var body: some View {
        ScrollView {
            if invitations.isEmpty {
                ZStack {
                    // Reserve space matching the scroll view's frame
                    Spacer().containerRelativeFrame([.horizontal, .vertical])

                    // Form content
                    VStack {
                        Text("You have no pending invitations yet.")
                            .foregroundColor(.gray)
                    }
                    .padding()
                }
                .onAppear {
                    // Fetch invitations when the view appears
                    self.fetchInvitations()
                }
            } else {
                VStack(spacing: 20) {
                    ForEach(invitations, id: \.id) { group in
                        InvitationRow(group: group) { accept in
                            // Respond to invitation
                            self.respondToInvitation(group: group, accept: accept)
                        }
                    }
                }
                .padding()
                .onAppear {
                    // Fetch invitations when the view appears
                    self.fetchInvitations()
                }
            }
        }
        .background(Color.gray.opacity(0.1)) // Background color for the entire page
        .navigationTitle("Invitations")
        .refreshable {
            self.fetchInvitations()
        }
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
                Text("You've been invited to join ")
                    .font(.body)
                    + Text(group.name)
                    .font(.body)
                    .bold()
                
                HStack(spacing: 20) {
                    Button(action: {
                        self.respondAction(true) // Accept action
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
                        self.respondAction(false) // Decline action
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
        .padding()
        .background(Color.white) // Background color for the box
        .cornerRadius(10) // Border radius for the box
        .padding(.horizontal) // Horizontal padding for the box
        .frame(maxWidth: .infinity) // Ensure the container takes up the whole width
    }
}
