//
//  ExampleScripts.swift
//  Extension
//
//  Created by Igor Polousov on 19.11.2021.
//

import Foundation

let exampleScripts = [
    (title: "Alert",
     exampleScript: "alert(document.title);"),
    
    (title: "ExtendedAlert",
     exampleScript: """
            alert("Page title: " + document.title + "\\nPage url: " + document.URL);
            """)
]
