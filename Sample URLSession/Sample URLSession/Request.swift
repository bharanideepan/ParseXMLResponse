//
//  Request.swift
//  Sample URLSession
//
//  Created by Bharani on 30/03/20.
//  Copyright © 2020 bharani. All rights reserved.
//

import Foundation

struct RequestBody: Codable {
    
    let ClientAppVersion: String
    let ClientAppId: String
    let Country: String
    let RequestId: String
    
}
