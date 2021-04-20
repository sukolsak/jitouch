//
//  CursorWindow.m
//  Jitouch
//
//  Copyright 2021 Supasorn Suwajanakorn and Sukolsak Sakshuwong. All rights reserved.
//

#import "CursorWindow.h"
#import "CursorView.h"

@implementation CursorWindow

- (id)init {
    self = [super initWithContentRect:NSMakeRect(0.0, 0.0, 100.0, 100.0) styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    if (self != nil) {
        self.alphaValue = 1.0;
        self.opaque = NO;
        self.backgroundColor = [NSColor clearColor];

        cursorView = [[CursorView alloc] initWithFrame:[self frame]];
        [self setContentView:cursorView];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
}

@end
