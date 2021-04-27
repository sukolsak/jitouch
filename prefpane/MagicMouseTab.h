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

#import <Cocoa/Cocoa.h>

@class GesturePreviewView;
@class KeyTextField;
@class GestureTableView;
@class MAAttachedWindow;
@class ApplicationButton;

@interface MagicMouseTab : NSObject {
    NSArray *allGestures;

    //General
    IBOutlet NSMatrix *rdMMHanded;
    IBOutlet NSButton *cbAll;

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
    IBOutlet ApplicationButton *applicationButton;
    IBOutlet GestureTableView *gestureTableView;
    IBOutlet NSPopUpButton *actionButton;
    IBOutlet KeyTextField *shortcutTextField;
    IBOutlet NSButton *commitButton;


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
- (IBAction)cancelCommandSheet:(id)sender;
- (IBAction)commitCommandSheet:(id)sender;
- (IBAction)addCommand:(id)sender;
- (IBAction)removeCommand:(id)sender;
- (IBAction)restoreDefaults:(id)sender;
- (void)enUpdated;
- (void)willUnselect;

@end
