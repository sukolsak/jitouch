//
//  CursorView.m
//  Jitouch
//
//  Copyright 2021 Supasorn Suwajanakorn and Sukolsak Sakshuwong. All rights reserved.
//

#import "CursorView.h"

int cursorImageType;

@implementation CursorView

@synthesize moveImage;
@synthesize resizeImage;
@synthesize tabImage;

- (id)initWithFrame:(NSRect)frameRect{
    if (self = [super initWithFrame:frameRect]) {
        self.moveImage = [NSImage imageNamed:@"move"];
        self.resizeImage = [NSImage imageNamed:@"resize"];
        self.tabImage = [NSImage imageNamed:@"tab"];
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
    [[NSColor clearColor] set];
    NSRectFill(self.frame);
    NSImage *image = nil;
    if (cursorImageType == 0) {
        image = moveImage;
    } else if (cursorImageType == 1) {
        image = resizeImage;
    } else if (cursorImageType == 2) {
        image = tabImage;
    }
    [image drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    [[self window] setHasShadow:NO];
}

- (void)dealloc {
    [moveImage release];
    [resizeImage release];
    [tabImage release];
    [super dealloc];
}

@end
