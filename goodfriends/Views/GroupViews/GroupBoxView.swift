import SwiftUI

struct GroupBoxView: View {
    let group: Group

    var body: some View {
        let backgroundImageName: String
        let overlayColor: Color

        switch group.theme {
        case "city":
            backgroundImageName = "group-theme-city"
            overlayColor = Color.blue.opacity(0.3)
        case "desert":
            backgroundImageName = "group-theme-desert"
            overlayColor = Color.orange.opacity(0.3)
        case "forest":
            backgroundImageName = "group-theme-forest"
            overlayColor = Color.green.opacity(0.3)
        default:
            backgroundImageName = "group-theme-city" // default theme
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

                Text(group.description)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding([.leading, .bottom], 8)
                    .shadow(radius: 3)
            }
        }
        .frame(height: 150)
    }
}
