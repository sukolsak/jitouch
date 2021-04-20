/*
 File: ImageAndTextCell.h
 Abstract: Subclass of NSTextFieldCell which can display text and an image simultaneously.

 Copyright (C) 2009 Apple Inc. All Rights Reserved.
 */

#import <Cocoa/Cocoa.h>

@interface ImageAndTextCell : NSTextFieldCell {
@private
    NSImage *image;
}

@property(readwrite, retain) NSImage *image;

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
- (NSSize)cellSize;

@end
