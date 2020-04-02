//
//  CustomTextField.swift
//  Sample URLSession
//
//  Created by Bharani on 31/03/20.
//  Copyright © 2020 bharani. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {
    
    let padding = UIEdgeInsets(top: 20, left: 30, bottom: 0, right: 10)
    var maximumLength = 10
    var minimumLength = 0
    var isValid: Bool = false
    var possibleValues: [PossibleValue] = []
    
    var field: Field? {
        didSet {
            guard let field = self.field else { return }
            self.text = field.text
            self.placeholder = !field.Optional ? "\(field.Description) *" : field.Description
            self.autocorrectionType = .no
            self.maximumLength = field.MaxLength
            self.minimumLength = field.MinLength
            self.possibleValues = field.PossibleValues
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: self.padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: self.padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: self.padding)
    }
    
    func setValid(forText text: String) {
        guard let field = self.field else { return }
        var minLength = field.MinLength
        if !field.Optional {
            minLength += minLength == 0 ? 1 : 0
        }
        self.isValid = text.count >= minLength
        self.field?.isValid = text.count >= minLength
    }
    
    func setText(text: String) {
        self.field?.text = text
        NotificationCenter.default.post(name: Notification.Name("enableSubmitBtn"), object: nil)
    }
    
}

extension CustomTextField: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if !(self.possibleValues.count == 0) {
            let selectedTextField = ["selectedTextField": self]
            NotificationCenter.default.post(name: Notification.Name("showPicker"), object: nil, userInfo: selectedTextField as [AnyHashable : Any])
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        self.setValid(forText: text)
        self.setText(text: text)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let current = textField.text! as NSString
        let newString = current.replacingCharacters(in: range, with: string) as NSString
        let shouldChangeCharactersIn = newString.length <= self.maximumLength
        
        let text = shouldChangeCharactersIn ? newString : current
        self.setValid(forText: text as String)
        self.setText(text: text as String)
        
        return shouldChangeCharactersIn && self.possibleValues.count == 0
    }
}
