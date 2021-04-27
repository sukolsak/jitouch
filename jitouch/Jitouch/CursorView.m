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

#import "CursorView.h"

int cursorImageType;

@implementation CursorView

@synthesize moveImage;
@synthesize resizeImage;
@synthesize tabImage;

- (id)initWithFrame:(NSRect)frameRect{
    if (self = [super initWithFrame:frameRect]) {
        self.moveImage = [NSImage imageNamed:@"move"];
        self.resizeImage = [NSImage imageNamed:@"resize"];
        self.tabImage = [NSImage imageNamed:@"tab"];
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
    [[NSColor clearColor] set];
    NSRectFill(self.frame);
    NSImage *image = nil;
    if (cursorImageType == 0) {
        image = moveImage;
    } else if (cursorImageType == 1) {
        image = resizeImage;
    } else if (cursorImageType == 2) {
        image = tabImage;
    }
    [image drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    [[self window] setHasShadow:NO];
}

- (void)dealloc {
    [moveImage release];
    [resizeImage release];
    [tabImage release];
    [super dealloc];
}

@end
