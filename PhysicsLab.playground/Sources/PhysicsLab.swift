import UIKit
import PlaygroundSupport

public class PhysicsLab {
    
    public var experiment: Experiment? {
        didSet {
            nameLabel.text = experiment?.name
            experiment?.prepare(frame: liveView.frame)
        }
    }

    public var liveView: UIView!

    private let themeColor: UIColor
    
    private var experimentView: UIView!
    private var nameLabel: Label!
    
    private var closeButton: Button?
    private var playButton: Button?
    private var screenshotButton: Button?
    private var clearButton: Button?
    private var timeLabel: Label?

    private let liveViewHeight: CGFloat = 500
    private let buttonInset: CGFloat = 20
    
    public init(themeColor: UIColor = .blue) {
        self.themeColor = themeColor
        addStartScreen()
    }
    
    private func addStartScreen() {
        liveView = UIView(frame: CGRect(x: 0, y: 0, width: liveViewHeight, height: liveViewHeight))
        liveView.backgroundColor = .white
        
        let nameLabel = Label()
        liveView.addSubview(nameLabel)
        nameLabel.frame.size = CGSize(width: liveView.bounds.width, height: 50)
        nameLabel.center = CGPoint(x: liveView.center.x, y: 200)
        nameLabel.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        nameLabel.textAlignment = .center
        self.nameLabel = nameLabel
        
        let button = UIButton(type: .system)
        button.setTitle("Start", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        button.backgroundColor = themeColor
        button.tintColor = .white
        button.frame.size = CGSize(width: 100, height: 40)
        button.center = CGPoint(x: liveView.center.x, y: liveView.center.y + 100)
        button.layer.cornerRadius = button.bounds.height / 2
        button.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        
        liveView.addSubview(button)
    }
    
    private func openExperiment(_ experiment: Experiment) {
        
        // Add experiment view
        experimentView = experiment.view
        experimentView.alpha = 0
        liveView.addSubview(experimentView)
        
        // Add close button
        let closeButton = Button(imageType: .close, color: themeColor)
        liveView.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.center = CGPoint(x: experimentView.bounds.width - buttonInset - closeButton.frame.width / 2, y: buttonInset + closeButton.frame.height / 2)
        self.closeButton = closeButton
        
        // Add play button
        let playButton = Button(imageType: .play, color: themeColor)
        liveView.addSubview(playButton)
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        playButton.center = CGPoint(x: experimentView.bounds.width - buttonInset - playButton.frame.width / 2, y: experimentView.bounds.width - buttonInset - playButton.frame.height / 2)
        self.playButton = playButton
        
        // Add screenshot button
        let screenshotButton = Button(imageType: .camera, color: themeColor)
        liveView.addSubview(screenshotButton)
        screenshotButton.addTarget(self, action: #selector(screenshotTapped), for: .touchUpInside)
        screenshotButton.center = CGPoint(x: experimentView.bounds.width - buttonInset - playButton.frame.width - buttonInset - playButton.frame.width / 2, y: experimentView.bounds.width - buttonInset - screenshotButton.frame.height / 2)
        self.screenshotButton = screenshotButton
        
        // Add clear button
        let clearButton = Button(imageType: .clear, color: themeColor)
        liveView.addSubview(clearButton)
        clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        clearButton.center = CGPoint(x: experimentView.bounds.width - buttonInset - playButton.frame.width / 2, y: experimentView.bounds.width - buttonInset - playButton.frame.height - buttonInset - clearButton.frame.height / 2)
        self.clearButton = clearButton
        
        // Add time label
        let timeLabel = Label(frame: .zero)
        liveView.addSubview(timeLabel)
        timeLabel.frame.size = CGSize(width: 70, height: 30)
        timeLabel.textColor = .white
        timeLabel.textAlignment = .center
        timeLabel.backgroundColor = themeColor
        timeLabel.clipsToBounds = true
        timeLabel.layer.cornerRadius = timeLabel.bounds.height / 2
        timeLabel.center = CGPoint(x: buttonInset + timeLabel.frame.width / 2, y: experimentView.bounds.height - buttonInset - timeLabel.frame.height / 2)
        timeLabel.isHidden = true
        self.timeLabel = timeLabel
        
        // Open experiment view
        UIView.animate(withDuration: 0.3) {
            self.experimentView.alpha = 1
        }
    }
    
    private func closeExperiment() {
        experiment?.stop()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.experimentView.alpha = 0
            self.screenshotButton?.alpha = 0
            self.playButton?.alpha = 0
            self.clearButton?.alpha = 0
            self.closeButton?.alpha = 0
            self.timeLabel?.alpha = 0
        }) { _ in
            self.experimentView = nil
            self.screenshotButton?.removeFromSuperview()
            self.playButton?.removeFromSuperview()
            self.clearButton?.removeFromSuperview()
            self.closeButton?.removeFromSuperview()
            self.timeLabel?.removeFromSuperview()
        }
    }
    
    private func createScreenshot() -> UIImage {
        hideControls()
        
        let rect = experimentView.bounds
        
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        experimentView.layer.render(in: context!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        showControls()
        
        return image!
    }
    
    private func saveScreenshot(_ image: UIImage) {
        
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "HH:mm:ss"
        
        let dateString = dateFormater.string(from: Date())
        let screenshotName = "ScreenShot(\(dateString)).jpeg"
        
        let screenshotPath = playgroundSharedDataDirectory.appendingPathComponent(screenshotName)
        
        let data = image.jpegData(compressionQuality: 1)
        
        do {
            try data?.write(to: screenshotPath)
            print("ScreenShot saved to \"~/Documents/Shared Playground Data\"")
        } catch {
            print("Attention! Need to create a directory \"~/Documents/Shared Playground Data\" to save screenshots")
        }
    }
    
    private func hideControls() {
        experiment?.hideControls()
        closeButton?.isHidden = true
        playButton?.isHidden = true
        screenshotButton?.isHidden = true
        timeLabel?.isHidden = true
    }
    
    private func showControls() {
        experiment?.showControls()
        closeButton?.isHidden = false
        playButton?.isHidden = false
        screenshotButton?.isHidden = false
        timeLabel?.isHidden = false
    }
    
    // MARK: Actions
    
    @objc private func startTapped() {
        guard let experiment = experiment else {
            return
        }
        
        self.experiment?.observer = self
        openExperiment(experiment)
    }
    
    @objc private func closeTapped() {
        closeExperiment()
    }
    
    @objc private func playTapped() {
        guard let type = playButton?.imageType else {
            return
        }
        
        if type == .play {
            experiment?.start()
            playButton?.changeType(.stop)
        } else {
            experiment?.stop()
            playButton?.changeType(.play)
        }
    }
    
    @objc private func screenshotTapped() {
        let image = createScreenshot()
        saveScreenshot(image)
    }
    
    @objc private func clearTapped() {
        experiment?.clear()
    }
}

extension PhysicsLab: ExperimentObserver {
    
    public func experimentStarted(_ experiment: Experiment) {
        timeLabel?.isHidden = false
        playButton?.changeType(.stop)
    }
    
    public func experimentStopped(_ experiment: Experiment) {
        playButton?.changeType(.play)
    }
    
    public func experimentChanged(_ experiment: Experiment) {
        timeLabel?.text = "\(NSString(format:"%.2f", experiment.time))"
    }
}
