import SwiftUI

struct GroupBoxView: View {
    let group: Group

    var body: some View {
        let backgroundImageName: String

        switch group.theme ?? "" {
        case "city":
            backgroundImageName = "group-theme-city-dark"
        case "desert":
            backgroundImageName = "group-theme-desert-dark"
        case "forest":
            backgroundImageName = "group-theme-forest-dark"
        default:
            backgroundImageName = "group-theme-city-light" // default theme
        }

        return ZStack(alignment: .topLeading) {
            Color(.red) // Background color of the box
                .cornerRadius(10)

            Image(backgroundImageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 150)
                .clipped()
                .cornerRadius(10)

            VStack(alignment: .leading) {
                Text(group.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding([.top, .leading], 8)
                    .shadow(radius: 3)

                if let description = group.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding([.leading, .bottom], 8)
                        .shadow(radius: 3)
                } else {
                    Text("No description available")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding([.leading, .bottom], 8)
                        .shadow(radius: 3)
                }
            }
        }
        .frame(height: 150)
    }
}
