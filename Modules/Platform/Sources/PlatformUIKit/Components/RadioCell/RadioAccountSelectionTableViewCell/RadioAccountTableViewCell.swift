import RxCocoa
import RxSwift

/// A `UITableViewCell` with a radio button as its accessory view.
/// This radio button serves as a its selection state.
/// The `RadioAccountTableViewCell` contains a `WalletView`
public final class RadioAccountTableViewCell: UITableViewCell {

    // MARK: - Public Properties

    public var presenter: RadioAccountCellPresenter! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let presenter else { return }

            presenter
                .imageContent
                .drive(radioView.rx.content)
                .disposed(by: disposeBag)

            presenter
                .viewModel
                .drive(walletView.rx.rx_viewModel)
                .disposed(by: disposeBag)
        }
    }

    // MARK: - Private Properties

    private var disposeBag = DisposeBag()
    private let walletView = WalletView()
    private let radioView = UIImageView()
    private let separatorView = UIView()

    // MARK: - Lifecycle

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
        presenter = nil
    }

    func setup() {
        backgroundColor = .semantic.background
        contentView.backgroundColor = .semantic.background
        contentView.addSubview(walletView)
        contentView.addSubview(radioView)
        contentView.addSubview(separatorView)
        separatorView.layoutToSuperview(.leading, .trailing, .bottom)
        separatorView.layout(dimension: .height, to: 1.0)
        separatorView.backgroundColor = .semantic.border
        walletView.layout(to: .centerY, of: contentView)
        walletView.layoutToSuperview(.top, offset: 16.0)
        walletView.layoutToSuperview(.leading, offset: 24.0)
        walletView.layout(edge: .trailing, to: .leading, of: radioView, offset: -16.0)
        radioView.layout(size: .edge(24.0))
        radioView.layout(to: .centerY, of: contentView)
        radioView.layoutToSuperview(.trailing, offset: -24.0)
    }
}
