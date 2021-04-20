//
//  KeyTextView.h
//  Jitouch
//
//  Copyright 2021 Supasorn Suwajanakorn and Sukolsak Sakshuwong. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface KeyTextView : NSTextView

- (void)handleEventKeyCode:(int64_t)keyCode flags:(CGEventFlags)flags;

@end
