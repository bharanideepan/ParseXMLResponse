//
//  JsonResponse.swift
//  Sample URLSession
//
//  Created by Bharani on 30/03/20.
//  Copyright © 2020 bharani. All rights reserved.
//

import Foundation

struct JsonResponse: Codable {
    let RecipientItems: [RecipientItem]

    struct RecipientItem: Codable {
        let FirstName: String
        let LastName: String
        let MiddleName: String
        let MobileNumber: String
    }
}

class InputFieldsResponse: Codable {
    var FieldData: [Field]
}

class Field: NSObject, Codable {
    var DefaultValue: String?
    var Description: String
    var IsPersonalField: Bool
    var MaxLength: Int
    var MinLength: Int
    var Name: String
    var Optional: Bool
    var Order: Int?
    var PossibleValues: [PossibleValue]
    var RequiresConfirmation: Bool
    var Row: Int?
    var UseRegEx: String?
    
    var text: String?
    var isValid: Bool?
    
    init(field: Field) {
        
        self.DefaultValue = field.DefaultValue
        self.Description = field.Description
        self.IsPersonalField = field.IsPersonalField
        self.MaxLength = field.MaxLength
        self.MinLength = field.MinLength
        self.Name = field.Name
        self.Optional = field.Optional
        self.Order = field.Order
        self.PossibleValues = field.PossibleValues
        self.RequiresConfirmation = field.RequiresConfirmation
        self.Row = field.Row
        self.UseRegEx = field.UseRegEx
        
        self.text = field.text
        self.isValid = field.isValid
        
    }
}

class PossibleValue: Codable {
    var Description: String
    var Value: String
}
