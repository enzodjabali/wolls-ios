import SwiftUI

struct GroupBoxView: View {
    let group: Group
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        let backgroundImageName: String

        switch group.theme ?? "" {
        case "city":
            backgroundImageName = "box-paris"
        case "desert":
            backgroundImageName = "box-paris"
            
            
        case "paris":
            backgroundImageName = "box-paris"
            
            
        default:
            backgroundImageName = "box-paris" // default theme
        }

        return ZStack(alignment: .topLeading) {
            Color(boxBackgroundColor) // Background color of the box
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
            
            // Overlay the logo at the bottom-left corner using GeometryReader
            GeometryReader { geometry in
                Image("logo-wolls") // Your logo image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30) // Adjust size as needed
                    .position(x: geometry.size.width * 0.1, y: geometry.size.height * 0.9) // Adjust position
            }
            .clipped()
            .padding(.bottom, 8)
            .padding(.leading, -8)
        }
        .frame(height: 150)
    }
    
    private var boxBackgroundColor: Color {
        colorScheme == .dark ? Color(red: 0/255, green: 24/255, blue: 49/255) : Color(red: 206/255, green: 228/255, blue: 250/255)
    }
}
