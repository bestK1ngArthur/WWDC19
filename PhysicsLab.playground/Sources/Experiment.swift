import UIKit

public protocol ExperimentObserver: AnyObject {
    func experimentStarted(_ experiment: Experiment)
    func experimentStopped(_ experiment: Experiment)
    func experimentChanged(_ experiment: Experiment)
}

public protocol Experiment {
    var view: UIView { get }
    
    var observer: ExperimentObserver? { get set }
    
    var time: TimeInterval { get }
    var timeInterval: TimeInterval { get set }
    
    var name: String { get }
    
    func prepare(frame: CGRect)
    
    func start()
    func stop()
    
    func hideControls()
    func showControls()
    
    func clear()
}

