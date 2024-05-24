import SwiftUI

struct GroupBoxView: View {
    let group: Group

    var body: some View {
        ZStack(alignment: .topLeading) {
            Image("group-background-buildings") // Placeholder for the background image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 150)
                .clipped()
                .cornerRadius(10)

            Color.blue.opacity(0.3)
                .cornerRadius(10)

            VStack(alignment: .leading) {
                Text(group.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding([.top, .leading], 8)
                    .shadow(radius: 1)
                Text(group.description)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding([.leading, .bottom], 8)
                    .shadow(radius: 1)
            }
        }
        .frame(height: 150)
    }
}
