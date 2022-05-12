import UIKit
import LinkPresentation

final class LastScansViewController: UIViewController {
    // MARK: - Properties
    // MARK: Public
    // MARK: Private
    private let lastScansTableView = UITableView()
    private var arrayOfLinks = [LinkModel]() {
        didSet {
            fetchURLPreview(qrcodeUrl: arrayOfLinks[0].linkString)
        }
    }
    private var arrayOfViews = [UIView]() {
        didSet {
            lastScansTableView.reloadData()
        }
    }
    private let scanQRbutton = UIButton()
    private lazy var linkView = LPLinkView()
    private var metaData: LPLinkMetadata = LPLinkMetadata() {
        didSet {
            self.addRichLinkToView(metadata: self.metaData)
            
        }
    }
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        addSubviews()
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Last scans"
        
        setupUI()
        addConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scanQRbutton.layer.cornerRadius = 0.5 * scanQRbutton.bounds.size.width
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let links = CoreDataManager.instance.getLink() else {return}
        arrayOfLinks = links
        print(arrayOfViews.count)
    }
    // MARK: - Setups
    private func addSubviews() {
        view.addSubview(lastScansTableView)
        view.addSubview(scanQRbutton)
    }
    
    private func setupUI() {
        //navigationBar
        setupNavigationBar()
        //lastScansTableView
        lastScansTableView.delegate = self
        lastScansTableView.dataSource = self
        lastScansTableView.register(LastScansTableViewCell.self, forCellReuseIdentifier: "LastScansTableViewCell")
        //lastScansTableView.backgroundColor = .systemRed
        lastScansTableView.separatorStyle = .none
        lastScansTableView.tableHeaderView?.backgroundColor = .white
        //scanQRbutton
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .large)
        let largeBoldQRCode = UIImage(systemName: "qrcode.viewfinder", withConfiguration: largeConfig)
        scanQRbutton.setImage(largeBoldQRCode, for: .normal)
        scanQRbutton.backgroundColor = .purple
        scanQRbutton.tintColor = .white
        scanQRbutton.superview?.bringSubviewToFront(scanQRbutton)
        scanQRbutton.addTarget(self, action: #selector(buttonDidTapped), for: .touchUpInside)
    }
    
    private func addConstraints() {
        //lastScansTableView
        lastScansTableView.translatesAutoresizingMaskIntoConstraints = false
        lastScansTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        lastScansTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        lastScansTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        lastScansTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
        //scanQRbutton
        scanQRbutton.translatesAutoresizingMaskIntoConstraints = false
        scanQRbutton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -75).isActive = true
        scanQRbutton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50).isActive = true
        scanQRbutton.widthAnchor.constraint(equalToConstant: 75).isActive = true
        scanQRbutton.heightAnchor.constraint(equalToConstant: 75).isActive = true
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Last scans"
    }
    
    private func addRichLinkToView(metadata: LPLinkMetadata) {
        linkView = LPLinkView(metadata: metadata)
        arrayOfViews.append(linkView)
    }
    
    @available(iOS 13.0, *)
    private func fetchURLPreview(qrcodeUrl: String?) {
        guard let url = URL(string: qrcodeUrl ?? "" ) else { return }
        let metadataProvider = LPMetadataProvider()
        metadataProvider.startFetchingMetadata(for: url) { [weak self] (metadata, error) in
            DispatchQueue.main.async {
                guard let data = metadata, error == nil else {
                    return
                }
                self?.metaData = data
            }
        }
    }
    // MARK: - Actions
    @objc private func buttonDidTapped() {
        let scannerVC = ScannerViewController()
        navigationController?.pushViewController(scannerVC, animated: true)
    }
}
// MARK: - Extensions
extension LastScansViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfViews.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "LastScansTableViewCell", for: indexPath) as? LastScansTableViewCell {
            cell.setupCell(view: arrayOfViews[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    
}

