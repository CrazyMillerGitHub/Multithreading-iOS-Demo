import Foundation

final class NetworkingService {
    static let shared = NetworkingService()

    private init() {}

    func makeCashFlow(completionHandler: @escaping (Decimal) -> Void) {
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now()) {
            completionHandler(Decimal((0 ..< 100).randomElement()!))
        }
    }
}
