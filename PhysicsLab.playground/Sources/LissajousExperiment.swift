import UIKit

public class LissajousExperiment: Experiment {
    public weak var observer: ExperimentObserver?

    // MARK: Physique
    
    /// Time between redrawings (sec)
    public var timeInterval: TimeInterval = 0.005
    
    /// Current simulation time (sec)
    public private(set) var time: TimeInterval = 0
    
    /// Mass of the fixed object (kg)
    public var mass: Double = 10

    /// Environmental viscosity
    public var viscosity: Double = 0.5
    
    /// Stiffness coefficient of the top spring
    public var topSpringStiffness: Double = 1
    
    /// Stiffness coefficient of the bottom spring
    public var bottomSpringStiffness: Double = 1

    /// Stiffness coefficient of the left spring
    public var leftSpringStiffness: Double = 3
    
    /// Stiffness coefficient of the right spring
    public var rightSpringStiffness: Double = 3
    
    // MARK: Drawing
    
    /// Drawing line width
    public var drawingLineWidth: CGFloat = 2
    
    /// Drawing line color
    public var drawingLineColor: UIColor = .red

    // MARK: Springs
    
    /// Springs line width
    public var springsLineWidth: CGFloat = 2
    
    /// Springs line color
    public var springsLineColor: UIColor = .red

    /// Springs width
    public var springsWidth: CGFloat = 25

    /// Springs opacity
    public var springsOpacity: CGFloat = 1
    
    // MARK: Views

    public var view: UIView {
        return experimentView
    }
    
    private var experimentView: UIView!
    private var massPoint: MovingPoint!
    
    private var topSpring: Spring!
    private var bottomSpring: Spring!
    private var leftSpring: Spring!
    private var rightSpring: Spring!
   
    public init() {}
    
    public func prepare(frame: CGRect) {
        experimentView = UIView(frame: frame)
        experimentView.backgroundColor = .white
        
        topSpring = Spring(half: .bottom)
        experimentView.addSubview(topSpring)
        topSpring.backgroundColor = .clear
        topSpring.lineColor = springsLineColor
        topSpring.lineWidth = springsLineWidth
        topSpring.alpha = springsOpacity
        
        bottomSpring = Spring(half: .top)
        experimentView.addSubview(bottomSpring)
        bottomSpring.backgroundColor = .clear
        bottomSpring.lineColor = springsLineColor
        bottomSpring.lineWidth = springsLineWidth
        bottomSpring.alpha = springsOpacity

        leftSpring = Spring(half: .top)
        experimentView.addSubview(leftSpring)
        leftSpring.backgroundColor = .clear
        leftSpring.lineColor = springsLineColor
        leftSpring.lineWidth = springsLineWidth
        leftSpring.alpha = springsOpacity

        rightSpring = Spring(half: .bottom)
        experimentView.addSubview(rightSpring)
        rightSpring.backgroundColor = .clear
        rightSpring.lineColor = springsLineColor
        rightSpring.lineWidth = springsLineWidth
        rightSpring.alpha = springsOpacity

        updateSprings(size: CGSize(width: springsWidth,
                                   height: view.frame.height / 2))
        
        massPoint = MovingPoint(size: .small)
        massPoint.delegate = self
        experimentView.addSubview(massPoint)
        massPoint.backgroundColor = springsLineColor
        massPoint.center = view.center
    }
    
    private func updateTopSpring(size: CGSize, angle: CGFloat = 0) {
        topSpring.frame = CGRect(x: (view.frame.width - size.width) / 2, y: -size.height, width: size.width, height: size.height * 2)
        topSpring.transform = topSpring.transform.rotated(by: angle)
    }
    
    private func updateBottomSpring(size: CGSize, angle: CGFloat = 0) {
        bottomSpring.frame = CGRect(x: (view.frame.width - size.width) / 2, y: view.frame.height - size.height, width: size.width, height: 2 * size.height)
        bottomSpring.transform = bottomSpring.transform.rotated(by: angle)
    }
    
    private func updateLeftSpring(size: CGSize, angle: CGFloat = 0) {
        leftSpring.frame = CGRect(x: -size.height, y: (view.frame.height - size.width) / 2, width: 2 * size.height, height: size.width)
        leftSpring.transform = leftSpring.transform.rotated(by: angle)
    }
    
    private func updateRightSpring(size: CGSize, angle: CGFloat = 0) {
        rightSpring.frame = CGRect(x: view.frame.width - size.height, y: (view.frame.height - size.width) / 2, width: 2 * size.height, height: size.width)
        rightSpring.transform = rightSpring.transform.rotated(by: angle)
    }
    
