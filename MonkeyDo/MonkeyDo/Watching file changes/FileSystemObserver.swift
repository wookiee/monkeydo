//
//  FileSystemObserver.swift
//  MonkeyDo
//
//  Created by Michael L. Ward on 2/5/18.
//  Copyright © 2018 Mikey Ward. All rights reserved.
//

import Foundation
import CoreServices.FSEvents

typealias FileSystemEventHandler = ([FileSystemEvent]) -> Void

class FileSystemObserver {
    private let handler: FileSystemEventHandler
    
    private var directRef: FSEventStreamRef! = nil
    private var context = FSEventStreamContext(version: 0,
                                               info: nil,
                                               retain: nil,
                                               release: nil,
                                               copyDescription: nil)
    
    private let flags = FSEventStreamCreateFlags(kFSEventStreamCreateFlagNoDefer |
                                                 kFSEventStreamCreateFlagUseCFTypes |
                                                 kFSEventStreamCreateFlagFileEvents)
    
    
    convenience init(url: URL, handler: @escaping FileSystemEventHandler) {
        let path = url.path
        self.init(paths: [path], handler: handler)
    }
    
    
    convenience init(urls: [URL], handler: @escaping FileSystemEventHandler) {
        let paths = urls.map { $0.path }
        self.init(paths: paths, handler: handler)
    }
    
    
    init(paths: [String], handler: @escaping FileSystemEventHandler) {

        self.handler = handler
        let contextSelf = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        context = FSEventStreamContext(version: 0,
                                       info: contextSelf,
                                       retain: nil,
                                       release: nil,
                                       copyDescription: nil)
        
        let callback: FSEventStreamCallback = {
            (eventStream, clientInfo, eventCount, opaquePaths, opaqueFlags, opaqueIDs) in
            
            let paths = unsafeBitCast(opaquePaths, to: NSArray.self) as! [String]
            let fsFlags = Array((0..<eventCount).map { opaqueFlags.pointee.advanced(by: $0) })
            let flags = fsFlags.map { FileSystemEvent.Flags(rawValue: $0) }
            let ids = Array((0..<eventCount).map { opaqueIDs.pointee.advanced(by: $0) })
            guard let events = FileSystemEvent.eventsWith(paths: paths,
                                                          flags: flags,
                                                          ids: ids) else { return }
            
            let observer = unsafeBitCast(clientInfo, to: FileSystemObserver.self)
            observer.handler(events)
        }
        
        directRef = FSEventStreamCreate(kCFAllocatorDefault,
                                        callback,
                                        &context,
                                        paths as CFArray,
                                        FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
                                        1.0,
                                        flags)
        
        FSEventStreamScheduleWithRunLoop(directRef, CFRunLoopGetCurrent(), CFRunLoopMode.commonModes.rawValue)
        FSEventStreamStart(directRef)
    }
    
    
    deinit {
        FSEventStreamStop(directRef)
        FSEventStreamUnscheduleFromRunLoop(directRef, CFRunLoopGetCurrent(), CFRunLoopMode.commonModes.rawValue)
    }
}
