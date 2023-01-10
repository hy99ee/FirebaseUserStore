import SwiftUI

struct ImageView: View {
    typealias ActionHandler = () -> Void

    let image: Image
    let size: CGFloat
    let background: Color
    let foreground: Color
    let border: Color
    let handler: ActionHandler
    
    private let cornerRadius: CGFloat = 10
    
    internal init(systemName: String,
                  size: CGFloat = 30,
                  background: Color = Color(UIColor.systemBackground),
                  foreground: Color = .blue,
                  border: Color = .clear,
                  handler: @escaping ButtonView.ActionHandler) {
        self.image = Image(systemName: systemName)
        self.size = size
        self.background = background
        self.foreground = foreground
        self.border = border
        self.handler = handler
    }
    
    var body: some View {
        
        Button(action: {
            handler()
        }, label: {
            image
        })
        .font(.system(size: size))
        .background(background)
        .foregroundColor(foreground)
        .overlay(
            RoundedRectangle(cornerRadius: 0)
                .stroke(border, lineWidth: 2)
        )
        
    }
}
