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

#import "CursorWindow.h"
#import "CursorView.h"

@implementation CursorWindow

- (id)init {
    self = [super initWithContentRect:NSMakeRect(0.0, 0.0, 100.0, 100.0) styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    if (self != nil) {
        self.alphaValue = 1.0;
        self.opaque = NO;
        self.backgroundColor = [NSColor clearColor];

        cursorView = [[CursorView alloc] initWithFrame:[self frame]];
        [self setContentView:cursorView];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
}

@end
