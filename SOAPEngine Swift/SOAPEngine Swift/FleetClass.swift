//
//  FleetClass.swift
//  SOAPEngine Swift
//
//  Created by Austin Chen on 2017-10-12.
//  Copyright © 2017 Danilo Priore. All rights reserved.
//

import Foundation

class FleetClass: ACSoapRemoteRecordType {
    let locationName: String?
    let name: String?
    let pCode: String?
    
    required init(dictionary: [String: Any]) {
        self.locationName = dictionary["LocationName"] as? String
        self.name = dictionary["Name"] as? String
        self.pCode = dictionary["PCode"] as? String
    }
}
