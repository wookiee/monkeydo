//
//  Snippet.swift
//  MonkeyDo
//
//  Created by Michael L. Ward on 8/17/17.
//  Copyright © 2017 Mikey Ward. All rights reserved.
//

import Foundation

class Snippet: NSObject, Codable {
    @objc dynamic var name: String = "Snippet"
    @objc dynamic var body: String = ""
    @objc dynamic var isEnabled: Bool = true
    
    @objc dynamic override init() {

    }
    
    @objc dynamic init(name: String, body: String, isEnabled: Bool = true) {
        self.name = name
        self.body = body
        self.isEnabled = isEnabled
    }
}

extension Snippet { // Equatable, Hashable
    
    static func ==(left: Snippet, right: Snippet) -> Bool {
        return left.name == right.name && left.body == right.body
    }
    
    override var hashValue: Int {
        return name.hashValue
    }
}
