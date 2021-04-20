//
//  GestureWindow.m
//  Jitouch
//
//  Copyright 2021 Supasorn Suwajanakorn and Sukolsak Sakshuwong. All rights reserved.
//

#import "GestureWindow.h"
#import "GestureView.h"

@implementation GestureWindow

static float trackpadWidth = 400 + 150;
static float trackpadHeight = 300 + 100;

static float magicMouseWidth = 800;
static float magicMouseHeight = 800;

- (id)init {
    NSSize size = [[NSScreen mainScreen] frame].size;
    self = [super initWithContentRect:NSMakeRect(size.width/2 - trackpadWidth/2, size.height/2 - trackpadHeight/2, trackpadWidth, trackpadHeight) styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    if (self != nil) {
        self.alphaValue = 1.0;
        self.opaque = NO;
        self.backgroundColor = [NSColor clearColor];

        gestureView = [[GestureView alloc] initWithFrame:[self frame]];
        [self setContentView:gestureView];
    }
    return self;
}
- (void)setUpWindowForTrackpad {
    NSArray *arr = [NSScreen screens];
    CGEventRef ourEvent = CGEventCreate(NULL);
    CGPoint location = CGEventGetUnflippedLocation(ourEvent);
    CFRelease(ourEvent);

    NSRect scr;
    NSPoint orig;
    NSSize size;
    int isIn = 0;
    for (int i = 0; i<[arr count]; i++) {
        scr = [[arr objectAtIndex:i] frame];
        orig = scr.origin;
        size = scr.size;

        if (location.x >= orig.x && location.x <= orig.x + size.width &&
           location.y >= orig.y && location.y <= orig.y + size.height) {
            isIn = i;
            break;
        }
    }
    scr = [[arr objectAtIndex:isIn] frame];
    orig = scr.origin;
    size = scr.size;
    [self setFrame:NSMakeRect(orig.x+size.width/2 - trackpadWidth/2, orig.y+size.height/2 - trackpadHeight/2, trackpadWidth, trackpadHeight) display:YES];
}
- (void)setUpWindowForMagicMouse {
    CGEventRef ourEvent = CGEventCreate(NULL);
    CGPoint ourLoc = CGEventGetUnflippedLocation(ourEvent);
    CFRelease(ourEvent);
    [self setFrame:NSMakeRect(ourLoc.x - magicMouseWidth/2, ourLoc.y - magicMouseHeight/2, magicMouseWidth, magicMouseHeight) display:YES];

}
- (void)setPossibleAlphabet:(NSString*)a {
    [tf setStringValue:a];
}

- (void)drawRect:(NSRect)dirtyRect {
}

- (void)addPointX:(float)x Y:(float)y {
    [gestureView addPointX:x Y:y];
}
- (void)addRelativePointX:(float)x Y:(float)y {
    [gestureView addRelativePointX:x Y:y];
}
- (void)clear {
    [gestureView clear];
}

- (void)refresh {
    [gestureView setNeedsDisplay:YES];
}
- (void)setHintText:(const char*)str {
    [gestureView setHintText:str];
    [self refresh];
}

- (void)dealloc {
    [tf release];
    [super dealloc];
}

@end
