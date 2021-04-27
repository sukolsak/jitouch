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

@interface SizeHistory : NSObject {
    NSRect curRect, savRect;
}
@property (readonly) NSRect curRect;
@property (readonly) NSRect savRect;
- (id)initWithCurRect:(NSRect)curRect SaveRect:(NSRect) savRect;

@end


@interface SizeHistoryKey : NSObject<NSCopying> {
    const CFTypeRef *windowRef;
}
- (void)setWindowRef:(CFTypeRef) a;
- (id)initWithKey:(CFTypeRef)a;
- (id) copyWithZone:(NSZone *)zone;
- (BOOL) isEqual:(id)other;
- (NSUInteger) hash;
@end
