//
//  Settings.h
//  Jitouch
//
//  Copyright 2021 Supasorn Suwajanakorn and Sukolsak Sakshuwong. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define kCurrentRevision 26
#define kAcceptableOldestRevision 13
#define appID CFSTR("com.jitouch.Jitouch")

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


@interface Settings : NSObject

+ (void)loadSettings;
//+ (void)noteSettingsUpdated;
+ (void)noteSettingsUpdated2;
+ (void)setKey:(NSString*)aKey withInt:(int)aValue;
//+ (void)setKey:(NSString*)aKey withFloat:(float)aValue;
+ (void)setKey:(NSString*)aKey with:(id)aValue;
//+ (void)trackpadDefault;
//+ (void)magicMouseDefault;
//+ (void)recognitionDefault;
//+ (void)createDefaultPlist;
+ (void)loadSettings:(id)sender;
+ (void)loadSettings2:(NSDictionary*)newSettings;

@end
