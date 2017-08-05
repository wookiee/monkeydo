//
//  FSEventStream+SwiftBridging.m
//  BookBuilder
//
//  Created by Nate Chandler on 2/1/15.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

#import "FSEventStream+SwiftBridging.h"
#import <Foundation/Foundation.h>
#import <CoreServices/CoreServices.h>
#import "BNRFSEvent.h"

void BNRFSEventStreamReceiveCallback(ConstFSEventStreamRef streamRef, void *clientCallBackInfo, size_t numEvents, void *eventPaths, const FSEventStreamEventFlags eventFlags[], const FSEventStreamEventId eventIds[]) {
    NSArray/*BNRFSEvent*/ *events = [BNRFSEvent eventsWithPaths:eventPaths
                                                          flags:eventFlags
                                                    identifiers:eventIds
                                                          count:numEvents];
    id<BNRFSEventStreamCallbackReceiver> callbackReceiver = (__bridge id<BNRFSEventStreamCallbackReceiver>)clientCallBackInfo;
    [callbackReceiver receiveCallbackForEventStream:streamRef
                                             events:events];
}


FSEventStreamRef BNRFSEventStreamCreate(NSArray *paths, id contextObject, NSRunLoop *runLoop) {
    FSEventStreamRef result = NULL;
    
    void *context = (__bridge void *)contextObject;
    FSEventStreamContext callbackCtx = {
        .version = 0,
        .info = context,
        .retain = CFRetain,
        .release = CFRelease,
        .copyDescription = CFCopyDescription
    };
    
    CFArrayRef pathsArray = (__bridge CFArrayRef)paths;
    result = FSEventStreamCreate(kCFAllocatorDefault,
                                 &BNRFSEventStreamReceiveCallback,
                                 &callbackCtx,
                                 pathsArray,
                                 kFSEventStreamEventIdSinceNow,
                                 0.1,
                                 kFSEventStreamCreateFlagWatchRoot | kFSEventStreamCreateFlagFileEvents);
    FSEventStreamScheduleWithRunLoop(result, [runLoop getCFRunLoop], (__bridge CFStringRef)NSRunLoopCommonModes);
    FSEventStreamStart(result);
    return result;
}
