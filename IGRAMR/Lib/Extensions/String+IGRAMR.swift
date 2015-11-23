//
//  String+IGRAMR.swift
//  IGRAMR
//
//  Created by GrepRuby3 on 08/09/15.
//  Copyright (c) 2015 GrepRuby3. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    // MARK: To check Email is valid or not
    func isValidEmailAddress(email:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluateWithObject(email)
        return result
    }
    
    // MARK: To check Phone umber is valid or not
    func isValidPhoneNumber(phoneNumber: String) -> Bool {
        let phoneRegex = "^\\d{3}-\\d{3}-\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        let result =  phoneTest.evaluateWithObject(phoneNumber)
        return result
    }
    
    func split(splitter: String) -> Array<String> {
        let regEx = try? NSRegularExpression(pattern: splitter, options: NSRegularExpressionOptions())
        let stop = "<SomeStringThatYouDoNotExpectToOccurInSelf>"
        let modifiedString = regEx!.stringByReplacingMatchesInString (self, options: NSMatchingOptions(),
            range: NSMakeRange(0, self.characters.count),
            withTemplate:stop)
        return modifiedString.componentsSeparatedByString(stop)
    }
}
