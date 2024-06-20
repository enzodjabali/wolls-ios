import SwiftUI

struct GroupBoxView: View {
    let group: Group
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        //let backgroundImageName: String

        //switch group.theme ?? "" {
        //case "desert":
        //    backgroundImageName = "group-theme-tokyo"
        //default:
        //    backgroundImageName = "group-theme-madrid" // default theme
        //}

        return ZStack(alignment: .topLeading) {
            Color(boxBackgroundColor) // Background color of the box
                .cornerRadius(10)
            
            
            
            // Overlay the logo at the bottom-left corner using GeometryReader
            GeometryReader { geometry in
                Image("logo-wolls") // Your logo image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30) // Adjust size as needed
                    .position(x: geometry.size.width - 310, y: geometry.size.height - 25) // Adjusted position
            }
            .clipped()

            // Overlay the logo at the bottom-right corner using GeometryReader
            GeometryReader { geometry in
                Image("biking") // Your background image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 180, height: 180) // Increased size
                    .position(x: geometry.size.width - 90, y: geometry.size.height - 68) // Adjusted position
            }
            .clipped()

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

    private var boxBackgroundColor: Color {
        colorScheme == .dark ? Color(red: 0/255, green: 24/255, blue: 49/255) : Color(red: 206/255, green: 228/255, blue: 250/255)
    }
}
