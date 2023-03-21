//
//  Truv.swift
//  truv-quickstart
//
//  Created by Rey Riel on 1/25/21.
//

import Foundation

struct CreateUserResponse: Decodable {
    var id: String
}

struct BridgeTokenResponse: Decodable {
    var bridge_token: String
}

struct AccessTokenResponse: Decodable {
    var access_token: String
}

class TruvService {
    
    func createUser(userId: String) async throws -> String {
        let request = try makeRequest(path: "users/", data: ["external_user_id": userId])
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let decoder = JSONDecoder()
        let decodedData = try decoder.decode(CreateUserResponse.self, from: data)
        return decodedData.id
    }
    
    func getBridgeToken(userId: String) async throws -> String {
        let request = try makeRequest(path: "users/\(userId)/tokens/", data: ["product_type": TruvProductType])
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let decoder = JSONDecoder()
        let decodedData = try decoder.decode(BridgeTokenResponse.self, from: data)
        return decodedData.bridge_token
    }
    
    func getAccessToken(publicToken: String) async throws -> String {
        let request = try makeRequest(path: "link-access-tokens/", data: ["public_token": publicToken])
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let decoder = JSONDecoder()
        let decodedData = try decoder.decode(AccessTokenResponse.self, from: data)
        return decodedData.access_token
    }
    
    func getEmploymentInfoByToken(accessToken: String) async throws -> [String: Any]? {
        let request = try makeRequest(path: "links/reports/employment/", data: ["access_token": accessToken])
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        
        return json
    }
    
    func getIncomeInfoByToken(accessToken: String) async throws -> [String: Any]? {
        let request = try makeRequest(path: "links/reports/income/", data: ["access_token": accessToken])
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        
        return json
    }
    
    private func makeRequest(path: String, data: [String: Any]) throws -> URLRequest {
        let url = URL(string: "\(TruvAPIUrl)\(path)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(TruvClientID, forHTTPHeaderField: "X-Access-Client-Id")
        request.setValue(TruvClientSecret, forHTTPHeaderField: "X-Access-Secret")
        
        
        let jsonData = try JSONSerialization.data(withJSONObject: data)
        request.httpBody = jsonData
        
        return request
    }
}
