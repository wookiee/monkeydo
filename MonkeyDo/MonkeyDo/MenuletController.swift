//
//  MenuletController.swift
//  MonkeyDo
//
//  Created by Michael L. Ward on 8/4/17.
//  Copyright © 2017 Mikey Ward. All rights reserved.
//

import Cocoa
import Carbon
import Quartz

class MenuletController: NSObject {
    
    @IBOutlet weak var menulet: NSMenu!
    @IBOutlet weak var nextSnippetMenuItem: NSMenuItem!
    @IBOutlet weak var typingEnabledMenuItem: NSMenuItem!
    @IBOutlet weak var editSnippetsMenuItem: NSMenuItem!
    
    var isTypingEnabled = UserDefault(key: "isTypingEnabled", value: true)

    let snippetStore = SnippetStore()
    
    let pasteboard = NSPasteboard.general
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var typeScript: NSAppleScript! = nil
    
    var watcher: FileObserver?
    
    override func awakeFromNib() {
        statusItem.title = "🐵"
        statusItem.menu = menulet
        
        registerShortcut()
        typingEnabledMenuItem.state = isTypingEnabled.boolValue ? .on : .off
        
        let scriptURL = Bundle.main.url(forResource: "TypePasteboard", withExtension: "scpt")!
        typeScript = NSAppleScript(contentsOf: scriptURL, error: nil)!
        
        selectSnippetsFile()
    }

    // MARK: - Actions
    
    @IBAction func typeMenuItemClicked(_ sender: NSMenuItem) {
        typeNextSnippet()
    }
    
    @IBAction func resetMenuItemClicked(_ sender: NSMenuItem) {
        snippetStore.reset()
    }
    
    @IBAction func selectSnippetsMenuItemClicked(_ sender: NSMenuItem) {
        selectSnippetsFile()
    }
    
    @IBAction func newSnippetsMenuItemClicked(_ sender: NSMenuItem) {
        newSnippetsFile()
    }
    
    @IBAction func editSnippetsMenuItemClicked(_ sender: NSMenuItem) {
        showSnippetEditor()
    }
    
    @IBAction func quitMenuItemClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
    
    @IBAction func typingEnabledMenuItemClicked(_ sender: NSMenuItem) {
        switch isTypingEnabled.boolValue {
        case true:
            isTypingEnabled.boolValue = false
            typingEnabledMenuItem.state = .off
        case false:
            isTypingEnabled.boolValue = true
            typingEnabledMenuItem.state = .on
        }
    }
    
    // MARK: - Snippets File Management
    
    func makeOpenPanel() -> NSOpenPanel {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowedFileTypes = ["json"]
        panel.title = "Open Snippets"
        return panel
    }
    
    func makeSavePanel() -> NSSavePanel {
        let panel = NSSavePanel()
        panel.title = "New Snippets File"
        panel.message = "Select a location for your new snippets file"
        panel.allowedFileTypes = ["json"]
        return panel
    }
    
    func selectSnippetsFile() {
        let openPanel = makeOpenPanel()
        openPanel.begin { (response) in
            guard response == NSApplication.ModalResponse.OK, let url = openPanel.urls.first else { return }
            self.loadSnippets(at: url)
        }
        openPanel.makeKeyAndOrderFront(self)
    }
    
    func newSnippetsFile() {
        let savePanel = makeSavePanel()
        savePanel.begin { (response) in
            guard response == NSApplication.ModalResponse.OK, let url = savePanel.url else { return }
            self.snippetStore.createNew(at: url, andThenUpon: OperationQueue.main, execute: { (result) in
                guard result == BooleanResult.success else { return }
                self.loadSnippets(at: url)
            })
        }
        savePanel.makeKeyAndOrderFront(self)
    }
    
    func loadSnippets(at url: URL) {
        snippetStore.load(from: url, andThenUpon: OperationQueue.main) { (result) in
            switch result {
            case .failure(let error):
                let alert = NSAlert(error: error)
                alert.alertStyle = .critical
                alert.runModal()
            case .success(let snippets):
                self.snippetStore.reset()
                self.watcher = FileObserver(file: url)
                self.watcher!.delegate = self
                print("Loaded \(snippets.count) snippets.")
            }
        }
    }
    
    lazy var snippetsWC: NSWindowController = {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Snippets"), bundle: nil)
        let snippetsWC = storyboard.instantiateInitialController() as! NSWindowController
        let snippetsVC = snippetsWC.contentViewController as! SnippetsViewController
        snippetsWC.window?.contentView = snippetsVC.view
        snippetsVC.snippetStore = snippetStore
        return snippetsWC
    }()
    
    var snippetsVC: SnippetsViewController {
        return snippetsWC.contentViewController as! SnippetsViewController
    }
    
    func showSnippetEditor() {
        snippetsWC.showWindow(self)
        snippetsWC.window?.makeKeyAndOrderFront(self)
    }
    
    // MARK: - Receiving Keyboard Shortcuts
    var eventMonitor: Any?
    func registerShortcut() {
        let opts = NSDictionary(object: kCFBooleanTrue,
                                forKey: kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString) as CFDictionary
        guard AXIsProcessTrustedWithOptions(opts) == true else { return }

        if let eventMonitor = eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
        }
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { (event) in
            guard event.keyCode == kVK_ANSI_Semicolon else { return }
            let desiredFlags: NSEvent.ModifierFlags = [.control, .option, .command]
            let desiredMask: UInt = 1835305
            guard event.modifierFlags.rawValue == desiredMask
                || event.modifierFlags == desiredFlags else { return }
            self.typeNextSnippet()
        }
    }

    // MARK: - Outputting keystrokes
    
    func typeNextSnippet() {
        guard let snippetText = snippetStore.next()?.body else {
            NSSound.beep()
            return
        }
        
        type(snippetText)
    }
    
    func type(_ string: String) {
        pasteboard.clearContents()
        pasteboard.setString(string, forType: .string)
        if isTypingEnabled.boolValue {
            var errDict: NSDictionary? = [:]
            typeScript.executeAndReturnError(&errDict)
            if let err = errDict, err.count > 0 {
                let alert = NSAlert()
                alert.messageText = err.description
                alert.alertStyle = .critical
                alert.runModal()
            }
        }
    }
    
    // MARK: - Menu Management
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        switch menuItem {
        case editSnippetsMenuItem:
            return snippetStore.storeURL != nil
        default:
            return true
        }
    }

}

extension MenuletController: FileObserverDelegate {
    
    func fileObserver(_ observer: FileObserver,
                      didObserveFileSystemEvents events: [BNRFSEvent]) {
        guard let path = events.first?.path else { return }
        let url = URL(fileURLWithPath: path)
        snippetStore.load(from: url, andThenUpon: OperationQueue.main) { (result) in
            switch result {
            case .failure(let error):
                let alert = NSAlert(error: error)
                alert.messageText = "Your snippets file changed on disk, but the new snippets couldn't be imported.\n\nYour loaded snippets have been left unchanged."
                alert.alertStyle = .critical
                alert.runModal()
            case .success(let snippets):
                self.snippetStore.reset()
                print("Reloaded \(snippets.count) snippets.")
            }
        }
    }

}