    private func updateSprings(size: CGSize) {
        updateTopSpring(size: size)
        updateBottomSpring(size: size)
        updateLeftSpring(size: size)
        updateRightSpring(size: size)
    }
    
    // MARK: Experiment
    
    public var name: String {
        return "Lissajous Figures"
    }
    
    private var experimentTimer: Timer?

    public func start() {
        massPoint.isUserInteractionEnabled = false
        
        x = Double(massPoint.center.x - view.center.x)
        y = Double(massPoint.center.y - view.center.y)
    
        experimentTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { timer in
            self.time += self.timeInterval

            DispatchQueue.main.async {
                self.updateSimulation(time: self.timeInterval)
            }
            
            self.observer?.experimentChanged(self)
        }
        
        observer?.experimentStarted(self)
    }
    
    public func stop() {
        experimentTimer?.invalidate()
        massPoint.isUserInteractionEnabled = true
        
        observer?.experimentStopped(self)
    }
    
    public func hideControls() {
        topSpring.isHidden = true
        bottomSpring.isHidden = true
        leftSpring.isHidden = true
        rightSpring.isHidden = true
        massPoint.isHidden = true
    }
    
    public func showControls() {
        topSpring.isHidden = false
        bottomSpring.isHidden = false
        leftSpring.isHidden = false
        rightSpring.isHidden = false
        massPoint.isHidden = false
    }

    public func clear() {

        view.layer.sublayers?.forEach({ layer in
            if layer is CAShapeLayer {
                layer.removeFromSuperlayer()
            }
        })
//        let path = UIBezierPath(rect: view.bounds)
//
//        let shapeLayer = CAShapeLayer()
//        shapeLayer.path = path.cgPath
//
//        shapeLayer.fillColor = UIColor.white.cgColor
//
//        view.layer.addSublayer(shapeLayer)

        massPoint.center = view.center
        updateSpringsDeformation()
        
        time = 0
        
        observer?.experimentChanged(self)
    }
    
    // MARK: Simulation

    private var ux: Double = 0
    private var uy: Double = 0

    private var x: Double = 0
    private var y: Double = 0
    
    private func updateSimulation(time: Double) {
        
        // Get new coordinates
        
        let centerX = Double(view.center.x)
        let centerY = Double(view.center.y)

        let minX: Double = 0
        let minY: Double = 0
        let maxX = Double(view.bounds.width)
        let maxY = Double(view.bounds.height)
        
        let currentX: Double = Double(massPoint.center.x)
        let currentY: Double = Double(massPoint.center.y)

        let f1 = calculateForce(k: topSpringStiffness,
                                x0: centerX,
                                y0: minY,
                                x: currentX,
                                y: currentY)

        let f2 = calculateForce(k: bottomSpringStiffness,
                                x0: centerX,
                                y0: maxY,
                                x: currentX,
                                y: currentY)

        let f3 = calculateForce(k: leftSpringStiffness,
                                x0: minX,
                                y0: centerY,
                                x: currentX,
                                y: currentY)

        let f4 = calculateForce(k: rightSpringStiffness,
                                x0: maxX,
                                y0: centerY,
                                x: currentX,
                                y: currentY)

        let fx = f1.x + f2.x + f3.x + f4.x - viscosity * ux
        let fy = f1.y + f2.y + f3.y + f4.y - viscosity * uy

        ux += fx / mass * time
        uy += fy / mass * time

        x += ux * time
        y += uy * time
        
        // Update UI

        drawCircle(center: massPoint.center, radius: drawingLineWidth / 2)
        massPoint.center = CGPoint(x: CGFloat(x) + view.center.x,
                                   y: CGFloat(y) + view.center.y)
        
        // Spring deformation
        
        let l1 = centerX - currentX
        let l2 = centerY - currentY
        
        let L1 = calculateSringLength(x0: centerX,
                                      y0: minY,
                                      x: currentX,
                                      y: currentY)
        let L4 = calculateSringLength(x0: centerX,
                                      y0: maxY,
                                      x: currentX,
                                      y: currentY)
        let L2 = calculateSringLength(x0: minX,
                                      y0: centerY,
                                      x: currentX,
                                      y: currentY)
        let L3 = calculateSringLength(x0: maxX,
                                      y0: centerY,
                                      x: currentX,
                                      y: currentY)
        
        let alpha = asin(l1/L1)
        let scale1 = 2 * CGFloat(L1) / (view.bounds.height)
        topSpring.transform = CGAffineTransform.identity.rotated(by: CGFloat(alpha)).scaledBy(x: 1, y: scale1)

        let beta = -asin(l2/L2)
        let scale2 = 2 * CGFloat(L2) / (view.bounds.width)
        leftSpring.transform = CGAffineTransform.identity.rotated(by: CGFloat(beta)).scaledBy(x: scale2, y: 1)

        let gamma = asin(l2/L3)
        let scale3 = 2 * CGFloat(L3) / (view.bounds.width)
        rightSpring.transform = CGAffineTransform.identity.rotated(by: CGFloat(gamma)).scaledBy(x: scale3, y: 1  )

        let delta = -asin(l1/L4)
        let scale4 = 2 * CGFloat(L4) / (view.bounds.height)
        bottomSpring.transform = CGAffineTransform.identity.rotated(by: CGFloat(delta)).scaledBy(x: 1, y: scale4)
    }
    
