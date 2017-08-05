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
    @IBOutlet weak var dvorakModeMenuItem: NSMenuItem!
    var isDvorakEnabled = UserDefault(key: "isDvorakEnabled", value: false)

    var snippets: [String] = []
    var currentSnippetIndex = 0
    let pasteboard = NSPasteboard.general
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var typeScript: NSAppleScript! = nil
    
    override func awakeFromNib() {
        statusItem.title = "🐵"
        statusItem.menu = menulet
        
        registerShortcut()
        dvorakModeMenuItem.state = isDvorakEnabled.boolValue ? .on : .off
        
        let scriptURL = Bundle.main.url(forResource: "TypePasteboard", withExtension: "scpt")!
        typeScript = NSAppleScript(contentsOf: scriptURL, error: nil)!
    }

    // MARK: - Actions
    
    @IBAction func typeMenuItemClicked(_ sender: NSMenuItem) {
        typeNextSnippet()
    }
    
    @IBAction func resetMenuItemClicked(_ sender: NSMenuItem) {
        currentSnippetIndex = 0
    }
    
    @IBAction func selectSnippetsMenuItemClicked(_ sender: NSMenuItem) {
        selectSnippetsFile()
    }

    
    
    // Booyah!
    
    
    @IBAction func dvorakMenuItemClicked(_ sender: NSMenuItem) {
        if isDvorakEnabled.boolValue {
            isDvorakEnabled.boolValue = false
            sender.state = .off
        } else {
            isDvorakEnabled.boolValue = true
            sender.state = .on
        }
        registerShortcut()
    }
    
    @IBAction func quitMenuItemClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
    
    // MARK: - Importing Snippets
    
    func makeOpenPanel() -> NSOpenPanel {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowedFileTypes = ["public.text"]
        panel.title = "Open Snippets"
        return panel
    }
    
    func selectSnippetsFile() {
        let openPanel = makeOpenPanel()
        openPanel.runModal()
        guard let url = openPanel.urls.first else { return }
        openSnippets(at: url) { (result) in
            switch result {
            case .failure(let error):
                let alert = NSAlert(error: error)
                alert.alertStyle = .critical
                alert.runModal()
            case .success(let snippets):
                self.snippets = snippets
                self.currentSnippetIndex = 0
                print("Loaded \(snippets.count) snippets.")
                break
            }
        }
    }

    func openSnippets(at url: URL, completion: (Result<[String]>)->Void) {
        var result: Result<[String]>
        defer { completion(result) }
        do {
            let blob = try String(contentsOf: url)
            let strings = blob.components(separatedBy: "#####")
            result = .success(strings)
        } catch {
            result = .failure(error)
        }
    }
    
    // MARK: - Receiving Keyboard Shortcuts
    var eventMonitor: Any?
    func registerShortcut() {
        let opts = NSDictionary(object: kCFBooleanTrue,
                                forKey: kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString) as CFDictionary
        guard AXIsProcessTrustedWithOptions(opts) == true else { return }
        
        let keyCode = isDvorakEnabled.boolValue ? kVK_ANSI_Semicolon : kVK_ANSI_S
        
        if let eventMonitor = eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
        }
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { (event) in
            guard event.keyCode == keyCode else { return }
            let desiredFlags: NSEvent.ModifierFlags = [.control, .option, .command]
            let desiredMask: UInt = 1835305
            guard event.modifierFlags.rawValue == desiredMask
                || event.modifierFlags == desiredFlags else { return }
            self.typeNextSnippet()
        }
    }

    // MARK: - Outputting keystrokes
    
    func typeNextSnippet() {
        print("Typing snippet at index \(currentSnippetIndex)")
        if currentSnippetIndex < snippets.count {
            type(snippets[currentSnippetIndex])
            currentSnippetIndex += 1
        } else {
            let alert = NSAlert()
            alert.messageText = "No pending snippets!"
            alert.alertStyle = .warning
            alert.runModal()
        }
    }
    
    func type(_ string: String) {
        pasteboard.clearContents()
        pasteboard.setString(string, forType: .string)
        var errDict: NSDictionary? = [:]
        typeScript.executeAndReturnError(&errDict)
        if let err = errDict, err.count > 0 {
            let alert = NSAlert()
            alert.messageText = err.description
            alert.alertStyle = .critical
            alert.runModal()
        }
    }

    // WIP solution for literally posting keyboard events? Prolly not gonna work because unicode.
    //        for char in string.characters {
    //            guard let keyCode = CGKeyCode(char) else {
    //                print("Dropping char: \(char)")
    //                continue
    //            }
    //
    //            let charEvent = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true)
    //            charEvent?.post(tap: .cgSessionEventTap)
    //        }

}
