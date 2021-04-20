//
//  GestureView.h
//  Jitouch
//
//  Copyright 2021 Supasorn Suwajanakorn and Sukolsak Sakshuwong. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GestureView : NSView {
    NSMutableArray *points;
    char hintText[20];
}
- (void)setHintText:(const char*)str;
- (void)addPointX:(float)x Y:(float)y;
- (void)addRelativePointX:(float)x Y:(float)y;
- (void)clear;

@end
