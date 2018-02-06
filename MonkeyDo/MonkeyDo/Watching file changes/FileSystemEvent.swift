//
//  FileSystemEvent.swift
//  MonkeyDo
//
//  Created by Michael L. Ward on 2/5/18.
//  Copyright © 2018 Mikey Ward. All rights reserved.
//

import Foundation
import CoreServices.FSEvents

struct FileSystemEvent: CustomStringConvertible {

    let path: String
    let flags: Flags
    let id: ID
    
    static func eventsWith(paths: [String],
                           flags: [Flags],
                           ids: [ID]) -> [FileSystemEvent]? {
        
        guard paths.count == flags.count && flags.count == ids.count else { return nil }
        
        let inputs = zip(a: paths, b: flags, c: ids)
        let events = inputs.map { (path, flag, id) in
            return FileSystemEvent(path: path, flags: flag, id: id)
        }
        
        return events
    }
    
    var description: String {
        return "<FileSystemEvent at \(path) with flags \(flags.elementDescriptions)>"
    }
}

// MARK: - Embedded Types

extension FileSystemEvent {
    
    typealias ID = UInt64
    
    struct Flags: OptionSet {
        
        let rawValue: UInt32
        
        /*
         * There was some change in the directory at the specific path
         * supplied in this event.
         */
        static let none = Flags(rawValue: 0x00000000)
        
        /*
         * Your application must rescan not just the directory given in the
         * event, but all its children, recursively. This can happen if there
         * was a problem whereby events were coalesced hierarchically. For
         * example, an event in /Users/jsmith/Music and an event in
         * /Users/jsmith/Pictures might be coalesced into an event with this
         * flag set and path=/Users/jsmith. If this flag is set you may be
         * able to get an idea of whether the bottleneck happened in the
         * kernel (less likely) or in your client (more likely) by checking
         * for the presence of the informational flags
         * kFSEventStreamEventFlagUserDropped or
         * kFSEventStreamEventFlagKernelDropped.
         */
        static let mustScanSubDirs = Flags(rawValue: 0x00000001)
        
        /*
         * The kFSEventStreamEventFlagUserDropped or
         * kFSEventStreamEventFlagKernelDropped flags may be set in addition
         * to the kFSEventStreamEventFlagMustScanSubDirs flag to indicate
         * that a problem occurred in buffering the events (the particular
         * flag set indicates where the problem occurred) and that the client
         * must do a full scan of any directories (and their subdirectories,
         * recursively) being monitored by this stream. If you asked to
         * monitor multiple paths with this stream then you will be notified
         * about all of them. Your code need only check for the
         * kFSEventStreamEventFlagMustScanSubDirs flag; these flags (if
         * present) only provide information to help you diagnose the problem.
         */
        static let userDropped = Flags(rawValue: 0x00000002)
        static let kernelDropped = Flags(rawValue: 0x00000004)
        
        /*
         * If kFSEventStreamEventFlagEventIdsWrapped is set, it means the
         * 64-bit event ID counter wrapped around. As a result,
         * previously-issued event ID's are no longer valid arguments for the
         * sinceWhen parameter of the FSEventStreamCreate...() functions.
         */
        static let eventIDsWrapped = Flags(rawValue: 0x00000008)
        
        /*
         * Denotes a sentinel event sent to mark the end of the "historical"
         * events sent as a result of specifying a sinceWhen value in the
         * FSEventStreamCreate...() call that created this event stream. (It
         * will not be sent if kFSEventStreamEventIdSinceNow was passed for
         * sinceWhen.) After invoking the client's callback with all the
         * "historical" events that occurred before now, the client's
         * callback will be invoked with an event where the
         * kFSEventStreamEventFlagHistoryDone flag is set. The client should
         * ignore the path supplied in this callback.
         */
        static let historyDone = Flags(rawValue: 0x00000010)
        
        /*
         * Denotes a special event sent when there is a change to one of the
         * directories along the path to one of the directories you asked to
         * watch. When this flag is set, the event ID is zero and the path
         * corresponds to one of the paths you asked to watch (specifically,
         * the one that changed). The path may no longer exist because it or
         * one of its parents was deleted or renamed. Events with this flag
         * set will only be sent if you passed the flag
         * kFSEventStreamCreateFlagWatchRoot to FSEventStreamCreate...() when
         * you created the stream.
         */
        static let rootChanged = Flags(rawValue: 0x00000020)
        
        /*
         * Denotes a special event sent when a volume is mounted underneath
         * one of the paths being monitored. The path in the event is the
         * path to the newly-mounted volume. You will receive one of these
         * notifications for every volume mount event inside the kernel
         * (independent of DiskArbitration). Beware that a newly-mounted
         * volume could contain an arbitrarily large directory hierarchy.
         * Avoid pitfalls like triggering a recursive scan of a non-local
         * filesystem, which you can detect by checking for the absence of
         * the MNT_LOCAL flag in the f_flags returned by statfs(). Also be
         * aware of the MNT_DONTBROWSE flag that is set for volumes which
         * should not be displayed by user interface elements.
         */
        static let mount = Flags(rawValue: 0x00000040)
        
