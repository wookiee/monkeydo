//
//  FileObserver.swift
//  MonkeyDo
//
//  Created by Michael L. Ward on 8/17/17.
//  Copyright © 2017 Mikey Ward. All rights reserved.
//

import Foundation
import CoreServices.FSEvents

protocol FileObserverDelegate: class {
    func fileObserver(_ bdo: FileObserver, didObserveFileSystemEvents events: [BNRFSEvent])
}

class FileObserver {
    
    let eventStream: FSEventStreamRef
    let callbackReceiver = EventStreamCallbackReceiver()
    weak var delegate: FileObserverDelegate?
    
    init(file: URL) {
        eventStream = BNRFSEventStreamCreate([file.path], callbackReceiver, RunLoop.main)
        self.callbackReceiver.enclosingObserver = self
    }
    
    // This class allows us to avoid making FileObserver subclass NSObject.
    class EventStreamCallbackReceiver: NSObject, BNRFSEventStreamCallbackReceiver {
        func receiveCallback(for streamRef: ConstFSEventStreamRef!, events: [Any]!) {
            if let events = events as? [BNRFSEvent],
                let enclosingObserver = self.enclosingObserver {
                enclosingObserver.receiveCallbackForEventStream(streamRef, events: events)
            } else {
                fatalError("EventStreamCallbackReceiver received callback with array that can't be cast to [BNRFSEvent].")
            }
        }
        
        weak var enclosingObserver: FileObserver?
    }
    
    func receiveCallbackForEventStream(_ streamRef: ConstFSEventStreamRef, events: [BNRFSEvent]) {
        delegate?.fileObserver(self, didObserveFileSystemEvents: events)
    }
}
