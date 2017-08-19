//
//  SnippetsViewController.swift
//  MonkeyDo
//
//  Created by Michael L. Ward on 8/4/17.
//  Copyright © 2017 Mikey Ward. All rights reserved.
//

import Cocoa

class SnippetsViewController: NSViewController {

    @objc dynamic var snippetStore: SnippetStore!
    
    @IBOutlet var arrayController: NSArrayController!
    @IBOutlet var nameField: NSTextField!
    @IBOutlet var bodyTextView: NSTextView!
    
    override func viewWillDisappear() {
        NSApp.keyWindow?.makeFirstResponder(nil)
        snippetStore.save()
    }
    
}

