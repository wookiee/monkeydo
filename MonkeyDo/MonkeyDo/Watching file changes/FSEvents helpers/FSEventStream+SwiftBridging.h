//
//  FSEventStream+SwiftBridging.h
//  BookBuilder
//
//  Created by Nate Chandler on 2/1/15.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreServices/CoreServices.h>

@protocol BNRFSEventStreamCallbackReceiver <NSObject>
- (void)receiveCallbackForEventStream:(ConstFSEventStreamRef)streamRef
                               events:(NSArray *)events;
@end

FSEventStreamRef BNRFSEventStreamCreate(NSArray *paths, id contextObject, NSRunLoop *runLoop);
