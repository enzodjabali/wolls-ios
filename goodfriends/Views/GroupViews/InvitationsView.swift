import SwiftUI

struct InvitationsView: View {
    @State private var invitations: [Group] = []
    @State private var fetchError: String?
    @State private var isLoading: Bool = true
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading...")
                        .padding()
                } else if let error = fetchError {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    if invitations.isEmpty {
                        Text("No invitations")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        List {
                            ForEach(invitations) { invitation in
                                InvitationRow(invitation: invitation)
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Invitations")
            .onAppear {
                fetchInvitations()
            }
        }
    }
    
    func fetchInvitations() {
        GroupMembershipController.shared.fetchInvitations { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedInvitations):
                    invitations = fetchedInvitations
                    isLoading = false
                case .failure(let error):
                    fetchError = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

struct InvitationRow: View {
    let invitation: Group
    
    var body: some View {
        HStack {
            Text(invitation.name)
            Spacer()
            Button("Accept") {
                acceptInvitation()
            }
            .foregroundColor(.green)
            Button("Deny") {
                denyInvitation()
            }
            .foregroundColor(.red)
        }
        .padding()
    }
    
    func acceptInvitation() {
        // Call the accept invitation API
        GroupMembershipController.shared.respondToInvitation(invitationId: invitation.id, accept: true) { result in
            // Handle the result
        }
    }
    
    func denyInvitation() {
        // Call the deny invitation API
        GroupMembershipController.shared.respondToInvitation(invitationId: invitation.id, accept: false) { result in
            // Handle the result
        }
    }
}
