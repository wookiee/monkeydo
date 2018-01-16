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
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var nameField: NSTextField!
    @IBOutlet var bodyTextView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bodyTextView.isAutomaticDataDetectionEnabled = false
        bodyTextView.isAutomaticTextCompletionEnabled = false
        bodyTextView.isAutomaticLinkDetectionEnabled = false
        bodyTextView.isAutomaticDashSubstitutionEnabled = false
        bodyTextView.isAutomaticQuoteSubstitutionEnabled = false
        bodyTextView.isAutomaticSpellingCorrectionEnabled = false
        tableView.registerForDraggedTypes([NSPasteboard.PasteboardType("public.data")])
    }
    
    override func viewWillDisappear() {
        NSApp.keyWindow?.makeFirstResponder(nil)
        snippetStore.save()
    }
    
}

extension SnippetsViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    // from https://gist.github.com/sooop/3c964900d429516ba48bd75050d0de0a
    
    func tableView(_ tableView: NSTableView,
                   writeRowsWith rowIndexes: IndexSet,
                   to pboard: NSPasteboard) -> Bool {
        
        let data = NSKeyedArchiver.archivedData(withRootObject: rowIndexes)
        let item = NSPasteboardItem()
        item.setData(data, forType: NSPasteboard.PasteboardType(rawValue: "public.data"))
        pboard.writeObjects([item])
        return true
    }
    
    func tableView(_ tableView: NSTableView,
                   validateDrop info: NSDraggingInfo,
                   proposedRow row: Int,
                   proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        
        guard let source = info.draggingSource() as? NSTableView,
            source === tableView
            else { return [] }
        
        if dropOperation == .above {
            return .move
        }
        return []
    }
    
    
    func tableView(_ tableView: NSTableView,
                   acceptDrop info: NSDraggingInfo,
                   row: Int,
                   dropOperation: NSTableView.DropOperation) -> Bool {
        
        let pb = info.draggingPasteboard()
        if let itemData = pb.pasteboardItems?.first?.data(forType: NSPasteboard.PasteboardType(rawValue: "public.data")),
            let indexes = NSKeyedUnarchiver.unarchiveObject(with: itemData) as? IndexSet
        {
            snippetStore.snippets.move(with: indexes, to: row)
            let targetIndex = row - (indexes.filter{ $0 < row }.count)
            tableView.selectRowIndexes(IndexSet(targetIndex..<targetIndex+indexes.count), byExtendingSelection: false)
            return true
        }
        return false
    }
}
