/*
 * This file is part of Jitouch.
 *
 * Copyright 2021 Sukolsak Sakshuwong
 * Copyright 2021 Supasorn Suwajanakorn
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Jitouch is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version.
 *
 * Jitouch is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * Jitouch. If not, see <https://www.gnu.org/licenses/>.
 */

#import "JitouchAppDelegate.h"
#import "Settings.h"
#import "Gesture.h"
#import "CursorWindow.h"
#import <Carbon/Carbon.h>
#import <CoreFoundation/CFPreferences.h>
#import "SystemPreferences.h"

CursorWindow *cursorWindow;
CGKeyCode keyMap[128]; // for dvorak support

@implementation JitouchAppDelegate

@synthesize window;

- (void)addJitouchToLoginItems{
    NSString *jitouchPath = [[NSString stringWithFormat:@"file://%@",[[NSBundle mainBundle] bundlePath]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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

- (void)removeJitouchFromLoginItems{
    LSSharedFileListRef loginListRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    if (loginListRef) {
        // delete all shortcuts to jitouch in the login items
        UInt32 seedValue;
        NSArray *loginItemsArray = (NSArray *)LSSharedFileListCopySnapshot(loginListRef, &seedValue);
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
        CFRelease(loginListRef);
    }
}

#pragma mark - Menu

- (BOOL)validateMenuItem:(NSMenuItem *)item {
    if ([item action] == @selector(switchChange:))
        return NO;
    return YES;
}

- (void)showIcon {
    theMenu = [[[NSMenu alloc] initWithTitle:@"Contextual Menu"] autorelease];

    if (enAll)
        [theMenu insertItemWithTitle:@"Turn Jitouch Off" action:@selector(switchChange:) keyEquivalent:@"" atIndex:0];
    else
        [theMenu insertItemWithTitle:@"Turn Jitouch On" action:@selector(switchChange:) keyEquivalent:@"" atIndex:0];

    //[theMenu insertItem:[NSMenuItem separatorItem] atIndex:1];
    [theMenu insertItemWithTitle:@"Open Preferences..." action:@selector(preferences:) keyEquivalent:@"" atIndex:1];
    [theMenu insertItem:[NSMenuItem separatorItem] atIndex:2];
    [theMenu insertItemWithTitle:@"Quit Jitouch" action:@selector(quit:) keyEquivalent:@"" atIndex:3];

    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    theItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    [theItem retain];
    [self updateIconImage];
    [theItem setHighlightMode:YES];
    [theItem setMenu:theMenu];
}

- (void)hideIcon {
    [[NSStatusBar systemStatusBar] removeStatusItem:theItem];
    [theItem release];
    theItem = nil;
}

- (void)updateIconImage {
    if (enAll) {
        NSImage *img = [NSImage imageNamed:@"logosmall"];
        [img setTemplate:YES];
        [theItem setImage:img];
    } else {
        NSImage *img = [NSImage imageNamed:@"logosmalloff"];
        [img setTemplate:YES];
        [theItem setImage:img];
    }
}

- (void)preferences:(id)sender  {
    NSString *prefPath = [@"~/Library/PreferencePanes/Jitouch.prefPane" stringByExpandingTildeInPath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:prefPath]) {
        prefPath = @"/Library/PreferencePanes/Jitouch.prefPane";
    }

    if ([[NSFileManager defaultManager] fileExistsAtPath:prefPath]) {
        [[NSWorkspace sharedWorkspace] openFile:prefPath];
    } else {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Can't find the jitouch preference panel."];
        [alert setInformativeText:@"Please reinstall jitouch."];
        [alert setAlertStyle:NSWarningAlertStyle];
        [NSApp activateIgnoringOtherApps:YES];
        [alert runModal];
        [alert release];
    }
}


- (void)quit:(id)sender {
    // Remove from login item
    [self removeJitouchFromLoginItems];

    // Quit
    [NSApp terminate: sender];
}

- (void)refreshMenu {
    if (theItem == nil && [[settings objectForKey:@"ShowIcon"] intValue] == 1){
        [self showIcon];
    } else if (theItem != nil && [[settings objectForKey:@"ShowIcon"] intValue] == 0){
        [self hideIcon];
    }
    if (theItem) {
        if (enAll) {
            [[theMenu itemAtIndex:0] setTitle:@"Turn Jitouch Off"];
        } else {
            [[theMenu itemAtIndex:0] setTitle:@"Turn Jitouch On"];
        }
        [self updateIconImage];
    }
}

- (void)switchChange:(id)sender {
    enAll = !enAll;
    [self refreshMenu];
    [self saveSettings];

    if (!enAll)
        turnOffGestures();
}

#pragma mark - Settings

- (void)saveSettings {
    [Settings setKey:@"enAll" withInt:enAll];
    [Settings noteSettingsUpdated2];
}

- (void)settingsUpdated:(NSNotification *)aNotification {
    //[Settings loadSettings];

    [Settings loadSettings2:aNotification.userInfo]; // fixes bug in mountain lion
    [self refreshMenu];

    if (!enAll)
        turnOffGestures();
}

#pragma mark - Initialization


- (void)checkAXAPI {
    AXIsProcessTrustedWithOptions((CFDictionaryRef)@{(id)kAXTrustedCheckOptionPrompt: @(YES)});
}

/*
void languageChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    for (int i = 0; i < 128; i++)
        keyMap[i] = (CGKeyCode)i;
    NSString *inputSource = (NSString*)TISGetInputSourceProperty(TISCopyCurrentKeyboardInputSource(), kTISPropertyLocalizedName);
    if ([inputSource isEqualToString:@"Dvorak"] || [inputSource isEqualToString:@"Svorak"]) {
        keyMap[13] = 43; //w -> ,
        keyMap[12] = 7;  //q -> x
        keyMap[17] = 40; //t -> k
        keyMap[4] = 38;  //h -> j
        keyMap[15] = 31; //r -> o
        keyMap[45] = 37; //n -> l
        keyMap[8] = 34; //c -> i
        keyMap[9] = 47; //v -> >
        keyMap[31] = 1; //o ->
        keyMap[37] = 45; //l -> n
        keyMap[3] = 32; // f -> u
        keyMap[40] = 17;
    } else if ([inputSource isEqualToString:@"French"]) {
        keyMap[13] = 6;  //w -> z
        keyMap[12] = 0;  //q -> a
    }
}
*/

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [Settings loadSettings];

    [self refreshMenu];

    // Move this task to prefpane instead. Starting at Sierra
    //[self addJitouchToLoginItems];

    cursorWindow = [[CursorWindow alloc] init];

    //languageChanged(NULL, NULL, NULL, NULL, NULL);

    gesture = [[Gesture alloc] init];

    //[self showIcon];

    [self checkAXAPI];

    [[NSDistributedNotificationCenter defaultCenter] addObserver: self
                                                        selector: @selector(settingsUpdated:)
                                                            name: @"My Notification"
                                                          object: @"com.jitouch.Jitouch.PrefpaneTarget"];

    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(wokeUp:) name:NSWorkspaceDidWakeNotification object: NULL];

    //CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(), self, languageChanged, kTISNotifySelectedKeyboardInputSourceChanged, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}

- (void)wokeUp:(NSNotification *)aNotification {
    //restart outselves
    NSString *killArg1AndOpenArg2Script = @"kill -9 $1 \n open \"$2\"";

    //NSTask needs its arguments to be strings
    NSString *ourPID = [NSString stringWithFormat:@"%d",
                        [[NSProcessInfo processInfo] processIdentifier]];

    //this will be the path to the .app bundle,
    //not the executable inside it; exactly what `open` wants
    NSString * pathToUs = [[NSBundle mainBundle] bundlePath];

    NSArray *shArgs = [NSArray arrayWithObjects:@"-c", // -c tells sh to execute the next argument, passing it the remaining arguments.
                       killArg1AndOpenArg2Script,
                       @"", //$0 path to script (ignored)
                       ourPID, //$1 in restartScript
                       pathToUs, //$2 in the restartScript
                       nil];
    NSTask *restartTask = [NSTask launchedTaskWithLaunchPath:@"/bin/sh" arguments:shArgs];
    [restartTask waitUntilExit]; //wait for killArg1AndOpenArg2Script to finish
}

#pragma mark -

- (void) dealloc {
    [cursorWindow release];
    [super dealloc];
}

@end
