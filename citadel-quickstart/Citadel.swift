//
//  Citadel.swift
//  citadel-quickstart
//
//  Created by Rey Riel on 1/25/21.
//

import Foundation

struct BridgeTokenResponse: Decodable {
    var bridge_token: String
}

struct AccessTokenResponse: Decodable {
    var access_tokens: [String]
}

class Citadel {
    
    func getBridgeToken (completionHandler:@escaping (String?, Error?) -> Void ) -> URLSessionTask {
        let url = URL(string: "\(CitadelAPIUrl)bridge-tokens/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(CitadelClientID, forHTTPHeaderField: "X-Access-Client-Id")
        request.setValue(CitadelClientSecret, forHTTPHeaderField: "X-Access-Secret")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let parameters: [String: String] = [
            "product_type": CitadelProductType,
        ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }

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
}
