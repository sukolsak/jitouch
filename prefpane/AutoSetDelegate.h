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
