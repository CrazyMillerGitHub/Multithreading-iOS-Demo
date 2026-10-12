import Foundation
import Observation

@Observable
final class MainViewModel {
    private let repository = MainRepository()

    /// Текущий баланс. Пишется и из main (трата), и из background-колбэка сети —
    /// синхронизации НЕТ, это учебный race condition (см. README).
    private(set) var balance: Decimal = 0

    /// Флаг активности денежного потока. Читается и пишется из разных потоков
    /// без синхронизации — окно гонки при быстром off→on сохранено намеренно.
    private(set) var isCashFlowActive = false

    func toggleCashFlow() {
        isCashFlowActive.toggle()

        if isCashFlowActive {
            performCashFlow()
        }
    }

    func spendMoney() {
        repository.currentAmount -= 100
        balance = repository.currentAmount
    }

    private func performCashFlow() {
        NetworkingService.shared.makeCashFlow { [weak self] extra in
            guard let self else { return }
            // Запись из background-очереди сети. Хоп на main НЕ добавлен:
            // обновление UI из фона — часть учебного кейса (см. README).
            repository.currentAmount += extra
            balance = repository.currentAmount

            if isCashFlowActive {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                    self?.performCashFlow()
                }
            }
        }
    }
}
