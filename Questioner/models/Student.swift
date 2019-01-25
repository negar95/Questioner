//
//  Student.swift
//  Questioner
//
//  Created by negar on 97/Aban/20 AP.
//  Copyright © 1397 negar. All rights reserved.
//

import Foundation
import SwiftyJSON

class Student: Codable {
    var userName = ""
    var password = ""
    var phone = ""
    var email = ""

    var profile = ""
    var fcmToken = ""
    var active = true
    var expireDate = ""
    var isFreeTrialAvailable = true

    enum CodingKeys: String, CodingKey {
        case userName
        case password
        case phone
        case email
        case profile
        case fcmToken
        case active
        case expireDate
        case isFreeTrialAvailable

    }

    class func buildSingle(jsonData: JSON) -> Student {
        let student = Student()

        student.userName = jsonData["userName"].stringValue
        student.password = jsonData["password"].stringValue
        student.phone = jsonData["phone"].stringValue
        student.email = jsonData["email"].stringValue
        student.active = jsonData["active"].boolValue

        if jsonData["profile"].exists() {
            student.profile = jsonData["profile"].stringValue
        }
        if jsonData["fcmToken"].exists() {
            student.fcmToken = jsonData["fcmToken"].stringValue
        }
        student.expireDate = jsonData["expireDate"].stringValue
        student.isFreeTrialAvailable = jsonData["freeTrial"].boolValue

        return student
    }
}
