# Introduction
Let's get you started with Citadel by walking through this iOS Quickstart app. You'll need a set of API keys which you can get by signing up at https://dashboard.citadelid.com

You'll have two different API keys used by the back end, `client_id` and `access_key`.


# Set up the iOS Quickstart
Once you have your API keys, it's time to run the Citadel iOS Quickstart app locally.
*Requirements*: XCode and Simulator

1. `git clone https://github.com/citadelid/quickstart-ios`
2. `cd quickstart-ios`
3. Create a `citadel-quickstart/Constants.swift` file with the following content (values with <> should be replaced by the proper keys or values):
```
import Foundation

var CitadelClientID = "<client_id>"
var CitadelClientSecret = "<access_key>"
var CitadelAPIUrl = "https://prod.citadelid.com/v1/"
var CitadelProductType = "<employment or income>"
```
5. Open the project in XCode and run the app

# Run your first verification
## Overview
The iOS Quickstart app emulates the experience of an applicant going through a background check/income verification inside an iOS app.

If the verification is successful via Citadel, we return the data on screen.

## Successful verification

After opening the iOS Quickstart app you will be presented with the Citadel Bridge. Select the button to choose a Payroll Provider and choose "ADP"

Use the Sandbox credentials to simulate a successful login.

```
username: goodlogin
password: goodpassword
```

Once you have entered your credentials and moved to the next screen, you have succesfully done your first verification. 

The API call will be executed and the data will be loaded into the next view.

# What happened under the hood

- :smiley: = User
- :iphone: = iOS App

Here is the flow that a successful verification process takes in our example:

1. [:iphone: sends API request to Citadel for `bridge_token`](#step-1)
2. [:iphone: loads mobile page from Citadel CDN with `bridge_token` into native WebView](#step-2)
3. [:smiley: selects employer, choses provider, logs in, clicks `Done`](#step-3)
4. [:iphone: sends API request to Citadel exchanging temporary `token` for `access_token`](#step-4)
5. [:iphone: sends API request to Citadel with `access_token` for employment/income verification](#step-5)
6. [:iphone: renders the verification info sent back by Citadel for :smiley: to view](#step-6)

## <a id="step-1"></a>1. :iphone: sends API request to Citadel for `bridge_token`
```
  citadel.getBridgeToken() { bridgeToken, error in
```
```
  func getBridgeToken (completionHandler:@escaping (String?, Error?) -> Void ) -> URLSessionTask {
    let url = URL(string: "\(CitadelAPIUrl)bridge-tokens/")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue(CitadelClientID, forHTTPHeaderField: "X-Access-Client-Id")
    request.setValue(CitadelClientSecret, forHTTPHeaderField: "X-Access-Secret")
        
    let task = URLSession.shared.dataTask(with: request) { data, response, error -> Void in
      guard let data = data, error == nil else {
        print(error?.localizedDescription ?? "No data")
        completionHandler(nil, error)
        return
      }
    
      do {
        let decoder = JSONDecoder()
        let decodedData = try decoder.decode(BridgeTokenResponse.self, from: data)
        completionHandler(decodedData.bridge_token, nil)
        return
      } catch {
        print("Something went wrong")
        completionHandler(nil, error)
        return
      }
    }
    task.resume()
    return task
  }
```
## <a id="step-2"></a>2. :iphone: loads mobile page from Citadel CDN into native WebView
```
  let uuid = NSUUID().uuidString
  var components = URLComponents(string: "https://cdn.citadelid.com/mobile.html")
  components?.queryItems = [URLQueryItem(name: "bridge_token", value: bridgeToken),
                            URLQueryItem(name: "product", value: CitadelProductType),
                            URLQueryItem(name: "tracking_info", value: uuid),
                            URLQueryItem(name: "client", value: "Your company name")]
  let myRequest = URLRequest(url: (components?.url)!)
  self.webView.load(myRequest)
```
## <a id="step-3"></a>3. :smiley: selects employer, choses provider, logs in, clicks `Done`
## <a id="step-4"></a>4. :iphone: sends API request to Citadel exchanging temporary `token` for `access_token`
```
  let publicToken = (payload?["public_token"] as! String)
  citadel.getAccessToken(publicToken: publicToken) { accessToken, error in
    if(CitadelProductType == "employment") {
      self.setupEmployment(accessToken: accessToken!)
    } else {
      self.setupIncome(accessToken: accessToken!)
    }
  }
```
```
  func getAccessToken (publicToken: String, completionHandler:@escaping (String?, Error?) -> Void ) -> URLSessionTask {
    let url = URL(string: "\(CitadelAPIUrl)access-tokens/")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(CitadelClientID, forHTTPHeaderField: "X-Access-Client-Id")
    request.setValue(CitadelClientSecret, forHTTPHeaderField: "X-Access-Secret")
    let json: [String: Any] = ["public_tokens": [publicToken]]
    do {
      let jsonData = try JSONSerialization.data(withJSONObject: json)
      request.httpBody = jsonData
    } catch {
      print("Access Token Error")
      print(error)
      completionHandler(nil, error)
    }
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error -> Void in
      guard let data = data, error == nil else {
          print(error?.localizedDescription ?? "No data")
          completionHandler(nil, error)
          return
      }
      do {
        let decoder = JSONDecoder()
        let decodedData = try decoder.decode(AccessTokenResponse.self, from: data)
        completionHandler(decodedData.access_tokens.first, nil)
      } catch {
        print("Something went wrong")
        print(error)
        completionHandler(nil, error)
      }
    }
    task.resume()
    return task
  }
```
## <a id="step-5"></a>5. :iphone: sends API request to Citadel with `access_token` for employment/income verification
```
  func getEmploymentInfoByToken (accessToken: String, completionHandler:@escaping ([String: Any]?, Error?) -> Void ) -> URLSessionTask {
    let url = URL(string: "\(CitadelAPIUrl)verifications/employments/")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(CitadelClientID, forHTTPHeaderField: "X-Access-Client-Id")
    request.setValue(CitadelClientSecret, forHTTPHeaderField: "X-Access-Secret")
    let json: [String: Any] = ["access_token": accessToken]
    do {
      let jsonData = try JSONSerialization.data(withJSONObject: json)
      request.httpBody = jsonData
    } catch {
      print("Employment Info by Token Error")
      print(error)
      completionHandler(nil, error)
    }
        
    let task = URLSession.shared.dataTask(with: request) { data, response, error -> Void in
      guard let data = data, error == nil else {
        print(error?.localizedDescription ?? "No data")
        completionHandler(nil, error)
        return
      }
      let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
      completionHandler(json, nil)
    }
    task.resume()
    return task
    }
```
## <a id="step-6"></a>6. :iphone: renders the verification info sent back by Citadel for :smiley: to view
```
  let finalView = EmploymentView(data: result!)
                    
  self.webView.removeFromSuperview()
  self.view.addSubview(finalView)
```
