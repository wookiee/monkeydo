//
//  BNRFSEventStream.m
//  BookBuilder
//
//  Created by Nate Chandler on 2/1/15.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

#import "BNRFSEvent.h"

@implementation BNRFSEvent

// Factory Methods

+ (NSArray/*BNRFSEventStream*/ *)eventsWithPaths:(void *)pPaths
                                           flags:(const FSEventStreamEventFlags[])eventFlags
                                     identifiers:(const FSEventStreamEventId[])eventIds
                                           count:(size_t)count {
    NSMutableArray *mutableResult = [[NSMutableArray alloc] init];
    
    const char **ppPaths = (const char **)pPaths;
    for (size_t index = 0; index < count; index++) {
        const char *pPath = ppPaths[index];
        NSString *path = [[NSString alloc] initWithUTF8String:pPath];
        FSEventStreamEventFlags flags = eventFlags[index];
        FSEventStreamEventId identifier = eventIds[index];
        BNRFSEvent *event = [[BNRFSEvent alloc] initWithPath:path
                                                       flags:flags
                                                  identifier:identifier];
        [mutableResult addObject:event];
    }
    
    return [mutableResult copy];
}

// Lifecycle

- (instancetype)initWithPath:(NSString *)path
                       flags:(FSEventStreamEventFlags)flags
                  identifier:(FSEventStreamEventId)identifier {
    self = [super init];
    if (self) {
        _path = path;
        _flags = flags;
        _identifier = identifier;
    }
    return self;
}

@end
