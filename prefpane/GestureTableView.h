//
//  GestureTableView.h
//  Jitouch
//
//  Copyright 2021 Supasorn Suwajanakorn and Sukolsak Sakshuwong. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MAAttachedWindow, GesturePreviewView;

@interface GestureTableView : NSTableView <NSTableViewDataSource> {
    NSArray *gestures;
    int device;
    NSSize size;

    MAAttachedWindow *attachedWindow;
    NSView *realView;
    GesturePreviewView *gesturePreviewView;

    NSInteger saveRowIndex;
}

- (NSString*)titleOfSelectedItem;
- (void)selectItemWithObjectValue:(NSString*)value;
- (void)hidePreview;
- (void)willUnselect;

@property (nonatomic, retain) NSArray *gestures;
@property (nonatomic) NSSize size;
@property (nonatomic) int device;

@end
