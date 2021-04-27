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

#import "RecognitionTab.h"
#import "Settings.h"
#import "GesturePreviewView.h"
#import "GestureTableView.h"
#import "KeyTextField.h"
#import "ImageAndTextCell.h"
#import "MAAttachedWindow.h"
#import "ApplicationButton.h"


@implementation RecognitionTab

- (void)enUpdated {
    if (enAll) {
        [cbTrackpad setEnabled:YES];
        [cbMouse setEnabled:YES];
    } else {
        [cbTrackpad setEnabled:NO];
        [cbMouse setEnabled:NO];
    }
    if (enAll && (enCharRegTP || enCharRegMM)) {
        [commandOutlineView setEnabled:YES];
        [addButton setEnabled:YES];
        if ([commandOutlineView selectedRow] != -1) {
            [removeButton setEnabled:YES];
        } else {
            [removeButton setEnabled:NO];
        }
        [restoreDefaultsButton setEnabled:YES];
    } else {
        [commandOutlineView setEnabled:NO];
        [addButton setEnabled:NO];
        [removeButton setEnabled:NO];
        [restoreDefaultsButton setEnabled:NO];
    }
}

- (void)awakeFromNib {
    recognitionTab = self;
    isPrefPane = YES;
    [Settings loadSettings:self];

    allGestures = [[NSArray alloc] initWithObjects:
                   @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z",
                   @"Up", @"Down",
                   @"Left", @"Right",
                   @"Left-Right", @"Right-Left",
                   @"Up-Left", @"Up-Right",
                   @"Left-Up", @"Right-Up",
                   @"/ Up", @"/ Down",
                   @"\\ Up", @"\\ Down",
                   @"All Unassigned Gestures",
                   nil];


    [cbTrackpad setState: enCharRegTP];
    [cbMouse setState: enCharRegMM];

    [self enUpdated];

    [commandOutlineView reloadData];
    [commandOutlineView tableColumnWithIdentifier:@"Enable"].minWidth = 20.0;
    [commandOutlineView tableColumnWithIdentifier:@"Enable"].width = 20.0;
    [commandOutlineView expandItem:nil expandChildren:YES];


    saveRowIndex = -1;
    realView = [commandOutlineView enclosingScrollView];

    NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:realView.bounds
                                                                options:(NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveAlways)
                                                                  owner:self userInfo:nil];
    [realView addTrackingArea:trackingArea];
    [trackingArea release];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector: @selector(outlineViewScrolled:)
                                                 name: NSViewBoundsDidChangeNotification
                                               object: [[commandOutlineView enclosingScrollView] contentView]];
}

- (void)hidePreview {
    window = [mainView window];
    if (attachedWindow) {
        [gesturePreviewView stopTimer];
        gesturePreviewView = nil;
        NSWindow *localAttachedWindow = attachedWindow;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            float alpha = 1.0;
            for (int i = 0; i < 10; i++) {
                alpha -= 0.1;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [localAttachedWindow setAlphaValue:alpha];
                });
                usleep(20 * 1000);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [window removeChildWindow:localAttachedWindow];
                [localAttachedWindow orderOut:self];
                [localAttachedWindow release];
            });
        });
        attachedWindow = nil;
    }
    saveRowIndex = -1;
}

