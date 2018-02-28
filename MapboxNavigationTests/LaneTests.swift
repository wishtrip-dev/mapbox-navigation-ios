import XCTest
import FBSnapshotTestCase
import MapboxDirections
@testable import MapboxNavigation
@testable import MapboxCoreNavigation

let bogusToken = "pk.feedCafeDeadBeefBadeBede"
let directions = Directions(accessToken: bogusToken)


class LaneTests: FBSnapshotTestCase {

    let route = Fixture.route(from: "route-for-lane-testing", waypoints: [Waypoint(coordinate: CLLocationCoordinate2D(latitude: 37.795042, longitude: -122.413165)), Waypoint(coordinate: CLLocationCoordinate2D(latitude: 37.7727, longitude: -122.433378))])
    
    var steps: [RouteStep]!
    var routeProgress: RouteProgress!
    
    override func setUp() {
        super.setUp()
        let routeController = RouteController(along: route, directions: directions)
        steps = routeController.routeProgress.currentLeg.steps
        routeProgress = routeController.routeProgress
        
        route.accessToken = bogusToken
        recordMode = false
        isDeviceAgnostic = true
    }
    
    func assertLanes(step: RouteStep) {
        let rect = CGRect(origin: .zero, size: .iPhone6Plus)
        let navigationView = NavigationView(frame: rect)
        
        navigationView.lanesView.update(for: routeProgress.currentLegProgress)
        navigationView.lanesView.show(animated: false)
        
        FBSnapshotVerifyView(navigationView.lanesView)
    }
    
    func testRightRight() {
        assertLanes(step: steps[0])
    }
    
    func testRightNone() {
        assertLanes(step: steps[1])
    }
}
