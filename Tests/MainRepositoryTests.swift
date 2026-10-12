@testable import MultithreadingiOSCase
import XCTest

final class MainRepositoryTests: XCTestCase {
    func test_mainRepository_in_concurrence_way() {
        let repository = MainRepository()

        DispatchQueue.concurrentPerform(iterations: 100_000) { _ in
            repository.currentAmount += 1
        }

        XCTAssertEqual(repository.currentAmount, 100_000)
    }
}
