//
//  Snippet.swift
//  MonkeyDo
//
//  Created by Michael L. Ward on 8/17/17.
//  Copyright © 2017 Mikey Ward. All rights reserved.
//

import Foundation

struct Snippet: Codable {
    let name: String
    let body: String
    let isEnabled: Bool
    
    init(name: String, body: String, isEnabled: Bool = true) {
        self.name = name
        self.body = body
        self.isEnabled = isEnabled
    }
    
    init(snippet: Snippet, name: String? = nil, body: String? = nil, isEnabled: Bool? = nil) {
        self.name = name ?? snippet.name
        self.body = body ?? snippet.body
        self.isEnabled = isEnabled ?? snippet.isEnabled
    }
}

extension Snippet: Equatable, Hashable {
    
    static func ==(left: Snippet, right: Snippet) -> Bool {
        return left.name == right.name && left.body == right.body
    }
    
    var hashValue: Int {
        return body.hashValue
    }
}
