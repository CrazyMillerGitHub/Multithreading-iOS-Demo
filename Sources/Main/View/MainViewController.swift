import Observation
import UIKit

final class MainViewController: UIViewController {
    private let viewModel: MainViewModel

    private lazy var currentBalanceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()

    private lazy var startCashFlowButton: BankButton = {
        let button = BankButton(frame: .zero)
        var config = UIButton.Configuration.filled()
        config.titleAlignment = .center
        button.configuration = config
        button.contentHorizontalAlignment = .center
        button.addAction(
            UIAction { [weak self] _ in
                self?.viewModel.toggleCashFlow()
            }, for: .touchUpInside
        )
        return button
    }()

    private lazy var spendingButton: UIButton = {
        let button = UIButton(frame: .zero)
        var config = UIButton.Configuration.filled()
        config.titleAlignment = .center
        button.setTitle("Время потратить", for: .normal)
        button.configuration = config
        button.addAction(
            UIAction { [weak self] _ in
                self?.viewModel.spendMoney()
            }, for: .touchUpInside
        )
        return button
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [startCashFlowButton, spendingButton])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        view.backgroundColor = .systemBackground
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    private func setupUI() {
        [currentBalanceLabel, stackView].forEach(view.addSubview(_:))
        prepareConstraints()
    }

    private func prepareConstraints() {
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            stackView.heightAnchor.constraint(equalToConstant: 56),

            currentBalanceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currentBalanceLabel.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -20),
        ])
    }

    // MARK: - Observation bridge

    /// Мост @Observable → UIKit для iOS 17.
    ///
    /// `withObservationTracking` — ОДНОРАЗОВЫЙ трекинг: после срабатывания
    /// onChange подписка умирает, поэтому метод перерегистрирует себя
    /// рекурсивно изнутри колбэка. Так View подписывается заново на каждое
    /// новое чтение свойств ViewModel.
    ///
    /// Важно: onChange может прилететь на background-потоке (сеть пишет
    /// balance из фона) — это учебная часть кейса, хоп на main здесь
    /// специально НЕ делается (см. README).
    private func bindViewModel() {
        withObservationTracking {
            render(viewModel)
        } onChange: { [weak self] in
            // Свойство, прочитанное в render, изменилось. Перерегистрация
            // синхронная: render выполнится в том потоке, на котором сработал
            // onChange (в т.ч. на background) — учебный баг «UI не из main»
            // сохраняется намеренно (см. README).
            self?.bindViewModel()
        }
    }

    private func render(_ viewModel: MainViewModel) {
        // Все чтения свойств внутри этого метода попадают в трекинг.
        currentBalanceLabel.text = viewModel.balance.formatted(.currency(code: "RUB"))
        let state: BankButton.BankButtonState = viewModel.isCashFlowActive ? .start : .stop
        startCashFlowButton.cashState = state
        startCashFlowButton.setTitle(state.buttonTitle, for: .normal)
    }
}
