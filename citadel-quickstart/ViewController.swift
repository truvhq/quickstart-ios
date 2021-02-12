import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate, WKScriptMessageHandler {

    lazy var citadel = Citadel()
    
    lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController.add(self, name: "iosListener")
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let body = message.body as! NSDictionary
        let event = body["event"] as! String
        let payload = body["payload"] as? NSDictionary
        print(event)
        if ((payload) != nil) {
            print(payload as Any)
        }
        
        if (event == "onClose" || event == "onSuccess") {
            print("close webview")
            if (event == "onClose") {
                let doneScreen = SuccessScreen()
                doneScreen.result = "Verification wasn't finished"
                present(doneScreen, animated: true)
            } else {
                let publicToken = (payload?["public_token"] as! String)
                _ = citadel.getAccessToken(publicToken: publicToken) { accessToken, error in
                    if(CitadelProductType == "employment") {
                        self.setupEmployment(accessToken: accessToken!)
                    } else {
                        self.setupIncome(accessToken: accessToken!)
                    }
                }
            }
        }
    }
    
    func setupEmployment(accessToken: String) {
        _ = self.citadel.getEmploymentInfoByToken(accessToken: (accessToken)) { result, error in
            if(result != nil) {
                DispatchQueue.main.async {
                    let finalView = EmploymentView(data: result!)
                    
                    self.webView.removeFromSuperview()
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
        _ = self.citadel.getIncomeInfoByToken(accessToken: (accessToken)) { result, error in
            if(result != nil) {
                DispatchQueue.main.async {
                    let finalView = IncomeView(data: result!)
                    
                    self.webView.removeFromSuperview()
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

    func setupUI() {
        self.view.backgroundColor = .white
        self.view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor
                .constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            webView.leftAnchor
                .constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            webView.bottomAnchor
                .constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            webView.rightAnchor
                .constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor)
        ])
        

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        //        // prepare json data
        //        let json: [String: Any] = ["title": "ABC",
        //                                   "dict": ["1":"First", "2":"Second"]]
        //
        //        let jsonData = try? JSONSerialization.data(withJSONObject: json)

                // create post request
        _ = citadel.getBridgeToken() { bridgeToken, error in
            let uuid = NSUUID().uuidString
            var components = URLComponents(string: "https://cdn.citadelid.com/mobile.html")
            components?.queryItems = [URLQueryItem(name: "bridge_token", value: bridgeToken),
                                      URLQueryItem(name: "product", value: CitadelProductType),
                                      URLQueryItem(name: "tracking_info", value: uuid),
                                      URLQueryItem(name: "client", value: "Your company name")]
            let myRequest = URLRequest(url: (components?.url)!)
            self.webView.load(myRequest)
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
