//
//  LinkTextField.m
//  Jitouch
//
//  Copyright 2021 Supasorn Suwajanakorn and Sukolsak Sakshuwong. All rights reserved.
//

#import "LinkTextField.h"

@implementation LinkTextField

- (void)mouseUp:(NSEvent *)event {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[self stringValue]]];
}

- (void)resetCursorRects {
    [self addCursorRect:self.bounds cursor:[NSCursor pointingHandCursor]];
}

@end
