//
//  UserDefault.swift
//
//  Created by Michael L. Ward on 5/29/17.
//  Copyright © Michael L. Ward. All rights reserved.
//

import Foundation

struct UserDefault<T> {
    let key: String
    let defaults: UserDefaults
    
    var value: T? {
        get {
            let val = defaults.value(forKey: key)
            guard let t = val as? T? else {
                fatalError("Defaults object for key '\(key)' is of type \(type(of:val)), expected \(T.self)")
            }
            return t
        }
        set {
            defaults.set(newValue, forKey: key)
        }
    }
    
    init(key: String, value: T? = nil, defaults: UserDefaults = UserDefaults.standard) {
        self.key = key
        self.defaults = defaults
        defaults.register(defaults: [key:value as Any])
    }
}

extension UserDefault where T == Bool {
    var boolValue: Bool {
        get { return self.value ?? false }
        set { self.value = newValue }
    }
}

