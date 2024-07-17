import SwiftUI

struct AvatarView: View {
    let initials: String

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.white.opacity(0.4)]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 0
                    )
                )
                .frame(width: 35, height: 35) // Circle size
            Text(initials)
                .font(.system(size: 16)) // Adjust font size
                .foregroundColor(.white)
        }
    }
}
