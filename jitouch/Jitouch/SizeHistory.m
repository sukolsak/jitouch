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

#import "SizeHistory.h"

@implementation SizeHistory

@synthesize curRect;
@synthesize savRect;

- (id)initWithCurRect:(NSRect)a SaveRect:(NSRect) b {
    if (self = [super init]) {
        curRect = a;
        savRect = b;
    }
    return self;
}
@end


@implementation SizeHistoryKey

- (id)initWithKey:(CFTypeRef)a {
    if (self = [super init]) {
        [self setWindowRef:a];
    }
    return self;
}
- (void)setWindowRef:(CFTypeRef) a {
    windowRef = a;
    CFRetain(windowRef);
}
- (id) copyWithZone:(NSZone *)zone {
    SizeHistoryKey* copy = [[self class] alloc];
    [copy setWindowRef:windowRef];
    return copy;
}
- (void) dealloc {
    CFRelease(windowRef);
    [super dealloc];
}
- (BOOL) isEqual:(id)other {
    return CFEqual(windowRef, other);
}

- (NSUInteger) hash {
    return CFHash(windowRef);;
}
@end
