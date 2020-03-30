//
//  ViewController.swift
//  Sample URLSession
//
//  Created by Bharani on 30/03/20.
//  Copyright © 2020 bharani. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var tableData: [Any] = []
    let url: String = "http://stg2be.qicsend.com/uat/PCMCoreService/PublicApiRequestProcessor/GetRecipients"
    
    var responses: [Response] = []
    var elementName: String = String()
    var FirstName = String()
    var MiddleName = String()
    var LastName = String()
    var MobileNumber = String()

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = URL(string: self.url) {
            self.submit(withRequest: self.getRequest(withUrl: url))
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
        return request
    }
    
    func submit(withRequest request: URLRequest) {
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (data, response, error) -> Void in
            if let data = data {
                let parser = XMLParser(data: data)
                parser.delegate = self
                parser.parse()
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        task.resume()
    }

}

extension ViewController: XMLParserDelegate {
    // 1
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        if elementName == "RecipientItem" {
            self.FirstName = ""
            self.MobileNumber = ""
            self.MiddleName = ""
            self.LastName = ""
        }
        
        self.elementName = elementName
    }

    // 2
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "RecipientItem" {
            let response = Response(FirstName: self.FirstName, MiddleName: self.MiddleName, LastName: self.LastName, MobileNumber: self.MobileNumber)
            self.responses.append(response)
        }
    }

    // 3
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if (!data.isEmpty) {
            switch self.elementName {
            case "FirstName":
                self.FirstName = data
            case "MiddleName":
                self.MiddleName = data
            case "LastName":
                self.LastName = data
            case "MobileNumber":
                self.MobileNumber = data
            default:
                break
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return responses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let response = responses[indexPath.row]
        cell.textLabel?.text = "\(response.FirstName) \(response.MiddleName) \(response.LastName)"
        cell.detailTextLabel?.text = response.MobileNumber
        
        return cell
    }
}
