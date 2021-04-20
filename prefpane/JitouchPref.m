//
//  JitouchPref.m
//  Jitouch
//
//  Copyright 2021 Supasorn Suwajanakorn and Sukolsak Sakshuwong. All rights reserved.
//

#import "JitouchPref.h"
#import "KeyTextField.h"
#import "KeyTextView.h"
#import "Settings.h"
#import "TrackpadTab.h"
#import "MagicMouseTab.h"
#import "RecognitionTab.h"
#import <Carbon/Carbon.h>

@implementation JitouchPref

CFMachPortRef eventTap;

- (void)enUpdated {
    [trackpadTab enUpdated];
    [magicMouseTab enUpdated];
    [recognitionTab enUpdated];
    if (enAll) {
        [sdClickSpeed setEnabled:YES];
        [sdSensitivity setEnabled:YES];
    } else {
        [sdClickSpeed setEnabled:NO];
        [sdSensitivity setEnabled:NO];
    }
}

- (IBAction)change:(id)sender {
    if (sender == scAll) {
        int value = (int)[sender selectedSegment];
        enAll = value;
        [Settings setKey:@"enAll" withInt:value];

        [self enUpdated];
    } else if (sender == cbShowIcon) {
        int value = [sender state] == NSOnState ? 1: 0;
        [Settings setKey:@"ShowIcon" withInt:value];
    } else if (sender == sdClickSpeed) {
        clickSpeed = 0.5 - [sender floatValue];
        [Settings setKey:@"ClickSpeed" withFloat:0.5 - [sender floatValue]];
    } else if (sender == sdSensitivity) {
        stvt = [sender floatValue];
        [Settings setKey:@"Sensitivity" withFloat:[sender floatValue]];
    }
    [Settings noteSettingsUpdated];
}

- (id)windowWillReturnFieldEditor:(NSWindow *)sender toObject:(id)anObject {
    if ([anObject isKindOfClass:[KeyTextField class]]) {
        if (!keyTextView) {
            keyTextView = [[KeyTextView alloc] init];
            [keyTextView setFieldEditor:YES];
        }
        return keyTextView;
    }
    return nil;
}

#pragma mark -

- (BOOL)jitouchIsRunning {
    NSArray *apps = [[NSWorkspace sharedWorkspace] runningApplications];
    for (NSRunningApplication *app in apps) {
        if ([app.bundleIdentifier isEqualToString:@"com.jitouch.Jitouch"])
            return YES;
    }
    return NO;
}

- (void)settingsUpdated:(NSNotification *)aNotification {
    NSDictionary *d = [aNotification userInfo];
    [Settings readSettings2:d];

    [scAll setSelectedSegment:enAll];
    [self enUpdated];
}


- (void)killAllJitouchs {
    NSString *script = @"killall Jitouch";
    NSArray *shArgs = [NSArray arrayWithObjects:@"-c", script, @"", nil];
    [NSTask launchedTaskWithLaunchPath:@"/bin/sh" arguments:shArgs];
}


static CGEventRef CGEventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon) {
    if ([NSApp isActive] && [[[NSApp keyWindow] firstResponder] isKindOfClass:[KeyTextView class]]) {
        if (type == kCGEventKeyDown) {
            int64_t keyCode = CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);
            CGEventFlags flags = CGEventGetFlags(event);
            [(KeyTextView*)[[NSApp keyWindow] firstResponder] handleEventKeyCode:keyCode flags:flags];
            return NULL;
        } else if (type == kCGEventKeyUp) {
            return NULL;
        }
    }
    return event;
}


