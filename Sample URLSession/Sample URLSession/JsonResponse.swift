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