- (void)showPreview:(BOOL)scroll {
    window = [mainView window];
    NSInteger rowIndex;

    NSPoint point = [commandOutlineView convertPoint:[window mouseLocationOutsideOfEventStream] fromView:[window contentView]];

    if ([commandOutlineView columnAtPoint:point] != 1) {
        [self hidePreview];
        return;
    }

    rowIndex = [commandOutlineView rowAtPoint:point];
    if (rowIndex == -1 || [commandOutlineView levelForRow:rowIndex] == 0) {
        [self hidePreview];
        return;
    }

    NSRect frame = [commandOutlineView frameOfCellAtColumn:1 row:rowIndex];
    frame.origin.y--;
    frame.size.height+=2;
    if (!NSPointInRect(point, frame)) {
        [self hidePreview];
        return;
    }



    if (saveRowIndex != rowIndex) {
        saveRowIndex = rowIndex;


        id item = [commandOutlineView itemAtRow:rowIndex];
        NSString *gesture = [item objectForKey:@"Gesture"];

        if ([gesture isEqualToString:@"All Unassigned Gestures"]) {
            [self hidePreview];
            return;
        }

        [gesturePreviewView stopTimer];
        gesturePreviewView = [[GesturePreviewView alloc] initWithDevice:0];
        [gesturePreviewView setHanded:0]; //no mirror
        [gesturePreviewView startTimer];

        NSPoint attachedPoint = [[window contentView] convertPoint:frame.origin fromView:commandOutlineView];
        attachedPoint.y -= frame.size.height/2;
        MAAttachedWindow *tmp = [[MAAttachedWindow alloc] initWithView:gesturePreviewView
                                                       attachedToPoint:attachedPoint
                                                              inWindow:window
                                                                onSide:0
                                                            atDistance:2.0];
        [tmp setBackgroundColor:[NSColor colorWithDeviceRed:1 green:1 blue:1 alpha:0.8]];
        [tmp setBorderWidth:0];
        [tmp setArrowBaseWidth:3*5];
        [tmp setArrowHeight:2*5];


        [window addChildWindow:tmp ordered:NSWindowAbove];


        [gesturePreviewView create:gesture forDevice:0];
        [gesturePreviewView release];


        if (attachedWindow) {
            [window removeChildWindow:attachedWindow];
            [attachedWindow orderOut:self];
            [attachedWindow release];
        }
        attachedWindow = tmp;
    } else if (scroll) {
        if (attachedWindow) {
            NSPoint attachedPoint = [[window contentView] convertPoint:frame.origin fromView:commandOutlineView];
            attachedPoint.y -= frame.size.height/2;
            [attachedWindow setPoint:attachedPoint side:0];
        }
    }
}

- (void)mouseEntered:(NSEvent *)theEvent {
    [self showPreview:NO];
}

- (void)mouseExited:(NSEvent *)theEvent {
    [self hidePreview];
}

- (void)mouseMoved:(NSEvent *)theEvent {
    [self showPreview:NO];
}

- (void)outlineViewScrolled:(NSNotification*)notification {
    [self showPreview:YES];
}


- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    return (item == nil) ? [recognitionCommands count] : [[item objectForKey:@"Gestures"] count];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return [outlineView levelForItem:item] == 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    return (item == nil) ? [recognitionCommands objectAtIndex:index] : [[item objectForKey:@"Gestures"] objectAtIndex:index];
}


- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    if ([outlineView levelForItem:item] == 0) {
        if ([[tableColumn identifier] isEqualToString:@"Gesture"]) {
            return [item objectForKey:@"Application"];
        } else if ([[tableColumn identifier] isEqualToString:@"Enable"]) {
            BOOL foundEnable=NO, foundDisable=NO;
            for (NSDictionary *command in [item objectForKey:@"Gestures"]) {
                if ([[command objectForKey:@"Enable"] intValue]) {
                    foundEnable = YES;
                } else {
                    foundDisable = YES;
                }
                if (foundEnable && foundDisable) break;
            }
            if (foundEnable) {
                if (foundDisable)
                    return [NSNumber numberWithInt:NSMixedState];
                return [NSNumber numberWithInt:NSOnState];
            }
            return [NSNumber numberWithInt:NSOffState];

        }
    } else {
        if ([[tableColumn identifier] isEqualToString:@"Gesture"]) {
            return [item objectForKey:@"Gesture"];
        } else if ([[tableColumn identifier] isEqualToString:@"Command"]) {
            return [item objectForKey:@"Command"];
        } else if ([[tableColumn identifier] isEqualToString:@"Enable"]) {
            return [item objectForKey:@"Enable"];
        }

    }
    return nil;
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    if ([[tableColumn identifier] isEqualToString:@"Enable"]) {
        if ([outlineView levelForItem:item] == 1) {
            [item setValue:object forKey:@"Enable"];
            [commandOutlineView reloadItem:nil reloadChildren:YES];

        } else {
            BOOL foundDisable=NO;
            for (NSDictionary *command in [item objectForKey:@"Gestures"]) {
                if (![[command objectForKey:@"Enable"] intValue]) {
                    foundDisable = YES;
                    break;
                }
            }
            if (foundDisable) {
                for (NSDictionary *gesture in [item objectForKey:@"Gestures"])
                    [gesture setValue:[NSNumber numberWithInteger:NSOnState] forKey:@"Enable"];
            } else {
                for (NSDictionary *gesture in [item objectForKey:@"Gestures"])
                    [gesture setValue:[NSNumber numberWithInteger:NSOffState] forKey:@"Enable"];
            }
            [outlineView reloadItem:nil reloadChildren:YES];
        }
        [Settings setKey:@"RecognitionCommands" with:recognitionCommands];
        [Settings noteSettingsUpdated];
    }
}


- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(NSCell *)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    if ([outlineView levelForItem:item] == 0) {
        if ([[tableColumn identifier] isEqualToString:@"Gesture"]) {
            NSString *application = [item objectForKey:@"Application"];
            NSImage *icon = [iconDict objectForKey:application];
            [(ImageAndTextCell *)cell setImage:icon];
        } else if ([[tableColumn identifier] isEqualToString:@"Enable"]) {
            [cell setAllowsMixedState:YES];

            BOOL foundEnable=NO, foundDisable=NO;
            for (NSDictionary *command in [item objectForKey:@"Gestures"]) {
                if ([[command objectForKey:@"Enable"] intValue]) {
                    foundEnable = YES;
                } else {
                    foundDisable = YES;
                }
                if (foundEnable && foundDisable) break;
            }
            //return;
            if (foundEnable) {
                if (foundDisable)
                    [cell setState:NSMixedState];
                else
                    [cell setState:NSOnState];
                return;
            }
            [cell setState:NSOffState];

        }
    } else {
        if ([[tableColumn identifier] isEqualToString:@"Gesture"]) {
            [(ImageAndTextCell *)cell setImage:nil];
        } else if ([[tableColumn identifier] isEqualToString:@"Enable"]) {
            [cell setAllowsMixedState:NO];
        }
    }
}


- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    if ([[tableColumn identifier] isEqualToString:@"Enable"])
        return YES;
    if ([outlineView levelForItem:item] == 1) {
        addsCommand = NO;
        oldItem = item;
        oldItemIndex = [allGestures indexOfObject:[item objectForKey:@"Gesture"]];
        [self showCommandSheet];
    }
    return NO;
}


- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
    return [outlineView levelForItem:item] == 0;
}


- (void)loadActionButton {

    NSString *saveTitle = [actionButton titleOfSelectedItem];
    [actionButton removeAllItems];

    NSString *gesture = [gestureTableView titleOfSelectedItem];

    if (!gesture) {
        [shortcutTextField setStringValue:@""];
        [shortcutTextField setEnabled:NO];
        return;
    }

    if ([gesture isEqualToString:@"One-Fix One-Slide"]) {
        [actionButton addItemWithTitle:@"Move / Resize"];
        [shortcutTextField setStringValue:@""];
        [shortcutTextField setEnabled:NO];
    } else if ([gesture isEqualToString:@"All Unassigned Gestures"]) {
        [shortcutTextField setStringValue:@""];
        [shortcutTextField setEnabled:NO];
    } else {
        NSMutableArray *builtinCommands = [NSMutableArray arrayWithObjects:
                                           @"New Tab",
                                           @"Close / Close Tab",
                                           @"Open Recently Closed Tab",
                                           @"Refresh",
                                           @"Quit",
                                           @"Hide",
                                           @"---",
                                           @"Full Screen",
                                           @"Minimize",
                                           @"Zoom",
                                           @"Maximize",
                                           @"Maximize Left",
                                           @"Maximize Right",
                                           @"Un-Maximize",
                                           @"---",
                                           @"Show Desktop",
                                           @"Dashboard",
                                           @"Mission Control",
                                           @"Launchpad",
                                           @"Application Windows",
                                           @"Application Switcher",
                                           @"---",
                                           @"New",
                                           @"Open",
                                           @"Save",
                                           @"Copy",
                                           @"Paste",
                                           @"---",
                                           @"Play / Pause",
                                           @"Next",
                                           @"Previous",
                                           @"Volume Up",
                                           @"Volume Down",
                                           @"---",
                                           @"Launch Browser",
                                             @"Launch Finder",
                                           @"Open File...",
                                           @"Open Website...",
                                           nil];
        if (![[applicationButton titleOfSelectedItem] isEqualToString:@"Safari"]) {
            [builtinCommands removeObject:@"Select Tab Above Cursor"];
        }

        if (openFilePath) {
            NSString *fileName = [openFilePath lastPathComponent];
            [builtinCommands insertObject:[NSString stringWithFormat:@"Open \"%@\"", fileName] atIndex:[builtinCommands count]];
        }
        if (openURL) {
            [builtinCommands insertObject:[NSString stringWithFormat:@"Open \"%@\"", openURL] atIndex:[builtinCommands count]];
        }

        for (NSString *element in builtinCommands) {
            if ([element isEqualToString:@"---"])
                [[actionButton menu] addItem:[NSMenuItem separatorItem]];
            else
                [actionButton addItemWithTitle:element];
        }

        [shortcutTextField setEnabled:YES];
    }



    [[actionButton menu] addItem:[NSMenuItem separatorItem]];
    [actionButton addItemWithTitle:@"-"];

    if (gesture == nil || saveTitle == nil || [saveTitle isEqualToString:@""]) {
        [actionButton selectItemWithTitle:@"-"];
    } else {
        NSInteger index = [actionButton indexOfItemWithTitle:saveTitle];
        if (index == -1)
            [actionButton selectItemWithTitle:@"-"];
        else
            [actionButton selectItemAtIndex:index];
    }


}

