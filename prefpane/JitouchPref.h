//
//  JitouchPref.h
//  Jitouch
//
//  Copyright 2021 Supasorn Suwajanakorn and Sukolsak Sakshuwong. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>

@class KeyTextView;
@class Update;

@interface JitouchPref : NSPreferencePane {
    NSWindow *window;

    IBOutlet NSSlider *sdClickSpeed;
    IBOutlet NSSlider *sdSensitivity;
    IBOutlet NSSegmentedControl *scAll;
    IBOutlet NSButton *cbShowIcon;
    IBOutlet NSTabView *mainTabView;
    IBOutlet NSScrollView *scrollView;

    KeyTextView *keyTextView;
}

- (IBAction)change:(id)sender;
- (void) mainViewDidLoad;

@end
