//
//  SnippetStore.swift
//  MonkeyDo
//
//  Created by Michael L. Ward on 8/17/17.
//  Copyright © 2017 Mikey Ward. All rights reserved.
//

import Foundation

class SnippetStore {
    
    var snippets: [Snippet] = []
    private(set) var storeURL: URL?
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private let queue: OperationQueue = {
        let q = OperationQueue()
        q.maxConcurrentOperationCount = 1
        return q
    }()
    
    func load(from url: URL, andThenUpon completionQueue: OperationQueue, execute completion: @escaping (Result<[Snippet]>)->Void) {
        queue.addOperation {
            var result: Result<[Snippet]>
            
            defer {
                completionQueue.addOperation {
                    completion(result)
                }
            }
            
            do {
                let snippetData = try Data(contentsOf: url, options: [])
                self.snippets = try self.decoder.decode(Array<Snippet>.self, from: snippetData)
                self.storeURL = url
                result = .success(self.snippets)
            } catch {
                result = .failure(error)
            }
        }
    }
    
    func save(andThenUpon completionQueue: OperationQueue, execute completion: @escaping (BooleanResult)->Void) {
        queue.addOperation {
            let savedSuccessfully = self.save()
            completionQueue.addOperation {
                completion(savedSuccessfully)
            }
        }
    }
    
    func createNew(at url: URL, andThenUpon completionQueue: OperationQueue, execute completion: @escaping (BooleanResult)->Void) {
        queue.addOperation {
            self.storeURL = url
            self.snippets = [Snippet(name: "Sample", body: "this is a sample snippet!")]
            let savedSuccessfully = self.save()
            completionQueue.addOperation {
                completion(savedSuccessfully)
            }
        }
    }
    
    private func save() -> BooleanResult {
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
}