- (void)loadGestureTableView {
    [gestureTableView setDevice:0];
    [gestureTableView setGestures:allGestures];
    [gestureTableView reloadData];

    if (addsCommand) {

        BOOL found=NO;
        for (NSString *gesture in allGestures) {
            if ([[recognitionMap objectForKey:[applicationButton titleOfSelectedItem]] objectForKey:gesture] == nil) {
                [gestureTableView selectItemWithObjectValue:gesture];
                [gestureTableView scrollRowToVisible:[gestureTableView selectedRow]];
                found = YES;
                break;
            }
        }

        if (!found) {
            [gestureTableView deselectAll:self];
        }

    } else {
        [gestureTableView selectItemWithObjectValue:[oldItem objectForKey:@"Gesture"]];
        [gestureTableView scrollRowToVisible:[gestureTableView selectedRow]];
    }
}

- (IBAction)showAdvancedSheet:(id)sender {

    [indexRing setFloatValue:charRegIndexRingDistance*100];
    [mouseButton selectCellAtRow:0 column:charRegMouseButton];

    [oneDrawing setState:enOneDrawing];
    //[twoDrawing setState:enTwoDrawing];

    [NSApp beginSheet: advancedSheet
       modalForWindow: [mainView window]
        modalDelegate: self
       didEndSelector: @selector(didEndSheet:returnCode:contextInfo:)
          contextInfo: nil];

}
- (void)showCommandSheet {
    window = [mainView window];
    if (eventKeyboard) CGEventTapEnable(eventKeyboard, true);

    openFilePath = nil;
    openURL = nil;
    if (addsCommand) {

        if ([commandOutlineView selectedRow] != -1) {
            id item = [commandOutlineView itemAtRow:[commandOutlineView selectedRow]];
            if ([commandOutlineView levelForRow:[commandOutlineView selectedRow]] == 0) {
                [applicationButton selectItemWithTitle:[item objectForKey:@"Application"]];
            } else {
                [applicationButton selectItemWithTitle:[[commandOutlineView parentForItem:item] objectForKey:@"Application"]];
            }
        } else {
            if (saveApplication != nil)
                [applicationButton selectItemWithTitle:saveApplication];
        }
        [applicationButton setEnabled:YES];

        [self loadGestureTableView];

        [self loadActionButton];
        [actionButton selectItemWithTitle:@"-"];
        [shortcutTextField setStringValue:@""];

        [commitButton setTitle:@"Add"];
    } else {
        [applicationButton selectItemWithTitle: [[commandOutlineView parentForItem:oldItem] objectForKey:@"Application"]  ];
        [applicationButton setEnabled:NO];

        [self loadGestureTableView];

        if ([[oldItem objectForKey:@"IsAction"] boolValue] && [oldItem objectForKey:@"OpenFilePath"]) {
            openFilePath = [oldItem objectForKey:@"OpenFilePath"];
        }
        if ([[oldItem objectForKey:@"IsAction"] boolValue] && [oldItem objectForKey:@"OpenURL"]) {
            openURL = [oldItem objectForKey:@"OpenURL"];
        }

        [self loadActionButton];

        if ([[oldItem objectForKey:@"IsAction"] boolValue]) {
            [actionButton selectItemWithTitle:[oldItem objectForKey:@"Command"]];
            [shortcutTextField setStringValue:@""];
        } else {
            [actionButton setTitle:@""];
            [shortcutTextField setStringValue:[oldItem objectForKey:@"Command"]];
            shortcutTextField.modifierFlags = [[oldItem objectForKey:@"ModifierFlags"] unsignedIntegerValue];
            shortcutTextField.keyCode = [[oldItem objectForKey:@"KeyCode"] unsignedShortValue];
            [shortcutTextField selectText:nil];
        }

        [commitButton setTitle:@"Save"];
    }

    if ([gestureTableView selectedRow] == -1) {
        [shortcutTextField setStringValue:@""];
        [shortcutTextField setEnabled:NO];
    }

    if ([gestureTableView selectedRow] == -1) {
        [commitButton setEnabled:NO];
    }else{
        [commitButton setEnabled:YES];
    }

    [NSApp beginSheet: commandSheet
       modalForWindow: window
        modalDelegate: self
       didEndSelector: @selector(didEndSheet:returnCode:contextInfo:)
          contextInfo: nil];
}

