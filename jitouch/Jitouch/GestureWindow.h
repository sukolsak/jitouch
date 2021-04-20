//
//  GestureWindow.h
//  Jitouch
//
//  Copyright 2021 Supasorn Suwajanakorn and Sukolsak Sakshuwong. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GestureView;

@interface GestureWindow : NSWindow {
    GestureView *gestureView;
    NSTextField *tf;
}
- (void)setHintText:(const char*)str;
- (void)addPointX:(float)x Y:(float)y;
- (void)addRelativePointX:(float)x Y:(float)y;
- (void)clear;
- (void)refresh;
- (void)setPossibleAlphabet:(NSString*)a;
- (void)setUpWindowForTrackpad;
- (void)setUpWindowForMagicMouse;
@end
