//
//  CGKeyCode+Helpers.swift
//  MonkeyDo
//
//  Created by Michael L. Ward on 8/4/17.
//  Copyright © 2017 Mikey Ward. All rights reserved.
//

import Foundation
import Quartz

extension CGKeyCode {
    
    var string: String? {
        guard let unmanagedString = createStringForKey(self) else { return nil }
        return unmanagedString.takeRetainedValue() as String
    }
    
    var cchar: CChar? {
        return string?.utf8CString.first
    }
    
    var character: Character? {
        return string?.characters.first
    }
    
    init?(_ string: String) {
        guard string.utf8CString.count == 2 else {
            print("\(string) is composed of \(string.utf8CString)")
            return nil
        }
        let char = string.utf8CString.first!
        let keycode = keyCodeForChar(char)
        if keycode == UInt16.max { return nil }
        self = keycode
    }

    init?(_ char: CChar) {
        let keycode = keyCodeForChar(char)
        if keycode == UInt16.max { return nil }
        self = keycode
    }
    
    init?(_ character: Character) {
        let string = String(character)
        self.init(string)
    }
}