- (IBAction)okUrlWindow:(id)sender {
    [NSApp endSheet:urlWindow];
    openFilePath = nil;
    openURL = [urlWindowUrl stringValue];
    openURL = [openURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![[NSURL URLWithString:openURL] scheme]) {
        openURL = [NSString stringWithFormat:@"http://%@", openURL];
    }
    [openURL retain];
    [self loadActionButton];
    [actionButton selectItemWithTitle:[NSString stringWithFormat:@"Open \"%@\"", openURL]];
}

- (IBAction)cancelUrlWindow:(id)sender {
    [NSApp endSheet:urlWindow];
    [actionButton selectItemWithTitle:@"-"];

}

- (IBAction)cancelCommandSheet:(id)sender {
    [gestureTableView hidePreview];
    CGEventTapEnable(eventKeyboard, false);
    [NSApp endSheet:commandSheet];

}


- (IBAction)commitCommandSheet:(id)sender {
    [gestureTableView hidePreview];
    CGEventTapEnable(eventKeyboard, false);
    [NSApp endSheet:commandSheet];
    NSString *newApplication = [applicationButton titleOfSelectedItem];
    NSString *newApplicationPath = [applicationButton pathOfSelectedItem];
    NSString *newGesture = [gestureTableView titleOfSelectedItem];
    NSMutableDictionary *newCommand;

    saveApplication = newApplication;

    if ([[shortcutTextField stringValue] isEqualToString:@""]) {
        //action
        newCommand = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                      newGesture, @"Gesture",
                      [actionButton titleOfSelectedItem], @"Command",
                      [NSNumber numberWithBool:YES], @"IsAction",
                      [NSNumber numberWithUnsignedInteger:0], @"ModifierFlags",
                      [NSNumber numberWithUnsignedShort:0], @"KeyCode",
                      [NSNumber numberWithInt:NSOnState], @"Enable",
                      nil];
        if (openFilePath) {
            [newCommand setObject:openFilePath forKey:@"OpenFilePath"];
        }
        if (openURL) {
            [newCommand setObject:openURL forKey:@"OpenURL"];
        }
    } else {

        //shortcut
        newCommand = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                      newGesture, @"Gesture",
                      [shortcutTextField stringValue], @"Command",
                      [NSNumber numberWithBool:NO], @"IsAction",
                      [NSNumber numberWithUnsignedInteger:shortcutTextField.modifierFlags], @"ModifierFlags",
                      [NSNumber numberWithUnsignedShort:shortcutTextField.keyCode], @"KeyCode",
                      [NSNumber numberWithInt:NSOnState], @"Enable",
                      nil];
    }


    if (!addsCommand) {
        NSString *oldApp = [[commandOutlineView parentForItem:oldItem] objectForKey:@"Application"];
        [[recognitionMap objectForKey:oldApp] removeObjectForKey:[oldItem objectForKey:@"Gesture"]];
        [[[commandOutlineView parentForItem:oldItem] objectForKey:@"Gestures"] removeObject:oldItem];
    }

    {
        //user adds a command
        NSUInteger i, count = [recognitionCommands count];
        for (i = 0; i < count; i++) {
            if ([[[recognitionCommands objectAtIndex:i] objectForKey:@"Application"] isEqualToString:newApplication]) {
                NSMutableArray *tmp = [[recognitionCommands objectAtIndex:i] objectForKey:@"Gestures"];
                NSUInteger j, count2 = [tmp count];
                NSUInteger newGestureIndex = [allGestures indexOfObject:newGesture];
                for (j = 0; j < count2; j++) {
                    NSUInteger currentGestureIndex = [allGestures indexOfObject: [[tmp objectAtIndex:j] objectForKey:@"Gesture"  ]];
                    if (currentGestureIndex > newGestureIndex) break;
                }
                //[[[recognitionCommands objectAtIndex:i] objectForKey:@"Gestures"] addObject:newCommand];
                [[[recognitionCommands objectAtIndex:i] objectForKey:@"Gestures"] insertObject:newCommand atIndex:j];


                [[recognitionMap objectForKey:newApplication] setObject:newCommand forKey:newGesture];
                break;
            }
        }
        if (i == count) {
            NSMutableArray *gestures = [[NSMutableArray alloc] init];
            [gestures addObject:newCommand];
            NSMutableDictionary *app = [[NSMutableDictionary alloc] initWithObjectsAndKeys:newApplication, @"Application", newApplicationPath, @"Path", gestures, @"Gestures", nil];
            [gestures release];
            [recognitionCommands addObject:app];
            [app release];


            NSMutableDictionary *tmp = [[NSMutableDictionary alloc] initWithObjectsAndKeys:newCommand, newGesture, nil];
            [recognitionMap setObject:tmp forKey:newApplication];
            [tmp release];
        }

        [commandOutlineView reloadItem:nil reloadChildren:YES];
        [commandOutlineView expandItem:[recognitionCommands objectAtIndex:i] expandChildren:YES];

    }

    NSInteger newIndex = [commandOutlineView rowForItem:newCommand];
    [commandOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:newIndex] byExtendingSelection:NO];
    [commandOutlineView scrollRowToVisible:newIndex];

    [newCommand release];

    [Settings setKey:@"RecognitionCommands" with:recognitionCommands];
    [Settings noteSettingsUpdated];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo{
    [sheet orderOut:self];
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    if ([commandOutlineView selectedRow] != -1) {
        [removeButton setEnabled:YES];
    } else {
        [removeButton setEnabled:NO];
    }
}

