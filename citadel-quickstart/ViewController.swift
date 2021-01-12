import UIKit
import WebKit

struct BridgeTokenResponse: Decodable {
    var bridge_token: String
}

class ViewController: UIViewController, WKUIDelegate, WKScriptMessageHandler {

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
            let doneScreen = SuccessScreen()
            if (event == "onClose") {
                doneScreen.result = "Verification wasn't finished"
            } else {
                doneScreen.result = "Successful verification. Public Token: " + (payload?["public_token"] as! String)
            }
            present(doneScreen, animated: true)
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
        let url = URL(string: "https://dev.citadelid.com/v1/bridge-tokens/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("d19ca76e3d4e4220bc671d198f8a3bb0", forHTTPHeaderField: "X-Access-Client-Id")
        request.setValue("prod-83247e495dad61638f1b872fa7e98fb21dc0fc27", forHTTPHeaderField: "X-Access-Secret")

                // insert json data to the request
        //        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(BridgeTokenResponse.self, from: data)
                print(decodedData.bridge_token)
                let uuid = NSUUID().uuidString
                var components = URLComponents(string: "https://cdn-dev.citadelid.com/mobile.html")
                components?.queryItems = [URLQueryItem(name: "bridge_token", value: decodedData.bridge_token),
                                          URLQueryItem(name: "product", value: "employment"),
                                          URLQueryItem(name: "tracking_info", value: uuid),
                                          URLQueryItem(name: "client", value: "Your company name")]
                let myRequest = URLRequest(url: (components?.url)!)
                self.webView.load(myRequest)
            } catch {
                print("Something went wrond")
            }
        }

        task.resume()
        
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
