import SwiftUI

struct CustomLoader: View {
    @State private var isAnimating: Bool = false
    
    var body: some View {
        Circle()
            .trim(from: 0.0, to: 0.7)
            .stroke(Color.blue, lineWidth: 5)
            .frame(width: 50, height: 50)
            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            .onAppear {
                withAnimation(Animation.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}
