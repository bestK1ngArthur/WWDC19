import UIKit

class Button: UIButton {
    
    enum ImageType: String {
        case play
        case stop
        case close
        case camera
        case clear
    }
    
    private(set) var imageType: ImageType = .play
    
    private let buttonHeight: CGFloat = 40
    private let buttonInset: CGFloat = 8
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        assertionFailure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(imageType: ImageType, color: UIColor) {
        super.init(frame: .zero)
        
        backgroundColor = color
        
        frame.size = CGSize(width: buttonHeight, height: buttonHeight)
        
        layer.masksToBounds = true
        layer.cornerRadius = frame.width / 2
        
        if let image = UIImage(named: "\(imageType.rawValue).png")?.withRenderingMode(.alwaysTemplate) {
            setImage(image, for: .normal)
            imageView?.tintColor = .white
            self.imageType = imageType
        }

        contentEdgeInsets = .init(top: buttonInset, left: buttonInset, bottom: buttonInset, right: buttonInset)
    }
    
    func changeType(_ newImageType: ImageType) {
        
        if let image = UIImage(named: "\(newImageType.rawValue).png")?.withRenderingMode(.alwaysTemplate) {
            setImage(image, for: .normal)
            tintColor = .white
            self.imageType = newImageType
        }
    }
}

