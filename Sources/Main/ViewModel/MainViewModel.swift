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

    /// Незавершённый тик денежного потока. cancel() гасит только ещё НЕ
    /// запущенный тик; in-flight сетевой колбэк уже выполняется и видит
    /// isCashFlowActive == true — окно гонки при быстром off→on сохранено
    /// намеренно (см. README, раздел «Учебные баги»).
    private var cashFlowWorkItem: DispatchWorkItem?

    func toggleCashFlow() {
        isCashFlowActive.toggle()

        if isCashFlowActive {
            performCashFlow()
        } else {
            cashFlowWorkItem?.cancel()
            cashFlowWorkItem = nil
        }
    }

    func spendMoney() {
        repository.currentAmount -= 100
        balance = repository.currentAmount
    }

    private func performCashFlow() {
        let workItem = DispatchWorkItem { [weak self] in
            self?.performCashFlow()
        }
        cashFlowWorkItem = workItem
        // Запись из background-очереди сети. Хоп на main НЕ добавлен:
        // обновление UI из фона — часть учебного кейса (см. README).
        NetworkingService.shared.makeCashFlow { [weak self, workItem] extra in
            guard let self, !workItem.isCancelled else { return }
            repository.currentAmount += extra
            balance = repository.currentAmount

            if isCashFlowActive {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: workItem)
            }
        }
    }
}