- (IBAction)addCommand:(id)sender {
    addsCommand = YES;
    [self showCommandSheet];
}

- (IBAction)removeCommand:(id)sender {
    id item = [commandOutlineView itemAtRow:[commandOutlineView selectedRow]];
    if ([commandOutlineView levelForItem:item] == 0) {
        [recognitionMap removeObjectForKey:[item objectForKey:@"Application"]];

        [recognitionCommands removeObject:item];
    } else {
        NSString *app = [[commandOutlineView parentForItem:item] objectForKey:@"Application"];
        [[recognitionMap objectForKey:app] removeObjectForKey:[item objectForKey:@"Gesture"]];

        [[[commandOutlineView parentForItem:item] objectForKey:@"Gestures"] removeObject:item];
    }
    [commandOutlineView reloadData];
    [Settings setKey:@"RecognitionCommands" with:recognitionCommands];
    [Settings noteSettingsUpdated];
}

- (IBAction)change:(id)sender {
    if (sender == actionButton) {
        [shortcutTextField setStringValue:@""];
        //[gestureTableView becomeFirstResponder]; DOESN"T WORK
        //[commitButton becomeFirstResponder];


        if ([[actionButton titleOfSelectedItem] isEqualToString:@"Open File..."]) {
            NSOpenPanel *oPanel = [NSOpenPanel openPanel];
            [oPanel setCanChooseDirectories:YES];
            NSModalResponse result = [oPanel runModal];

            if (result == NSOKButton) {
                openFilePath = [[[oPanel URL] path] copy]; //TODO: mem leak
                openURL = nil;
                [self loadActionButton];
                [actionButton selectItemWithTitle:[NSString stringWithFormat:@"Open \"%@\"", [openFilePath lastPathComponent]]];
            } else {
                [actionButton selectItemWithTitle:@"-"];
            }
        } else if ([[actionButton titleOfSelectedItem] isEqualToString:@"Open Website..."]) {
            if (openURL)
                [urlWindowUrl setStringValue:openURL];
            else
                [urlWindowUrl setStringValue:@""];
            [urlWindowOk setTarget:self];
            [urlWindowOk setAction:@selector(okUrlWindow:)];
            [urlWindowCancel setTarget:self];
            [urlWindowCancel setAction:@selector(cancelUrlWindow:)];
            [NSApp beginSheet: urlWindow
               modalForWindow: commandSheet
                modalDelegate: self
               didEndSelector: @selector(didEndSheet:returnCode:contextInfo:)
                  contextInfo: nil];
        }
    } else if (sender == shortcutTextField && ![[shortcutTextField stringValue] isEqualToString:@""]) {
        //[actionButton selectItemWithTitle:@"-"];
        [actionButton setTitle:@""];
    } else if (sender == applicationButton) {
        if ([[applicationButton titleOfSelectedItem] isEqualToString:@"Other..."]) {
            NSOpenPanel *oPanel = [NSOpenPanel openPanel];
            [oPanel setDirectoryURL:[NSURL fileURLWithPath:@"/Applications"]];
            [oPanel setAllowedFileTypes:@[@"app"]];
            NSModalResponse result = [oPanel runModal];

            if (result == NSOKButton) {
                NSString* path = [[oPanel URL] path];
                [applicationButton addApplication:path];
            } else {
                [applicationButton selectItemAtIndex:0];
            }
        }
        [self loadGestureTableView];
        [self loadActionButton];
    } else if (sender == cbTrackpad) {
        enCharRegTP = [sender state] == NSOnState ? 1: 0;
        [Settings setKey:@"enCharRegTP" withInt:enCharRegTP];
        [self enUpdated];
    } else if (sender == cbMouse) {
        enCharRegMM = [sender state] == NSOnState ? 1: 0;
        [Settings setKey:@"enCharRegMM" withInt:enCharRegMM];
        [self enUpdated];
    }

    if ([gestureTableView selectedRow] == -1) {
        [shortcutTextField setStringValue:@""];
        [shortcutTextField setEnabled:NO];
    }

    if ([gestureTableView selectedRow] == -1) {
        [commitButton setEnabled:NO];
    } else {
        [commitButton setEnabled:YES];
    }

    [Settings noteSettingsUpdated];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    [self loadActionButton];

}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex {
    if (addsCommand) {
        return [[recognitionMap objectForKey:[applicationButton titleOfSelectedItem]] objectForKey:[allGestures objectAtIndex:rowIndex]] == nil;
    } else {
        NSDictionary *tmp = [recognitionMap objectForKey:[applicationButton titleOfSelectedItem]];
        return rowIndex == oldItemIndex || [tmp objectForKey:[allGestures objectAtIndex:rowIndex]] == nil;
    }
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    if (addsCommand) {
        if ([[recognitionMap objectForKey:[applicationButton titleOfSelectedItem]] objectForKey:[allGestures objectAtIndex:rowIndex]] == nil)
            [aCell setTextColor:[NSColor textColor]];
        else
            [aCell setTextColor:[NSColor colorWithDeviceRed:0.6 green:0.6 blue:0.6 alpha:1.0]];
    } else {
        NSDictionary *tmp = [recognitionMap objectForKey:[applicationButton titleOfSelectedItem]];
        if (rowIndex == oldItemIndex || [tmp objectForKey:[allGestures objectAtIndex:rowIndex]] == nil)
            [aCell setTextColor:[NSColor textColor]];
        else
            [aCell setTextColor:[NSColor colorWithDeviceRed:0.6 green:0.6 blue:0.6 alpha:1.0]];
    }
}

- (IBAction)restoreDefaults:(id)sender {
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:@"Restore default settings?"];
    [alert setInformativeText:@"Your current Character Gestures settings will be deleted."];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    if (returnCode == NSAlertFirstButtonReturn) {
        [Settings recognitionDefault];
        isPrefPane = YES;
        //[Settings loadSettings];
        [Settings readSettings];
        [commandOutlineView reloadData];
        [commandOutlineView expandItem:nil expandChildren:YES];
        [Settings noteSettingsUpdated];
    }
}

- (void)willUnselect {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewBoundsDidChangeNotification object:nil];
    [self hidePreview];
    [gestureTableView willUnselect];
}

- (void)dealloc{;
    [allGestures release];
    [iconDict release];
    [super dealloc];
}

@end
