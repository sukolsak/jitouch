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

#define kCurrentRevision 26
#define kAcceptableOldestRevision 13
#define appID CFSTR("com.jitouch.Jitouch")

@class TrackpadTab, MagicMouseTab, RecognitionTab;

extern NSMutableDictionary *settings;
extern NSMutableDictionary *trackpadMap;
extern NSMutableDictionary *magicMouseMap;
extern NSMutableDictionary *recognitionMap;

//General
extern float clickSpeed;
extern float stvt;
extern int enAll;

//Trackpad
extern int enTPAll;
extern int enHanded;

//Magic Mouse
extern int enMMAll;
extern int enMMHanded;

//Character Recognition
extern int enCharRegTP;
extern int enCharRegMM;
extern float charRegIndexRingDistance;
extern int charRegMouseButton;
extern int enOneDrawing, enTwoDrawing;

extern NSMutableArray *trackpadCommands;
extern NSMutableArray *magicMouseCommands;
extern NSMutableArray *recognitionCommands;

extern BOOL hasloaded;

extern BOOL isPrefPane;

extern BOOL hasPreviousVersion;

extern NSView *mainView;

extern TrackpadTab *trackpadTab;
extern MagicMouseTab *magicMouseTab;
extern RecognitionTab *recognitionTab;

extern NSMutableDictionary *iconDict;
extern NSMutableArray *allApps;
extern NSMutableArray *allAppPaths;

extern CFMachPortRef eventKeyboard;


@interface Settings : NSObject

//+ (void)loadSettings;
+ (void)noteSettingsUpdated;
//+ (void)noteSettingsUpdated2;
+ (void)setKey:(NSString*)aKey withInt:(int)aValue;
+ (void)setKey:(NSString*)aKey withFloat:(float)aValue;
+ (void)setKey:(NSString*)aKey with:(id)aValue;
+ (void)trackpadDefault;
+ (void)magicMouseDefault;
+ (void)recognitionDefault;
+ (void)createDefaultPlist;
+ (void)loadSettings:(id)sender;
+ (void)readSettings;
+ (void)readSettings2:(NSDictionary*)d;

@end
