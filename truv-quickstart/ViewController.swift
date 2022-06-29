import UIKit
import TruvSDK

class ViewController: UIViewController {

    private lazy var truvService = TruvService()

    private var bridgeView: TruvBridgeView?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func setupEmployment(accessToken: String) {
        truvService.getEmploymentInfoByToken(accessToken: (accessToken)) { result, error in
            if(result != nil) {
                DispatchQueue.main.async {
                    let finalView = EmploymentView(data: result!)
                    
                    self.bridgeView?.removeFromSuperview()
                    self.view.addSubview(finalView)
                    
                    NSLayoutConstraint.activate([
                        finalView.topAnchor
                            .constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
                        finalView.leftAnchor
                            .constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
                        finalView.bottomAnchor
                            .constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
                        finalView.rightAnchor
                            .constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor)
                    ])
                }
                
            }
        }
    }
    
    func setupIncome(accessToken: String) {
        truvService.getIncomeInfoByToken(accessToken: (accessToken)) { result, error in
            if(result != nil) {
                DispatchQueue.main.async {
                    let finalView = IncomeView(data: result!)
                    
                    self.bridgeView?.removeFromSuperview()
                    self.view.addSubview(finalView)
                    
                    NSLayoutConstraint.activate([
                        finalView.topAnchor
                            .constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
                        finalView.leftAnchor
                            .constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
                        finalView.bottomAnchor
                            .constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
                        finalView.rightAnchor
                            .constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor)
                    ])
                }
                
            }
        }
    }

    func setupUI(with bridgeView: UIView) {
        self.view.backgroundColor = .white
        self.view.addSubview(bridgeView)
        
        NSLayoutConstraint.activate([
            bridgeView.topAnchor
                .constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            bridgeView.leftAnchor
                .constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            bridgeView.bottomAnchor
                .constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            bridgeView.rightAnchor
                .constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        truvService.getBridgeToken() { [weak self] bridgeToken, _ in
            guard let self = self, let bridgeToken = bridgeToken else { return }

            DispatchQueue.main.async {
                let bridgeView = TruvBridgeView(token: bridgeToken, delegate: self)
                self.setupUI(with: bridgeView)
                self.bridgeView = bridgeView
            }
        }
    }
}

extension ViewController: TruvDelegate {

    func onEvent(_ event: TruvEvent) {
        print(event)

        switch event {
        case .onClose:
            let doneScreen = SuccessScreen()
            doneScreen.result = "Verification wasn't finished"
            present(doneScreen, animated: true)
        case .onSuccess(let payload):
            guard let publicToken = payload?.publicToken else { return }
            truvService.getAccessToken(publicToken: publicToken) { accessToken, error in
                if(TruvProductType == "employment") {
                    self.setupEmployment(accessToken: accessToken!)
                } else {
                    self.setupIncome(accessToken: accessToken!)
                }
            }
        default:
            break
        }
    }

}

class SuccessScreen: UIViewController {
    
    var result = ""
    override func viewDidLoad() {
        let x: CGFloat = 20
        let y: CGFloat = 40
        let height: CGFloat = 50
        let label = UILabel(frame: CGRect(x: x, y: y, width: UIScreen.main.bounds.width, height: height))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.00)
        label.text = self.result
        view.backgroundColor = UIColor(red: 0.46, green: 0.72, blue: 0.51, alpha: 1.00)
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            label.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            label.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor)
        ])
    }
}
