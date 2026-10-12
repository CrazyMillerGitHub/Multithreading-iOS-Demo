import Foundation

final class MainPresenter: MainPresenterProtocol {
    private weak var view: MainViewControllerProtocol?
    private var repository = MainRepository()
    private var isCashFlowActive = false

    func attach(_ view: MainViewControllerProtocol) {
        self.view = view
    }

    func viewDidLoad() {
        view?.showBalance(repository.currentAmount)
    }

    func toggleCashFlowTapped() {
        isCashFlowActive.toggle()
        view?.updateButtonAppearance(state: isCashFlowActive ? .stop : .start)

        if isCashFlowActive {
            performCashFlow()
        }
    }

    func spendingTapped() {
        repository.currentAmount -= 100
        view?.showBalance(repository.currentAmount)
    }

    private func performCashFlow() {
        NetworkingService.shared.makeCashFlow { [weak self] extra in
            guard let self else { return }
            repository.currentAmount += extra
            view?.showBalance(repository.currentAmount)

            if isCashFlowActive {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.performCashFlow()
                }
            }
        }
    }
}
