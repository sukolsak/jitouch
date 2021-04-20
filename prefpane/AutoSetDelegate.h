//
//  AutoSetDelegate.h
//  Jitouch
//
//  Copyright 2021 Supasorn Suwajanakorn and Sukolsak Sakshuwong. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AutoSetDelegate : NSObject {
    IBOutlet NSWindow *advancedWindow;
    IBOutlet NSWindow *autoSetWindow;

    IBOutlet NSTextField *fingersName;
    IBOutlet NSTextField *counter;

    IBOutlet NSButton *oneDrawing;
    IBOutlet NSButton *twoDrawing;

    IBOutlet NSButton *autoSetButton;
    IBOutlet NSButton *cancelButton;
    IBOutlet NSButton *restartButton;
    IBOutlet NSButton *resetButton;

    IBOutlet NSMatrix *mouseButton;
    IBOutlet NSSlider *indexRing;
}

- (IBAction)done:(id)sender;
- (IBAction)doneAutoSet:(id)sender;
- (IBAction)change:(id)sender;

@end
