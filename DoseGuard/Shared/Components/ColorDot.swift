import SwiftUI

struct ColorDot: View {
    let colorHex: String
    var size: CGFloat = 12
    
    var body: some View {
        Circle()
            .fill(Color(hex: colorHex))
            .frame(width: size, height: size)
    }
}
