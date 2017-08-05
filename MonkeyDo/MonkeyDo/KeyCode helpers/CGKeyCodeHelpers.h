//
//  CGKeyCodeHelpers.h
//  MonkeyDo
//
//  Created by Michael L. Ward on 8/4/17.
//  Copyright © 2017 Mikey Ward. All rights reserved.
//

#ifndef CGKeyCodeHelpers_h
#define CGKeyCodeHelpers_h

#include <CoreGraphics/CoreGraphics.h>
CFStringRef createStringForKey(CGKeyCode keyCode);
CGKeyCode keyCodeForChar(const char c);


#endif /* CGKeyCodeHelpers_h */


