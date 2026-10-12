import UIKit

protocol MainPresenterProtocol {
    func toggleCashFlowTapped()
    func spendingTapped()
    func viewDidLoad()
}

protocol MainViewControllerProtocol: AnyObject {
    func showBalance(_ balance: Decimal)
    func updateButtonAppearance(state: BankButton.BankButtonState)
}

final class MainViewController: UIViewController, MainViewControllerProtocol {
    private let presenter: MainPresenterProtocol

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
                self?.presenter.toggleCashFlowTapped()
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
                self?.presenter.spendingTapped()
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

    init(presenter: MainPresenterProtocol) {
        self.presenter = presenter
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
        presenter.viewDidLoad()
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

    func showBalance(_ balance: Decimal) {
        currentBalanceLabel.text = balance.formatted(.currency(code: "RUB"))
    }

    func updateButtonAppearance(state: BankButton.BankButtonState) {
        startCashFlowButton.cashState = state
        startCashFlowButton.setTitle(state.buttonTitle, for: .normal)
    }
}
