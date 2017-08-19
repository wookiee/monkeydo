//
//  HeadlessApplication.swift
//  MonkeyDo
//
//  Created by Michael L. Ward on 8/19/17.
//  Copyright © 2017 Mikey Ward. All rights reserved.
//

import Cocoa
import Carbon

@objc class HeadlessApplication: NSApplication {
    override func sendEvent(_ event: NSEvent) {
        if event.type == NSEvent.EventType.keyDown {
            
            if (event.modifierFlags.contains(NSEvent.ModifierFlags.command)) {
                switch Int(event.keyCode) {
                case kVK_ANSI_X:
                    if NSApp.sendAction(#selector(NSText.cut(_:)), to:nil, from:self) { return }
                case kVK_ANSI_C:
                    if NSApp.sendAction(#selector(NSText.copy(_:)), to:nil, from:self) { return }
                case kVK_ANSI_V:
                    if NSApp.sendAction(#selector(NSText.paste(_:)), to:nil, from:self) { return }
                case kVK_ANSI_A:
                    if NSApp.sendAction(#selector(NSText.selectAll(_:)), to:nil, from:self) { return }
                default:
                    break
                }
            }
        }
        return super.sendEvent(event)
    }
    
}
