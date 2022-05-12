import UIKit

final class LastScansTableViewCell: UITableViewCell {
    // MARK: - Properties
    // MARK: Public
    // MARK: Private
    private var internalView = UIView()
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Setups
    private func addSubviews() {
//        contentView.addSubview(internalView)
    }
    
    private func setupUI() {
        //cell
        self.selectionStyle = .none
        //internalView
        internalView.layer.cornerRadius = 13
        internalView.layer.masksToBounds = true
        internalView.backgroundColor = .clear
    }
    
    private func addConstraints() {
        // internalView Constraints
        internalView.translatesAutoresizingMaskIntoConstraints = false
        internalView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        internalView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
        internalView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        internalView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
    }
    // MARK: - API
    func setupCell(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
        view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
//        internalView.frame = view.bounds
    }
}
