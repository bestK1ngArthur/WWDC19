import UIKit

class Spring: UIView {
    
    enum Half {
        case top
        case bottom
    }
    
    /// Length of base
    var baseLength: CGFloat = 10
    
    /// Units count
    var unitsCount: Int = 20
    
    /// Length of unit
    var unitLength: CGFloat = 20
    
    /// Line width
    var lineWidth: CGFloat = 6
    
    /// Line color
    var lineColor: UIColor = .red

    private let half: Half
    
    required init?(coder aDecoder: NSCoder) {
        self.half = .top
        super.init(coder: aDecoder)
        assertionFailure()
    }
    
    override init(frame: CGRect) {
        self.half = .top
        super.init(frame: frame)
    }
    
    init(half: Half) {
        self.half = half
        super.init(frame: .zero)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if rect.height > rect.width {
            drawVerticalSpring()
        } else {
            drawHorizontalSpring()
        }
    }
    
    func drawVerticalSpring() {
        let path = UIBezierPath()
        
        let centerX = frame.width / 2
        
        var inset: CGFloat = 0
        if half == .bottom {
            inset = bounds.height / 2
        }
        
        path.move(to: CGPoint(x: centerX, y: inset))
        path.addLine(to: CGPoint(x: centerX, y: inset + baseLength))
        
        let unitHeight = (bounds.height / 2 - 2 * baseLength) / CGFloat(unitsCount - 1)
        for unit in 1..<unitsCount-1 {
            
            let x = (unit % 2) == 0 ? bounds.width : 0
            let y = inset + baseLength + CGFloat(unit) * unitHeight
            
            path.addLine(to: CGPoint(x: x, y: y))
        }
        path.addLine(to: CGPoint(x: centerX, y: inset + baseLength + CGFloat(unitsCount - 1) * unitHeight))
        path.addLine(to: CGPoint(x: centerX, y: inset + bounds.height / 2))
        path.move(to: CGPoint(x: centerX, y: inset))

        lineColor.set()
        path.lineWidth = lineWidth
        path.stroke()
    }
    
    func drawHorizontalSpring() {
        let path = UIBezierPath()
    
        var inset: CGFloat = 0
        if half == .top {
            inset = bounds.width / 2
        }
    
        let centerY = frame.height / 2
        
        path.move(to: CGPoint(x: inset, y: centerY))
        path.addLine(to: CGPoint(x: inset + baseLength, y: centerY))
        
        let unitWdith = (bounds.width / 2 - 2 * baseLength) / CGFloat(unitsCount - 1)
        for unit in 1..<unitsCount-1 {
            let x = inset + baseLength + CGFloat(unit) * unitWdith
            let y = (unit % 2) == 0 ? bounds.height : 0
            
            path.addLine(to: CGPoint(x: x, y: y))
        }
        path.addLine(to: CGPoint(x: inset + baseLength + CGFloat(unitsCount - 1) * unitWdith, y: centerY))
        path.addLine(to: CGPoint(x: inset + bounds.width / 2, y: centerY))
        path.move(to: CGPoint(x: inset, y: centerY))
        
        lineColor.set()
        path.lineWidth = lineWidth
        path.stroke()
    }
}
