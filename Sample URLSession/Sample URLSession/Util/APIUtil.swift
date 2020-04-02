//
//  APIUtil.swift
//  Sample URLSession
//
//  Created by Bharani on 31/03/20.
//  Copyright © 2020 bharani. All rights reserved.
//

import Foundation

class RequestUtil {

    fileprivate static func getBasicAuth() -> String {
        let username = "pandiyarj@gmail.com"
        let password = "Test1234"
        let userPasswordString = "\(username):\(password)"
        let userPasswordData = userPasswordString.data(using: .utf8)!
        let base64EncodedCredential = userPasswordData.base64EncodedString()
        return "Basic \(base64EncodedCredential)"
    }

    static func getRequest(withUrl url: URL, requestBody: Data?, acceptJSON: Bool) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = requestBody
        request.setValue(self.getBasicAuth(), forHTTPHeaderField: "Authorization")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        if acceptJSON {
            request.setValue("application/json", forHTTPHeaderField: "accept")
        }
        return request
    }

}
