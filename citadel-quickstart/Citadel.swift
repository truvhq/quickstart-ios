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
    var access_token: String
}

class Citadel {
    
    func getBridgeToken (completionHandler:@escaping (String?, Error?) -> Void ) -> URLSessionTask {
        let url = URL(string: "\(CitadelAPIUrl)bridge-tokens/")!
        let json: [String: Any] = ["product_type": CitadelProductType]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue(CitadelClientID, forHTTPHeaderField: "X-Access-Client-Id")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
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
                print(error)
                completionHandler(nil, error)
                return
            }
        }
        task.resume()
        return task
    }
    
    func getAccessToken (publicToken: String, completionHandler:@escaping (String?, Error?) -> Void ) -> URLSessionTask {
        let url = URL(string: "\(CitadelAPIUrl)link-access-tokens/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(CitadelClientID, forHTTPHeaderField: "X-Access-Client-Id")
        request.setValue(CitadelClientSecret, forHTTPHeaderField: "X-Access-Secret")
        let json: [String: Any] = ["public_token": publicToken]
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
                completionHandler(decodedData.access_token, nil)
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
    
    func getIncomeInfoByToken (accessToken: String, completionHandler:@escaping ([String: Any]?, Error?) -> Void ) -> URLSessionTask {
        let url = URL(string: "\(CitadelAPIUrl)verifications/incomes/")!
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
