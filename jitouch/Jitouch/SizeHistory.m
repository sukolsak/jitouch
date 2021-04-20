//
//  SizeHistory.m
//  Jitouch
//
//  Copyright 2021 Supasorn Suwajanakorn and Sukolsak Sakshuwong. All rights reserved.
//

#import "SizeHistory.h"

@implementation SizeHistory

@synthesize curRect;
@synthesize savRect;

- (id)initWithCurRect:(NSRect)a SaveRect:(NSRect) b {
    if (self = [super init]) {
        curRect = a;
        savRect = b;
    }
    return self;
}
@end


@implementation SizeHistoryKey

- (id)initWithKey:(CFTypeRef)a {
    if (self = [super init]) {
        [self setWindowRef:a];
    }
    return self;
}
- (void)setWindowRef:(CFTypeRef) a {
    windowRef = a;
    CFRetain(windowRef);
}
- (id) copyWithZone:(NSZone *)zone {
    SizeHistoryKey* copy = [[self class] alloc];
    [copy setWindowRef:windowRef];
    return copy;
}
- (void) dealloc {
    CFRelease(windowRef);
    [super dealloc];
}
- (BOOL) isEqual:(id)other {
    return CFEqual(windowRef, other);
}

- (NSUInteger) hash {
    return CFHash(windowRef);;
}
@end
