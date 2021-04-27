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

#import "ApplicationButton.h"
#import "Settings.h"

@implementation ApplicationButton

- (NSString*)pathOfSelectedItem {
    if ([self indexOfSelectedItem]-2 < 0 || [self indexOfSelectedItem]-2 >= [allAppPaths count])
        return @"";
    return [allAppPaths objectAtIndex:[self indexOfSelectedItem]-2];
}

- (void)addApplication:(NSString*)path {
    NSBundle *bundle = [NSBundle bundleWithPath: path];
    NSDictionary *infoDict = [bundle infoDictionary];
    NSString *displayName = [infoDict objectForKey: @"CFBundleName"];
    if (!displayName)
        displayName = [infoDict objectForKey: @"CFBundleExecutable"];

    if (displayName) { //TODO: workaround

        if ([displayName isEqualToString:@"RDC"])
            displayName = @"Remote Desktop Connection"; //TODO: workaround

        [allApps addObject:displayName];
        [allAppPaths addObject:path];

        NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:path];
        [icon setSize:NSMakeSize(16, 16)];
        [iconDict setObject:icon forKey:displayName];

        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:displayName action:nil keyEquivalent:@""];
        [item setImage:icon];
        {
            [[self menu] insertItem:item atIndex:[[[self menu] itemArray] count]-2];
            [self selectItemAtIndex:[[[self menu] itemArray] count]-3];
        }
        [item release];
    }
}

- (void)awakeFromNib {
    isPrefPane = YES;
    [Settings loadSettings:self];

    [self addItemWithTitle:@"All Applications"];
    [[self menu] addItem:[NSMenuItem separatorItem]];

    for (NSUInteger i = 0; i<[allApps count]; i++) {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[allApps objectAtIndex:i] action:nil keyEquivalent:@""];
        [item setImage:[iconDict objectForKey:[allApps objectAtIndex:i]]];
        [[self menu] addItem:item];
        [item release];
    }

    [[self menu] addItem:[NSMenuItem separatorItem]];
    [self addItemWithTitle:@"Other..."];
}

@end
