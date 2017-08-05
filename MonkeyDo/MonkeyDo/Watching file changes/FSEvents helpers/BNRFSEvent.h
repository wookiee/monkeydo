//
//  BNRFSEventStream.h
//  BookBuilder
//
//  Created by Nate Chandler on 2/1/15.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BNRFSEvent : NSObject

@property (nonatomic, readonly) NSString *path;
@property (nonatomic, readonly) FSEventStreamEventFlags flags;
@property (nonatomic, readonly) FSEventStreamEventId identifier;

- (instancetype)initWithPath:(NSString *)path
                       flags:(FSEventStreamEventFlags)flags
                  identifier:(FSEventStreamEventId)identifier;

+ (NSArray/*BNRFSEventStream*/ *)eventsWithPaths:(void *)paths
                                           flags:(const FSEventStreamEventFlags[])eventFlags
                                     identifiers:(const FSEventStreamEventId[])eventIds
                                           count:(size_t)count;

@end
