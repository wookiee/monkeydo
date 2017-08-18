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
    
    @IBOutlet var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