- (void)addJitouchToLoginItems{
    NSString *jitouchPath = [NSString stringWithFormat:@"file://%@", [[self bundle] pathForResource:@"Jitouch" ofType:@"app"]];
    NSURL *jitouchURL = [NSURL URLWithString:jitouchPath];

    LSSharedFileListRef loginListRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    if (loginListRef) {
        // delete all shortcuts to jitouch in the login items
        UInt32 seedValue;
        NSArray  *loginItemsArray = (NSArray *)LSSharedFileListCopySnapshot(loginListRef, &seedValue);
        for (id item in loginItemsArray) {
            LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)item;
            CFURLRef thePath;
            if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &thePath, NULL) == noErr) {
                NSRange range = [[(NSURL*)thePath path] rangeOfString:@"Jitouch"];
                if (range.location != NSNotFound)
                    LSSharedFileListItemRemove(loginListRef, itemRef);
            }
        }
        [loginItemsArray release];


        if (![settings objectForKey:@"StartAtLogin"] || [[settings objectForKey:@"StartAtLogin"] intValue]) {
            // add shortcut to jitouch in the login items (there should be only one shortcut)
            LSSharedFileListItemRef loginItemRef = LSSharedFileListInsertItemURL(loginListRef,  kLSSharedFileListItemLast, NULL,  NULL, (CFURLRef)jitouchURL, NULL, NULL);

            if (loginItemRef) {
                CFRelease(loginItemRef);
            }
        }

        CFRelease(loginListRef);
    }
}

- (void)mainViewDidLoad {
    isPrefPane = YES;
    [Settings loadSettings:self];

    [scAll setSelectedSegment:enAll];
    [cbShowIcon setState:[[settings objectForKey:@"ShowIcon"] intValue]];
    [sdClickSpeed setFloatValue:0.5-clickSpeed];
    [sdSensitivity setFloatValue:stvt];

    [self enUpdated];

    [[NSDistributedNotificationCenter defaultCenter] addObserver: self
                                                        selector: @selector(settingsUpdated:)
                                                            name: @"My Notification2"
                                                          object: @"com.jitouch.Jitouch.PrefpaneTarget2"];


    BOOL running = [self jitouchIsRunning];
    if (running && hasPreviousVersion) {
        [self killAllJitouchs];
        running = NO;
    }
    [self addJitouchToLoginItems];
    //if (!running) {
        NSString *pathToJitouchInBundle = [[self bundle] pathForResource:@"Jitouch" ofType:@"app"];
        [[NSWorkspace sharedWorkspace] openFile:pathToJitouchInBundle];
    //}


    NSInteger tabIndex;
    if ([settings objectForKey:@"LastTab"] && (tabIndex=[mainTabView indexOfTabViewItemWithIdentifier:[settings objectForKey:@"LastTab"]]) != NSNotFound) {
        [mainTabView selectTabViewItemAtIndex:tabIndex];
    } else {
        CFMutableDictionaryRef matchingDict = IOServiceNameMatching("AppleUSBMultitouchDriver");
        io_registry_entry_t service = (io_registry_entry_t)IOServiceGetMatchingService(kIOMasterPortDefault, matchingDict);
        if (service) {
            [mainTabView selectTabViewItemWithIdentifier:@"Trackpad"];
        } else {
            [mainTabView selectTabViewItemWithIdentifier:@"Magic Mouse"];
        }
    }

    mainView = [self mainView];

}

- (void)willSelect {
    BOOL trusted = AXIsProcessTrustedWithOptions((CFDictionaryRef)@{(id)kAXTrustedCheckOptionPrompt: @(YES)});

    if (trusted && !eventKeyboard) {
        CGEventMask eventMask = CGEventMaskBit(kCGEventKeyDown) | CGEventMaskBit(kCGEventKeyUp);
        eventKeyboard = CGEventTapCreate(kCGSessionEventTap, kCGHeadInsertEventTap, 0, eventMask, CGEventCallback, NULL);

        CGEventTapEnable(eventKeyboard, false);
        CFRunLoopSourceRef runLoopSource = CFMachPortCreateRunLoopSource( kCFAllocatorDefault, eventKeyboard, 0);
        CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, kCFRunLoopCommonModes);
    }
}

- (void)willUnselect {
    [trackpadTab willUnselect];
    [magicMouseTab willUnselect];
    [recognitionTab willUnselect];
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem {
    [Settings setKey:@"LastTab" with:[tabViewItem identifier]];
    [settings setObject:[tabViewItem identifier] forKey:@"LastTab"];
}

@end
