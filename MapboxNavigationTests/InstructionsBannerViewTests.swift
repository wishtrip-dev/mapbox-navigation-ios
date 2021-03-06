import XCTest
import FBSnapshotTestCase
import MapboxDirections
import SDWebImage
@testable import MapboxNavigation
@testable import MapboxCoreNavigation

extension CGSize {
    static let iPhone5      : CGSize    = CGSize(width: 320, height: 568)
    static let iPhone6Plus  : CGSize    = CGSize(width: 414, height: 736)
    static let iPhoneX      : CGSize    = CGSize(width: 375, height: 812)
}

class InstructionsBannerViewTests: FBSnapshotTestCase {
    
    let bannerHeight: CGFloat = 96
    
    let shieldURL = URL(string: "https://s3.amazonaws.com/mapbox/shields/v3/i-280@3x.png")!
    
    var shieldImage: UIImage {
        get {
            let bundle = Bundle(for: MapboxNavigationTests.self)
            return UIImage(named: "i-280", in: bundle, compatibleWith: nil)!
        }
    }
    
    override func setUp() {
        super.setUp()
        recordMode = false
        
        let instruction = VisualInstructionComponent(text: nil, imageURL: shieldURL)
        let shieldKey = instruction.shieldKey()
        SDImageCache.shared().store(shieldImage, forKey: shieldKey)
    }
    
    func instructionsView() -> InstructionsBannerView {
        return InstructionsBannerView(frame: CGRect(origin: .zero, size: CGSize(width: CGSize.iPhone6Plus.width, height: bannerHeight)))
    }
    
    func testSinglelinePrimary() {
        let view = instructionsView()
        styleInstructionsView(view)
        
        view.maneuverView.isStart = true
        view.distance = 482
        
        let instructions = [
            VisualInstructionComponent(text: "US 45", imageURL: nil),
            VisualInstructionComponent(text: "/", imageURL: nil),
            VisualInstructionComponent(text: "Chicago", imageURL: nil)
        ]
        
        view.set(instructions, secondaryInstruction: nil)
        
        verifyView(view, size: view.bounds.size)
    }
    
    func testMultilinePrimary() {
        let view = instructionsView()
        styleInstructionsView(view)

        view.maneuverView.isStart = true
        view.distance = 482

        let instructions = [
            VisualInstructionComponent(text: "I 280", imageURL: shieldURL),
            VisualInstructionComponent(text: "US 45 / Chicago / US 45 / Chicago", imageURL: nil)
        ]

        view.set(instructions, secondaryInstruction: nil)
    
        verifyView(view, size: view.bounds.size)
    }
    
    func testSinglelinePrimaryAndSecondary() {
        let view = instructionsView()
        styleInstructionsView(view)

        view.maneuverView.isStart = true
        view.distance = 482
        
        let primary = [
            VisualInstructionComponent(text: "I 280", imageURL: shieldURL),
            VisualInstructionComponent(text: "South", imageURL: nil)
        ]
        let secondary = [VisualInstructionComponent(text: "US 45 / Chicago", imageURL: nil)]
        
        view.set(primary, secondaryInstruction: secondary)

        verifyView(view, size: view.bounds.size)
    }
    
    func testPrimaryShieldAndSecondary() {
        let view = instructionsView()
        styleInstructionsView(view)

        view.maneuverView.isStart = true
        view.distance = 482
        
        let primary = [
            VisualInstructionComponent(text: "I 280", imageURL: shieldURL)
        ]
        let secondary = [VisualInstructionComponent(text: "Mountain View Test", imageURL: nil)]

        view.set(primary, secondaryInstruction: secondary)
        
        verifyView(view, size: view.bounds.size)
    }
    
    func testInstructionsAndNextInstructions() {
        let view = UIView()
        view.backgroundColor = .white
        let instructionsBannerView = instructionsView()
        let nextBannerViewFrame = CGRect(x: 0, y: instructionsBannerView.frame.maxY, width: instructionsBannerView.bounds.width, height: 44)
        let nextBannerView = NextBannerView(frame: nextBannerViewFrame)
        nextBannerView.translatesAutoresizingMaskIntoConstraints = true
        view.addSubview(instructionsBannerView)
        view.addSubview(nextBannerView)
        view.frame = CGRect(origin: .zero, size: CGSize(width: nextBannerViewFrame.width, height: nextBannerViewFrame.maxY))

        instructionsBannerView.maneuverView.isStart = true
        instructionsBannerView.distance = 482
        
        let primary = [
            VisualInstructionComponent(text: "I 280", imageURL: shieldURL)
        ]
        let secondary = [VisualInstructionComponent(text: "US 45 / Chicago", imageURL: nil)]
        
        instructionsBannerView.set(primary, secondaryInstruction: secondary)

        
        let primaryThen = [
            VisualInstructionComponent(text: "I 280", imageURL: shieldURL)
        ]
        
        nextBannerView.instructionLabel.instruction = primaryThen
        nextBannerView.maneuverView.backgroundColor = .clear
        nextBannerView.maneuverView.isEnd = true
        
        verifyView(view, size: view.bounds.size)
    }
}

extension InstructionsBannerViewTests {
    
    func verifyView(_ view: UIView, size: CGSize) {
        view.frame.size = size
        FBSnapshotVerifyView(view)
    }
    
    // UIAppearance proxy do not work in unit test environment so we have to style manually
    func styleInstructionsView(_ view: InstructionsBannerView) {
        view.backgroundColor = .white
        view.maneuverView.backgroundColor = #colorLiteral(red: 0.5882352941, green: 0.5882352941, blue: 0.5882352941, alpha: 0.5)
        view.distanceLabel.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 0.5)
        view.primaryLabel.backgroundColor = #colorLiteral(red: 0.5882352941, green: 0.5882352941, blue: 0.5882352941, alpha: 0.5)
        view.secondaryLabel.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 0.5)
        view.dividerView.backgroundColor = .red
        view._separatorView.backgroundColor = .red
        
        view.distanceLabel.valueFont = UIFont.systemFont(ofSize: 24)
        view.distanceLabel.unitFont = UIFont.systemFont(ofSize: 14)
        view.primaryLabel.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        view.secondaryLabel.font = UIFont.systemFont(ofSize: 26, weight: .medium)
    }
}
