//
//  CursorView.h
//  Jitouch
//
//  Copyright 2021 Supasorn Suwajanakorn and Sukolsak Sakshuwong. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CursorView : NSView {
    NSImage *moveImage;
    NSImage *resizeImage;
    NSImage *tabImage;
}

@property (nonatomic, retain) NSImage *moveImage;
@property (nonatomic, retain) NSImage *resizeImage;
@property (nonatomic, retain) NSImage *tabImage;

@end

extern int cursorImageType;
