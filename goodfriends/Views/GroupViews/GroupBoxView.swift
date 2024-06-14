import SwiftUI

struct GroupBoxView: View {
    let group: Group

    var body: some View {
        let backgroundImageName: String
        let overlayColor: Color

        switch group.theme ?? "" {
        case "city":
            backgroundImageName = "group-theme-city-dark"
            overlayColor = Color.blue.opacity(0.0)
        case "desert":
            backgroundImageName = "group-theme-desert-dark"
            overlayColor = Color.orange.opacity(0.0)
        case "forest":
            backgroundImageName = "group-theme-forest-dark"
            overlayColor = Color.green.opacity(0.0)
        default:
            backgroundImageName = "group-theme-city-light" // default theme
            overlayColor = Color.blue.opacity(0.3)
        }

        return ZStack(alignment: .topLeading) {
            Image(backgroundImageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 150)
                .clipped()
                .cornerRadius(10)

            overlayColor
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
