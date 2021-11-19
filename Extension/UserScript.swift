//
//  UserScript.swift
//  Extension
//
//  Created by Igor Polousov on 19.11.2021.
//

import Foundation

class UserScript: Codable {
    
    var title: String
    var exampleScript: String
    
    init (title: String, exampleScript: String) {
        self.title = title
        self.exampleScript = exampleScript
    }
}
