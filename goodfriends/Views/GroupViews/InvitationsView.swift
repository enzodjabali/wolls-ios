import SwiftUI

struct InvitationRow: View {
    let group: Group
    let acceptAction: () -> Void
    let declineAction: () -> Void
    
    @State private var feedback: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text(group.name)
                .font(.headline)
            Text(group.description)
                .font(.subheadline)
                .foregroundColor(.gray)
            HStack {
                Button(action: acceptAction) {
                    Text("Accept")
                        .bold() // Make text bold
                }
                Button(action: declineAction) {
                    Text("Decline")
                        .bold() // Make text bold
                        .foregroundColor(.red) // Make text red
                }
            }
        }
        
    }
}

struct InvitationsView: View {
    @ObservedObject var groupMembershipController = GroupMembershipController.shared
    @State private var invitations: [Group] = []
    
    var body: some View {
        VStack {
         
            if invitations.isEmpty {
                Text("No invitations")
                    .padding()
            } else {
                List(invitations, id: \.id) { group in
                    InvitationRow(group: group, acceptAction: {
                        self.respondToInvitation(groupId: group.id, accept: true)
                    }, declineAction: {
                        self.respondToInvitation(groupId: group.id, accept: false)
                    })
                }
            }
        }
        .onAppear {
            fetchInvitations()
        }
    }
    
    func fetchInvitations() {
        groupMembershipController.fetchInvitations { result in
            switch result {
            case .success(let groups):
                self.invitations = groups
            case .failure(let error):
                print("Error fetching invitations: \(error.localizedDescription)")
            }
        }
    }
    
    func respondToInvitation(groupId: String, accept: Bool) {
        groupMembershipController.respondToInvitation(groupId: groupId, accept: accept) { result in
            switch result {
            case .success:
                // Invitation response successful, update UI or perform any necessary action
                fetchInvitations() // Refresh invitations after responding
            case .failure(let error):
                print("Error responding to invitation: \(error.localizedDescription)")
                // Handle error
            }
        }
    }
}
