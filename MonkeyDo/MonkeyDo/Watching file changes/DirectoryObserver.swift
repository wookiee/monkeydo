//
//  FileSystemObserver.swift
//  BookBuilder
//
//  Created by Nate Chandler on 2/1/15.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

import Foundation
import CoreServices.FSEvents

protocol DirectoryObserverDelegate: class {
    func directoryObserver(_ bdo: DirectoryObserver, didObserveFileSystemEvents events: [BNRFSEvent])
}

class DirectoryObserver {
    
    let eventStream: FSEventStreamRef
    let callbackReceiver = EventStreamCallbackReceiver()
    weak var delegate: DirectoryObserverDelegate?
    
    init(directory: URL) {
        eventStream = BNRFSEventStreamCreate([directory.path], callbackReceiver, RunLoop.main)
        self.callbackReceiver.enclosingObserver = self
    }

    // This class allows us to avoid making DirectoryObserver subclass NSObject.
    class EventStreamCallbackReceiver: NSObject, BNRFSEventStreamCallbackReceiver {
        func receiveCallback(for streamRef: ConstFSEventStreamRef!, events: [Any]!) {
            if let events = events as? [BNRFSEvent],
                let enclosingObserver = self.enclosingObserver {
                enclosingObserver.receiveCallbackForEventStream(streamRef, events: events)
            } else {
                fatalError("EventStreamCallbackReceiver received callback with array that can't be cast to [BNRFSEvent].")
            }
        }

        weak var enclosingObserver: DirectoryObserver?
    }

    func receiveCallbackForEventStream(_ streamRef: ConstFSEventStreamRef, events: [BNRFSEvent]) {
        delegate?.directoryObserver(self, didObserveFileSystemEvents: events)
    }
}


extension BNRFSEvent {
    open override var description: String {
        return "<BNRFSEvent: \(flags) @ \(path)>"
    }
}
