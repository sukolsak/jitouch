//
//  RecognitionTab.h
//  Jitouch
//
//  Copyright 2021 Supasorn Suwajanakorn and Sukolsak Sakshuwong. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GesturePreviewView;
@class KeyTextField;
@class GestureTableView;
@class MAAttachedWindow;
@class ApplicationButton;

@interface RecognitionTab : NSObject {
    NSArray *allGestures;

    //General
    IBOutlet NSButton *cbTrackpad;
    IBOutlet NSButton *cbMouse;

    IBOutlet NSOutlineView *commandOutlineView;
    IBOutlet NSButton *addButton;
    IBOutlet NSButton *removeButton;
    IBOutlet NSButton *restoreDefaultsButton;

    IBOutlet NSWindow *window;
    IBOutlet NSWindow *commandSheet;
    IBOutlet NSWindow *urlWindow;
    IBOutlet NSButton *urlWindowOk;
    IBOutlet NSButton *urlWindowCancel;
    IBOutlet NSTextField *urlWindowUrl;
    IBOutlet NSWindow *advancedSheet;
    IBOutlet ApplicationButton *applicationButton;
    IBOutlet GestureTableView *gestureTableView;
    IBOutlet NSPopUpButton *actionButton;
    IBOutlet KeyTextField *shortcutTextField;
    IBOutlet NSButton *commitButton;

    IBOutlet NSButton *oneDrawing;
    IBOutlet NSButton *twoDrawing;

    IBOutlet NSMatrix *mouseButton;
    IBOutlet NSSlider *indexRing;

    BOOL addsCommand;
    NSDictionary *oldItem;
    NSInteger oldItemIndex;
    NSString *saveApplication;

    NSView *realView;
    MAAttachedWindow *attachedWindow;
    NSInteger saveRowIndex;
    GesturePreviewView *gesturePreviewView;

    NSString *openFilePath;
    NSString *openURL;
}

- (IBAction)change:(id)sender;
- (IBAction)showAdvancedSheet:(id)sender;
- (IBAction)cancelCommandSheet:(id)sender;
- (IBAction)commitCommandSheet:(id)sender;
- (IBAction)addCommand:(id)sender;
- (IBAction)removeCommand:(id)sender;
- (IBAction)restoreDefaults:(id)sender;
- (void)enUpdated;
- (void)willUnselect;

@end