    private func updateSpringsDeformation() {
        
        let centerX = Double(view.center.x)
        let centerY = Double(view.center.y)
        
        let minX: Double = 0
        let minY: Double = 0
        let maxX = Double(view.bounds.width)
        let maxY = Double(view.bounds.height)
        
        let currentX: Double = Double(massPoint.center.x)
        let currentY: Double = Double(massPoint.center.y)

        let l1 = centerX - currentX
        let l2 = centerY - currentY
        
        let L1 = calculateSringLength(x0: centerX,
                                      y0: minY,
                                      x: currentX,
                                      y: currentY)
        let L4 = calculateSringLength(x0: centerX,
                                      y0: maxY,
                                      x: currentX,
                                      y: currentY)
        let L2 = calculateSringLength(x0: minX,
                                      y0: centerY,
                                      x: currentX,
                                      y: currentY)
        let L3 = calculateSringLength(x0: maxX,
                                      y0: centerY,
                                      x: currentX,
                                      y: currentY)
        
        let alpha = asin(l1/L1)
        let scale1 = 2 * CGFloat(L1) / (view.bounds.height)
        topSpring.transform = CGAffineTransform.identity.rotated(by: CGFloat(alpha)).scaledBy(x: 1, y: scale1)
        
        let beta = -asin(l2/L2)
        let scale2 = 2 * CGFloat(L2) / (view.bounds.width)
        leftSpring.transform = CGAffineTransform.identity.rotated(by: CGFloat(beta)).scaledBy(x: scale2, y: 1)
        
        let gamma = asin(l2/L3)
        let scale3 = 2 * CGFloat(L3) / (view.bounds.width)
        rightSpring.transform = CGAffineTransform.identity.rotated(by: CGFloat(gamma)).scaledBy(x: scale3, y: 1  )
        
        let delta = -asin(l1/L4)
        let scale4 = 2 * CGFloat(L4) / (view.bounds.height)
        bottomSpring.transform = CGAffineTransform.identity.rotated(by: CGFloat(delta)).scaledBy(x: 1, y: scale4)
    }
    
    private func drawCircle(center: CGPoint, radius: CGFloat) {
        
        let circlePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        shapeLayer.fillColor = drawingLineColor.cgColor
        
        view.layer.addSublayer(shapeLayer)
    }
    
    // MARK: Calculations
    
    private var rx0: Double {
        return Double(view.center.x)
    }
    
    private var ry0: Double {
        return Double(view.center.y)
    }
    
    private func calculateForce(k: Double, x0: Double, y0: Double, x: Double, y: Double) -> (x: Double, y: Double) {
        
        let r = sqrt(pow(x - x0, 2) + pow(y - y0, 2))
        
        let dx = (1 - rx0/r) * (x0 - x)
        let dy = (1 - ry0/r) * (y0 - y)
        
        return (dx*k, dy*k)
    }
    
    private func calculateSringLength(x0: Double, y0: Double, x: Double, y: Double) -> Double {
        return sqrt(pow(x - x0, 2) + pow(y - y0, 2))
    }
}

extension LissajousExperiment: MovingPointDelegate {
    
    func tappedIn(point: MovingPoint) {
        // ..
    }
    
    func tappedOut(point: MovingPoint) {
        point.isUserInteractionEnabled = false
        start()
    }
    
    func panned(point: MovingPoint) {
        updateSpringsDeformation()
    }
}
