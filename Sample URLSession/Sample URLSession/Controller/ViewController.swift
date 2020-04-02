//
//  ViewController.swift
//  Sample URLSession
//
//  Created by Bharani on 30/03/20.
//  Copyright © 2020 bharani. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let api: String = "http://stg2be.qicsend.com/uat/PCMCoreService/PublicApiRequestProcessor/GetRecipients"
    
    var responses: [Response] = []
    var elementName: String = ""
    var currentEntity: Dictionary<String, String> = [:]

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = URL(string: self.api) {
            let request = RequestUtil.getRequest(withUrl: url, requestBody: self.getRequestBody(), acceptJSON: false)
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
            self.currentEntity.forEach({ dict in
                self.currentEntity[dict.key] = ""
            })
        }
        self.elementName = elementName
    }

    // 2
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if (!data.isEmpty) {
            self.currentEntity[self.elementName] = data
        }
    }
    // 3
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "RecipientItem" {
            if let fName = self.currentEntity["FirstName"], let mName = self.currentEntity["MiddleName"], let lName = self.currentEntity["LastName"], let mNumber = self.currentEntity["MobileNumber"] {
                let response = Response(FirstName: fName, MiddleName: mName, LastName: lName, MobileNumber: mNumber)
                self.responses.append(response)
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