        /*
         * Denotes a special event sent when a volume is unmounted underneath
         * one of the paths being monitored. The path in the event is the
         * path to the directory from which the volume was unmounted. You
         * will receive one of these notifications for every volume unmount
         * event inside the kernel. This is not a substitute for the
         * notifications provided by the DiskArbitration framework; you only
         * get notified after the unmount has occurred. Beware that
         * unmounting a volume could uncover an arbitrarily large directory
         * hierarchy, although Mac OS X never does that.
         */
        static let unmount = Flags(rawValue: 0x00000080)
        
        /*
         * A file system object was created at the specific path supplied in this event.
         * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        @available(iOS 6.0, OSX 10.7, *) static let created = Flags(rawValue: 0x00000100)
        
        /*
         * A file system object was removed at the specific path supplied in this event.
         * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        @available(iOS 6.0, OSX 10.7, *) static let removed = Flags(rawValue: 0x00000200)
        
        /*
         * A file system object at the specific path supplied in this event had its metadata modified.
         * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        @available(iOS 6.0, OSX 10.7, *) static let metaMod = Flags(rawValue: 0x00000400)
        
        /*
         * A file system object was renamed at the specific path supplied in this event.
         * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        @available(iOS 6.0, OSX 10.7, *) static let renamed = Flags(rawValue: 0x00000800)
        
        /*
         * A file system object at the specific path supplied in this event had its data modified.
         * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        @available(iOS 6.0, OSX 10.7, *) static let modified = Flags(rawValue: 0x00001000)
        
        /*
         * A file system object at the specific path supplied in this event had its FinderInfo data modified.
         * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        @available(iOS 6.0, OSX 10.7, *) static let infoMod = Flags(rawValue: 0x00002000)
        
        /*
         * A file system object at the specific path supplied in this event had its ownership changed.
         * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        @available(iOS 6.0, OSX 10.7, *) static let changeOwner = Flags(rawValue: 0x00004000)
        
        /*
         * A file system object at the specific path supplied in this event had its extended attributes modified.
         * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        @available(iOS 6.0, OSX 10.7, *) static let xattrMod = Flags(rawValue: 0x00008000)
        
        /*
         * The file system object at the specific path supplied in this event is a regular file.
         * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        @available(iOS 6.0, OSX 10.7, *) static let isFile = Flags(rawValue: 0x00010000)
        
        /*
         * The file system object at the specific path supplied in this event is a directory.
         * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        @available(iOS 6.0, OSX 10.7, *) static let isDirectory = Flags(rawValue: 0x00020000)
        
        /*
         * The file system object at the specific path supplied in this event is a symbolic link.
         * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        @available(iOS 6.0, OSX 10.7, *) static let isSymlink = Flags(rawValue: 0x00040000)
        
        /*
         * Indicates the event was triggered by the current process.
         * (This flag is only ever set if you specified the MarkSelf flag when creating the stream.)
         */
        @available(iOS 7.0, OSX 10.9, *) static let ownEvent = Flags(rawValue: 0x00080000)
        
        /*
         * Indicates the object at the specified path supplied in this event is a hard link.
         * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        @available(iOS 9.0, OSX 10.10, *) static let itemIsHardLink = Flags(rawValue: 0x00100000)
        
        /* Indicates the object at the specific path supplied in this event was the last hard link.
         * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        @available(iOS 9.0, OSX 10.10, *) static let itemIsLastHardLink = Flags(rawValue: 0x00200000)
        
        /*
         * The file system object at the specific path supplied in this event is a clone or was cloned.
         * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        @available(iOS 11.0, OSX 10.13, *) static let itemCloned = Flags(rawValue: 0x00400000)
        
        var elementDescriptions: [String] {
            return elements().map { $0.description }
        }
        
        var description: String {
            switch self {
            case Flags.mustScanSubDirs: return "mustScanSubDirs"
            case Flags.userDropped: return "userDropped"
            case Flags.kernelDropped: return "kernelDropped"
            case Flags.eventIDsWrapped: return "eventIDsWrapped"
            case Flags.historyDone: return "historyDone"
            case Flags.rootChanged: return "rootChanged"
            case Flags.mount: return "mount"
            case Flags.unmount: return "unmount"
            case Flags.created: return "created"
            case Flags.removed: return "removed"
            case Flags.metaMod: return "metaMod"
            case Flags.renamed: return "renamed"
            case Flags.modified: return "modified"
            case Flags.infoMod: return "infoMod"
            case Flags.changeOwner: return "changeOwner"
            case Flags.xattrMod: return "xattrMod"
            case Flags.isFile: return "isFile"
            case Flags.isDirectory: return "isDirectory"
            case Flags.isSymlink: return "isSymlink"
            case Flags.ownEvent: return "ownEvent"
            case Flags.itemIsHardLink: return "itemIsHardLink"
            case Flags.itemIsLastHardLink: return "itemIsLastHardLink"
            case Flags.itemCloned: return "itemCloned"
            default: return rawValue.description
            }
        }
    }
}


