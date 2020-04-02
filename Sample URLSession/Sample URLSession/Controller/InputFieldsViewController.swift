//
//  InputFieldsViewController.swift
//  Sample URLSession
//
//  Created by Bharani on 31/03/20.
//  Copyright © 2020 bharani. All rights reserved.
//

import UIKit

class InputFieldsViewController: UIViewController {

    var inputFieldsResponse: InputFieldsResponse!
    var formattedFields: [Field] = []
    var possibleValues: [PossibleValue] = []
    var fieldForPickerView: Field?
    var selectedTextField: CustomTextField?

    let api: String = "http://stg2be.qicsend.com/uat/PCMCoreService/PublicApiRequestProcessor/GetRecipientFields"
    
    ///personal details payload
//    let RequestId = "17807F0F-23A0-49C0-900C-1D63E672A7A5"
//    let RemittanceOptionId = "12"
//    let ClientAppId = "FDFC611C-78F0-48E8-8665-D9EF269929CF"
//    let ClientAppVersion = "1.8"
    
    ///Beneficiary details payload
    let RequestId = "7DE92540-F1B3-431F-8385-B34C52BEF588"
    let RemittanceOptionId = "49"
    let ClientAppId = "FDFC611C-78F0-48E8-8665-D9EF269929CF"
    let ClientAppVersion = "1.8"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var submitBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(enableSubmitButton), name: Notification.Name("enableSubmitBtn"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(createPickerView), name: Notification.Name("showPicker"), object: nil)
        self.styleSubmitBtn()
        self.registerCell()
        self.loadFieldsFromAPI()
    }
    
    func loadFieldsFromAPI() {
        if let url = URL(string: self.api) {
            let request = RequestUtil.getRequest(withUrl: url, requestBody: self.getRequestBody(), acceptJSON: true)
            self.submit(withRequest: request)
        }
    }
    
    func registerCell() {
        self.tableView.register(FieldDataCell.self, forCellReuseIdentifier: "FieldDataCell")
    }
    
    func styleSubmitBtn() {
        self.submitBtn.layer.cornerRadius = 10
        self.submitBtn.isEnabled = false
        self.submitBtn.backgroundColor = .lightGray
    }
    
    func getRequestBody() -> Data {
        let requestBody = FieldsDataRequest(RequestId: self.RequestId, RemittanceOptionId: self.RemittanceOptionId, ClientAppId: self.ClientAppId, ClientAppVersion: self.ClientAppVersion)
        let encoder = JSONEncoder()
        var jsonData: Data = Data()
        do {
            jsonData = try encoder.encode(requestBody)
        } catch {
            print(error)
        }
        return jsonData
    }
    
    //Order property might be nil.
    func sortFields() {
        self.formattedFields = self.formattedFields.sorted(by: { first, second -> Bool in
            var firstOrder: Int = 0
            var secondOrder: Int = 1
            if let order = first.Order {
                firstOrder = order
            }
            if let order = second.Order {
                secondOrder = order
            }
            return firstOrder < secondOrder
        })
    }
    
    func formatFields() {
        self.formattedFields = self.inputFieldsResponse.FieldData
        
        //adding confirmation fields
        self.inputFieldsResponse.FieldData.forEach({ field in
            if field.RequiresConfirmation {
                let newField = Field(field: field)
                newField.Description = "Confirm \(field.Description)"
                self.formattedFields.append(newField)
            }
        })
//        self.formattedFields = temp.sorted(by: { $0.Order < $1.Order })
        self.sortFields()
    }
    
    func submit(withRequest request: URLRequest) {
        let session = URLSession.shared

        let task = session.dataTask(with: request) { (data, response, error) -> Void in
            if (error != nil) {
                return
            }
            do {
                let json = try JSONDecoder().decode(InputFieldsResponse.self, from: data! )
                self.inputFieldsResponse = json
                DispatchQueue.main.async {
                    self.formatFields()
                    self.tableView.reloadData()
                }
            } catch {
                print("Error during JSON serialization: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    @objc func enableSubmitButton() {
        self.submitBtn.isEnabled = self.areAllFieldsValid()
        if self.submitBtn.isEnabled {
            self.submitBtn.backgroundColor = .systemTeal
        } else {
            self.submitBtn.backgroundColor = .lightGray
        }
    }
    
    func areAllFieldsValid() -> Bool {
        let allFieldsValid = self.formattedFields.allSatisfy({ ($0.isValid ?? false) })
        return allFieldsValid
    }
    
    @IBAction func submit(_ sender: UIButton) {
        let confirmationFields = self.formattedFields.filter({ $0.RequiresConfirmation })
        var confirmationText: [String: String] = [:]
        var confirmationStatus: [String: Bool] = [:]
        confirmationFields.forEach({ field in
            if let confirmationText = confirmationText[field.Name] {
                confirmationStatus[field.Name] = confirmationText == field.text
            } else {
                confirmationText[field.Name] = field.text
            }
        })
        
        //Can modify later for submitting
        let confirmationSatisfied = confirmationStatus.allSatisfy({ $0.value })
        let title = confirmationSatisfied ? "Valid Form" : "Confirmation fields should be same!"
        var message = confirmationSatisfied ? "Successfully submitted!" : ""
        let actionName = confirmationSatisfied ? "OK" : "Cancel"
        if !confirmationSatisfied {
            confirmationStatus.forEach({ status in
                if !status.value {
                    message += "\(status.key), "
                }
            })
        }
        self.showSimpleAlert(title: title, message: message, actionName: actionName)
        
    }
    
    func showSimpleAlert(title: String, message: String, actionName: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: actionName, style: UIAlertAction.Style.default, handler: { _ in
            //Cancel Action
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @objc func createPickerView(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        guard let selectedTextField = userInfo["selectedTextField"] as? CustomTextField else { return }
        self.selectedTextField = selectedTextField
        let picker = UIPickerView()
        picker.backgroundColor = .white
        picker.delegate = self
        picker.dataSource = self
        selectedTextField.inputView = picker
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.action))
        toolBar.setItems([button], animated: true)
        toolBar.isUserInteractionEnabled = true
        selectedTextField.inputAccessoryView = toolBar
    }
    
    @objc func action() {
       view.endEditing(true)
    }
}

extension InputFieldsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.formattedFields.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FieldDataCell", for: indexPath) as! FieldDataCell
        cell.field = self.formattedFields[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Required fields are marked with *"
    }
}

extension InputFieldsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("DidSelectRowAt, tableView")
    }
}


extension InputFieldsViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let textField = self.selectedTextField, let field = textField.field {
            return field.PossibleValues.count
        }
        return 0
    }
    
}

extension InputFieldsViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let textField = self.selectedTextField, let field = textField.field else { return nil }
        return field.PossibleValues[row].Description
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let textField = self.selectedTextField, let field = textField.field else { return }
        textField.text = field.PossibleValues[row].Value
    }
}
