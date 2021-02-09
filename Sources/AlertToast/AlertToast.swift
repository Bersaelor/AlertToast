import SwiftUI

@available(iOS 13, *)
fileprivate struct AnimatedCheckmark: View {
    
    var color: Color = .black
    
    var size: Int
    
    var height: CGFloat {
        return CGFloat(size)
    }
    
    var width: CGFloat {
        return CGFloat(size)
    }
    
    @State private var percentage: CGFloat = .zero
    
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: height / 2))
            path.addLine(to: CGPoint(x: width / 2.5, y: height))
            path.addLine(to: CGPoint(x: width, y: 0))
        }
        .trim(from: 0, to: percentage)
        .stroke(color, style: StrokeStyle(lineWidth: CGFloat(size / 8), lineCap: .round, lineJoin: .round))
        .animation(Animation.spring().speed(0.75).delay(0.25))
        .onAppear {
            percentage = 1.0
        }
        .frame(width: width, height: height, alignment: .center)
    }
}

@available(iOS 13, *)
fileprivate struct AnimatedXmark: View {
    
    var color: Color = .black
    
    var size: Int
    
    var height: CGFloat {
        return CGFloat(size)
    }
    
    var width: CGFloat {
        return CGFloat(size)
    }
    
    var rect: CGRect{
        return CGRect(x: 0, y: 0, width: size, height: size)
    }
    
    @State private var percentage: CGFloat = .zero
    
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxY, y: rect.maxY))
            path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        }
        .trim(from: 0, to: percentage)
        .stroke(color, style: StrokeStyle(lineWidth: CGFloat(size / 8), lineCap: .round, lineJoin: .round))
        .animation(Animation.spring().speed(0.75).delay(0.25))
        .onAppear {
            percentage = 1.0
        }
        .frame(width: width, height: height, alignment: .center)
    }
}

@available(iOS 13, *)
struct AlertToast: View{
    
    @Environment(\.colorScheme) private var colorScheme
    
    enum AlertType: Equatable{
        case complete(Color)
        case error(Color)
        case systemImage(String, Color)
        case image(String)
        case none
    }
    
    var type: AlertType
    var title: String
    var subTitle: String?
    
    init(type: AlertType, title: String, subTitle: String? = nil){
        self.type = type
        self.title = title
        self.subTitle = subTitle
    }
    
    var body: some View{
        VStack{
            
            switch type{
            case .complete(let color):
                Spacer()
                AnimatedCheckmark(color: color, size: 50)
                Spacer()
            case .error(let color):
                Spacer()
                AnimatedXmark(color: color, size: 50)
                Spacer()
            case .systemImage(let name, let color):
                Spacer()
                Image(systemName: name)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaledToFit()
                    .foregroundColor(color)
                    .padding(.bottom)
                Spacer()
            case .image(let name):
                Spacer()
                Image(name)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaledToFit()
                    .padding(.bottom)
                Spacer()
            case .none:
                EmptyView()
            }
            
            VStack(spacing: type == .none ? 8 : 2){
                Text(title)
                    .bold()
                if subTitle != nil{
                    Text(subTitle!)
                        .font(.footnote)
                        .opacity(0.7)
                }
            }
        }
        .padding()
        .withFrame(type != .none)
        .background(BlurView(style: .systemMaterial))
        .cornerRadius(10)
    }
}

@available(iOS 13, *)
fileprivate struct AlertToastModifier: ViewModifier{
    
    @Binding var show: Bool
    var alert: () -> AlertToast
    
    @ViewBuilder
    func body(content: Content) -> some View {
        content
            .overlay(
                ZStack{
                    if show{
                        alert()
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation(.spring()){
                                        show = false
                                    }
                                }
                            }
                            .onTapGesture {
                                withAnimation(.spring()){
                                    show = false
                                }
                            }
                            .transition(AnyTransition.scale(scale: 0.8).combined(with: .opacity))
                    }
                }
                .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height, alignment: .center)
                .edgesIgnoringSafeArea(.all)
                .animation(.spring())
            )
        
    }
}

@available(iOS 13, *)
fileprivate struct WithFrameModifier: ViewModifier{
    
    var withFrame: Bool
    
    var maxWidth: CGFloat = 150
    var maxHeight: CGFloat = 150
    
    @ViewBuilder
    func body(content: Content) -> some View {
        if withFrame{
            content
                .frame(maxWidth: maxWidth, maxHeight: maxHeight, alignment: .center)
        }else{
            content
        }
    }
}

@available(iOS 13, *)
extension View{
    
    func withFrame(_ widthFrame: Bool) -> some View{
        modifier(WithFrameModifier(withFrame: widthFrame))
    }
    
    func alertDialog(show: Binding<Bool>, alert: @escaping () -> AlertToast) -> some View{
        modifier(AlertToastModifier(show: show, alert: alert))
    }
}

@available(iOS 13, *)
struct BlurView: UIViewRepresentable {
    typealias UIViewType = UIVisualEffectView
    
    let style: UIBlurEffect.Style
    
    init(style: UIBlurEffect.Style = .systemMaterial) {
        self.style = style
    }
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: self.style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: self.style)
    }
}