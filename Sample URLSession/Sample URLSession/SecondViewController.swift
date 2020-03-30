//
//  SecondViewController.swift
//  Sample URLSession
//
//  Created by Bharani on 30/03/20.
//  Copyright © 2020 bharani. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    let api: String = "http://stg2be.qicsend.com/uat/PCMCoreService/PublicApiRequestProcessor/GetRecipients"
    
    var jsonresponse: JsonResponse!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = URL(string: self.api) {
            let request = self.getRequest(withUrl: url)
            self.submit(withRequest: request)
        }
    }
    
    func getRequestBody() -> Data {
        let requestBody = RequestBody(ClientAppVersion: "1.8", ClientAppId: "FDFC611C-78F0-48E8-8665-D9EF269929CF", Country: "India", RequestId: "45798525-D8FD-4A1E-8F97-92636802F287")
        let encoder = JSONEncoder()
        var jsonData: Data = Data()
        do {
            jsonData = try encoder.encode(requestBody)
        } catch {
            print(error)
        }
        return jsonData
    }
    
    func getBasicAuth() -> String {
        let username = "pandiyarj@gmail.com"
        let password = "Test1234"
        let userPasswordString = "\(username):\(password)"
        let userPasswordData = userPasswordString.data(using: .utf8)!
        let base64EncodedCredential = userPasswordData.base64EncodedString()
        return "Basic \(base64EncodedCredential)"
    }
    
    func getRequest(withUrl url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = self.getRequestBody()
        request.setValue(self.getBasicAuth(), forHTTPHeaderField: "Authorization")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        return request
    }
    
    func submit(withRequest request: URLRequest) {
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (data, response, error) -> Void in
            do {
                let json = try JSONDecoder().decode(JsonResponse.self, from: data! )
                self.jsonresponse = json
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("Error during JSON serialization: \(error.localizedDescription)")
            }
        }
        task.resume()
    }

}

extension SecondViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.jsonresponse?.RecipientItems.count {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if let response = jsonresponse {
            let recipient = response.RecipientItems[indexPath.row]
            cell.textLabel?.text = "\(recipient.FirstName) \(recipient.MiddleName) \(recipient.LastName)"
            cell.detailTextLabel?.text = recipient.MobileNumber
        }
        
        return cell
    }
}
