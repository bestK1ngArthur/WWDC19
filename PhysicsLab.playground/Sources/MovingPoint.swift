import UIKit

protocol MovingPointDelegate: AnyObject {
    func tappedIn(point: MovingPoint)
    func tappedOut(point: MovingPoint)
    func panned(point: MovingPoint)
}

class MovingPoint: UIView {
    
    enum Size {
        case small
        case custom(CGFloat)
    }
    
    enum State {
        case normal
        case increased
    }
    
    weak var delegate: MovingPointDelegate?
    
    private let scale: CGFloat = 1.5
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        assertionFailure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(size: Size = .small) {
        super.init(frame: .zero)
        
        backgroundColor = .red
        
        // Gesture
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panChanged(_:)))
        addGestureRecognizer(pan)
        
        // UI
        
        let width = value(from: size)
        
        frame.size = CGSize(width: width, height: width)
        
        layer.masksToBounds = true
        layer.cornerRadius = width / 2
    }
    
    private func value(from size: Size) -> CGFloat {
        
        switch size {
        case .small:
            return 20
        case .custom(let value):
            return value
        }
    }
    
    var lastPosition: CGPoint?
    @objc private func panChanged(_ gesture: UIPanGestureRecognizer) {
        
        switch gesture.state {
        case .began:
            lastPosition = center
            changeState(.increased)
            delegate?.tappedIn(point: self)
            
        case .changed:
    
            guard let lastPosition = lastPosition else {
                return
            }
            
            let translation = gesture.translation(in: superview)
            center = CGPoint(x: lastPosition.x + translation.x, y: lastPosition.y + translation.y)
            
            delegate?.panned(point: self)
            
        case .ended, .cancelled:
            changeState(.normal)
            delegate?.tappedOut(point: self)
            
        default:
            break
        }
    }
    
    private func changeState(_ state: State) {
     
        var newTransform = CGAffineTransform.identity
        
        if state == .increased {
            newTransform = transform.scaledBy(x: scale, y: scale)
        }

        UIView.animate(withDuration: 0.3) {
            self.transform = newTransform
        }
    }
}
