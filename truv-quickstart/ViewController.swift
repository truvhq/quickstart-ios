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
    
    func setupEmployment(accessToken: String) async {
        do {
            let result = try await truvService.getEmploymentInfoByToken(accessToken: (accessToken))
            
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
            
        } catch {
            print("error happened when getting employment info: \(error.localizedDescription)")
        }
    }

    
    func setupIncome(accessToken: String) async {
        do {
            let result = try await truvService.getIncomeInfoByToken(accessToken: (accessToken))
        
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
        } catch {
            print("error hapenned when getting income info \(error.localizedDescription)")
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

        Task {
            do {
                let userId = try await truvService.createUser(userId: "truv-quickstart")
                let bridgeToken = try await truvService.getBridgeToken(userId: userId)
                
                let bridgeView = TruvBridgeView(token: bridgeToken, delegate: self)
                self.setupUI(with: bridgeView)
                self.bridgeView = bridgeView
            } catch {
                print("Error while getting bridge token: \(error.localizedDescription)")
            }
        }
    }
}

extension ViewController: TruvDelegate {
    func onEvent(_ event: TruvEvent) {
        print(event)
        switch event {
        case .onClose:
            print("Widget closed")
        case .onSuccess(let payload):
            guard let publicToken = payload?.publicToken else { return }
        
            Task {
                let accessToken = try await truvService.getAccessToken(publicToken: publicToken)
                if(TruvProductType == "employment") {
                    await self.setupEmployment(accessToken: accessToken)
                } else {
                    await self.setupIncome(accessToken: accessToken)
                }
            }
        default:
            break
        }
    }

}
