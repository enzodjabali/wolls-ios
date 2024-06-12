import SwiftUI

struct AvatarViewProfile: View {
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
                .frame(width: 200, height: 200) // Circle size
            Text(initials)
                .font(.custom("Arial Rounded MT Bold", size: 75)) // Rounded font
                .foregroundColor(.white)
        }
    }
}
