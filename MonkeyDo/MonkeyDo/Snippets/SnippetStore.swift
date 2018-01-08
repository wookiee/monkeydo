//
//  SnippetStore.swift
//  MonkeyDo
//
//  Created by Michael L. Ward on 8/17/17.
//  Copyright © 2017 Mikey Ward. All rights reserved.
//

import Foundation
import AppKit

class SnippetStore: NSObject {

    private var nextSnippetIndex = 0 {
        didSet {
            guard nextSnippetIndex != oldValue else { return }
            selectionIndexes = IndexSet(integer: nextSnippetIndex)
        }
    }
    @objc dynamic var selectionIndexes: IndexSet {
        set {
            precondition(newValue.count <= 1, "Multiple selection should be illegal here")
            guard newValue.count == 1 else { return } // don't update model selection
            nextSnippetIndex = newValue.first!
        }
        get {
            return IndexSet(integer: nextSnippetIndex)
        }
    }
    
    @objc dynamic var snippets: [Snippet] = [] { // @objc dynamic for Bindings support
        didSet {
            if nextSnippetIndex >= snippets.count { nextSnippetIndex = 0 }
            save()
        }
    }

    private(set) var storeURL: URL?
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private let queue: OperationQueue = {
        let q = OperationQueue()
        q.maxConcurrentOperationCount = 1
        return q
    }()

    // MARK: - Managing Snippets File
    
    func load(from url: URL,
              andThenUpon completionQueue: OperationQueue = OperationQueue.main,
              execute completion: ((Result<[Snippet]>)->Void)? = nil) {
        queue.addOperation {
            var result: Result<[Snippet]>
            do {
                let snippetData = try Data(contentsOf: url, options: [])
                
                if let oldSnippetData = try? self.encoder.encode(self.snippets) {
                    // Don't reload if the data hasn't changed
                    if snippetData == oldSnippetData { return }
                }
                
                let snippets = try self.decoder.decode(Array<Snippet>.self, from: snippetData)
                OperationQueue.main.addOperation {
                    self.snippets = snippets
                    self.storeURL = url
                }
                result = .success(snippets)
            } catch {
                result = .failure(error)
            }
            
            completionQueue.addOperation {
                completion?(result)
            }
        }
    }
    
    func save(andThenUpon completionQueue: OperationQueue = OperationQueue.main,
              execute completion: ((BooleanResult)->Void)? = nil) {
        queue.addOperation {
            let savedSuccessfully = self.syncSave()
            completionQueue.addOperation {
                completion?(savedSuccessfully)
            }
        }
    }
    
    func createNew(at url: URL, andThenUpon completionQueue: OperationQueue, execute completion: @escaping (BooleanResult)->Void) {
        self.storeURL = url
        self.snippets = [Snippet(name: "Sample", body: "this is a sample snippet!")]
        queue.addOperation {
            let savedSuccessfully = self.syncSave()
            completionQueue.addOperation {
                completion(savedSuccessfully)
            }
        }
    }
    
    private func syncSave() -> BooleanResult {
        guard let storeURL = storeURL else {
            fatalError("Attempt to save with nil storeURL!")
        }
        
        do {
            let snippetData = try encoder.encode(snippets)
            try snippetData.write(to: storeURL)
            return BooleanResult.success
        } catch {
            print("Failed to save snippets: \(error)")
            return BooleanResult.failure(error)
        }
    }

    // MARK: - Reporting Snippets
    
    func next() -> Snippet? {
        guard nextSnippetIndex < snippets.count else { return nil }
        guard let snippet = snippets.suffix(from: nextSnippetIndex).first(where: {$0.isEnabled}) else { return nil }
        nextSnippetIndex = snippets.index(of: snippet)! + 1
        return snippet
    }
    
    func reset() {
        nextSnippetIndex = 0
    }
}
