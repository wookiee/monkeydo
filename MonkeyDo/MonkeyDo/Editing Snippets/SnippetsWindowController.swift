//
//  SnippetsWindowController.swift
//  MonkeyDo
//
//  Created by Michael L. Ward on 8/17/17.
//  Copyright © 2017 Mikey Ward. All rights reserved.
//

import Cocoa

class SnippetsWindowController: NSWindowController {
    var snippetStore: SnippetStore!
    var onClose: ((NSWindowController)->Void)?
}
