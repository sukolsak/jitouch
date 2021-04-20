//
//  Settings.m
//  Jitouch
//
//  Copyright 2021 Supasorn Suwajanakorn and Sukolsak Sakshuwong. All rights reserved.
//

#import "Settings.h"
#import <CoreFoundation/CFPreferences.h>
#import <CoreFoundation/CoreFoundation.h>

#define ADD_GESTURE(a, gesture, command) [a addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:gesture, @"Gesture", command, @"Command", @YES, @"IsAction", @0, @"ModifierFlags", @0, @"KeyCode", [NSNumber numberWithInt:NSOnState], @"Enable", nil]];

NSMutableDictionary *settings;
NSMutableDictionary *trackpadMap;
NSMutableDictionary *magicMouseMap;
NSMutableDictionary *recognitionMap;

//General
float clickSpeed;
float stvt;
int enAll;

//Trackpad
int enTPAll;
int enHanded;

//Magic Mouse
int enMMAll;
int enMMHanded;

//Character Recognition
int enCharRegTP;
int enCharRegMM;
float charRegIndexRingDistance;
int charRegMouseButton;
int enOneDrawing, enTwoDrawing;

NSMutableArray *trackpadCommands;
NSMutableArray *magicMouseCommands;
NSMutableArray *recognitionCommands;

BOOL hasloaded;

BOOL isPrefPane;

BOOL hasPreviousVersion;

NSView *mainView;

TrackpadTab *trackpadTab;
MagicMouseTab *magicMouseTab;
RecognitionTab *recognitionTab;

NSMutableDictionary *iconDict;
NSMutableArray *allApps;
NSMutableArray *allAppPaths;

CFMachPortRef eventKeyboard;


@implementation Settings

static int notSynchronize;

+ (void)noteSettingsUpdated {
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName: @"My Notification"
                                                                   object: @"com.jitouch.Jitouch.PrefpaneTarget"
                                                                 userInfo: settings
                                                       deliverImmediately: YES];
}

+ (void)setKey:(NSString*)aKey withInt:(int)aValue{
    [settings setObject:[NSNumber numberWithInt:aValue] forKey:aKey];

    CFNumberRef value = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &aValue);
    CFPreferencesSetAppValue((CFStringRef)aKey, value, appID);
    CFRelease(value);
    if (!notSynchronize)
        CFPreferencesAppSynchronize(appID);
}

+ (void)setKey:(NSString*)aKey withFloat:(float)aValue{
    [settings setObject:[NSNumber numberWithFloat:aValue] forKey:aKey];

    CFNumberRef value = CFNumberCreate(kCFAllocatorDefault, kCFNumberFloatType, &aValue);
    CFPreferencesSetAppValue((CFStringRef)aKey, value, appID);
    CFRelease(value);
    if (!notSynchronize)
        CFPreferencesAppSynchronize(appID);
}

+ (void)setKey:(NSString*)aKey with:(id)aValue {
    [settings setObject:aValue forKey:aKey];

    CFPropertyListRef value = (CFPropertyListRef)aValue;
    CFPreferencesSetAppValue((CFStringRef)aKey, value, appID);
    //CFRelease(value);
    if (!notSynchronize)
        CFPreferencesAppSynchronize(appID);
}

// must make sure that everything is mutable

+ (void)recognitionDefault {
    NSMutableArray *gestures1 = [[NSMutableArray alloc] init];
    ADD_GESTURE(gestures1, @"B", @"Launch Browser");
    ADD_GESTURE(gestures1, @"F", @"Launch Finder");
    ADD_GESTURE(gestures1, @"N", @"New");
    ADD_GESTURE(gestures1, @"O", @"Open");
    ADD_GESTURE(gestures1, @"S", @"Save");
    ADD_GESTURE(gestures1, @"T", @"New Tab");
    ADD_GESTURE(gestures1, @"Up", @"Copy");
    ADD_GESTURE(gestures1, @"Down", @"Paste");

    ADD_GESTURE(gestures1, @"Left", @"Maximize Left");
    ADD_GESTURE(gestures1, @"Right", @"Maximize Right");
    ADD_GESTURE(gestures1, @"/ Up", @"Maximize");
    ADD_GESTURE(gestures1, @"/ Down", @"Un-Maximize");

    NSDictionary *app1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"All Applications", @"Application", @"", @"Path", gestures1, @"Gestures", nil];

    NSMutableArray *apps = [[NSMutableArray alloc] init];
    [apps addObject:app1];

    [Settings setKey:@"RecognitionCommands" with:apps];
    [apps release];
    [gestures1 release];
}

+ (void)trackpadDefault {
    NSMutableArray *gestures1 = [[NSMutableArray alloc] init];
    ADD_GESTURE(gestures1, @"One-Fix Left-Tap", @"Previous Tab");
    ADD_GESTURE(gestures1, @"One-Fix Right-Tap", @"Next Tab");
    ADD_GESTURE(gestures1, @"One-Fix One-Slide", @"Move / Resize");
    ADD_GESTURE(gestures1, @"One-Fix Two-Slide-Down", @"Close / Close Tab");
    ADD_GESTURE(gestures1, @"One-Fix-Press Two-Slide-Down", @"Quit");
    ADD_GESTURE(gestures1, @"Two-Fix Index-Double-Tap", @"Refresh");
    ADD_GESTURE(gestures1, @"Three-Finger Tap", @"Middle Click");
    ADD_GESTURE(gestures1, @"Pinky-To-Index", @"Zoom");
    ADD_GESTURE(gestures1, @"Index-To-Pinky", @"Minimize");
    //ADD_GESTURE(gestures1, @"Left-Side Scroll", @"Auto Scroll");

    NSDictionary *app1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"All Applications", @"Application", @"", @"Path", gestures1, @"Gestures", nil];

    NSMutableArray *apps = [[NSMutableArray alloc] init];
    [apps addObject:app1];

    [Settings setKey:@"TrackpadCommands" with:apps];

    [apps release];
    [gestures1 release];
}

+ (void)magicMouseDefault {
    NSMutableArray *gestures1 = [[NSMutableArray alloc] init];
    ADD_GESTURE(gestures1, @"Middle-Fix Index-Near-Tap", @"Next Tab");
    ADD_GESTURE(gestures1, @"Middle-Fix Index-Far-Tap", @"Previous Tab");
    ADD_GESTURE(gestures1, @"Middle-Fix Index-Slide-Out", @"Close / Close Tab");
    ADD_GESTURE(gestures1, @"Middle-Fix Index-Slide-In", @"Refresh");
    ADD_GESTURE(gestures1, @"Three-Swipe-Up", @"Show Desktop");
    ADD_GESTURE(gestures1, @"Three-Swipe-Down", @"Mission Control");
    ADD_GESTURE(gestures1, @"V-Shape", @"Move / Resize");
    ADD_GESTURE(gestures1, @"Middle Click", @"Middle Click");

    NSDictionary *app1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"All Applications", @"Application", @"", @"Path", gestures1, @"Gestures", nil];

    NSMutableArray *apps = [[NSMutableArray alloc] init];
    [apps addObject:app1];
    [Settings setKey:@"MagicMouseCommands" with:apps];
    [apps release];
    [gestures1 release];
}

+ (void)createDefaultPlist {
    notSynchronize = 1;

    //General
    [Settings setKey:@"enAll" withInt:1];
    [Settings setKey:@"ClickSpeed" withFloat:0.25];
    [Settings setKey:@"Sensitivity" withFloat:4.6666];
    [Settings setKey:@"ShowIcon" withInt:1];
    [Settings setKey:@"Revision" withInt:kCurrentRevision];

    //Trackpad
    [Settings setKey:@"enTPAll" withInt:1];
    [Settings setKey:@"Handed" withInt:0];

    //Magic Mouse
    [Settings setKey:@"enMMAll" withInt:1];
    [Settings setKey:@"MMHanded" withInt:0];

    //Recognition
    [Settings setKey:@"enCharRegTP" withInt:0];
    [Settings setKey:@"enCharRegMM" withInt:0];
    [Settings setKey:@"charRegMouseButton" withInt:0];
    [Settings setKey:@"charRegIndexRingDistance" withFloat:0.33];
    [Settings setKey:@"enOneDrawing" withInt:0];
    [Settings setKey:@"enTwoDrawing" withInt:1];

    [Settings trackpadDefault];
    [Settings magicMouseDefault];
    [Settings recognitionDefault];

    CFPreferencesAppSynchronize(appID);

    notSynchronize = 0;
}

// The jitouch app doesn't have ability to change settings
// except these three keys: enAll
+ (void)readSettings2:(NSDictionary*)d {
    [settings setObject:[d objectForKey:@"enAll"] forKey:@"enAll"];

    enAll = [[settings objectForKey:@"enAll"] intValue];
}


+ (void)readSettings {

    //General
    enAll = [[settings objectForKey:@"enAll"] intValue];
    clickSpeed = [[settings objectForKey:@"ClickSpeed"] floatValue];
    stvt = [[settings objectForKey:@"Sensitivity"] floatValue];

    //Trackpad
    enTPAll = [[settings objectForKey:@"enTPAll"] intValue];
    enHanded = [[settings objectForKey:@"Handed"] intValue];

    //Magic Mouse
    enMMAll = [[settings objectForKey:@"enMMAll"] intValue];
    enMMHanded = [[settings objectForKey:@"MMHanded"] intValue];

    //Recognition
    enCharRegTP = [[settings objectForKey:@"enCharRegTP"] intValue];
    enCharRegMM = [[settings objectForKey:@"enCharRegMM"] intValue];
    enOneDrawing = [[settings objectForKey:@"enOneDrawing"] intValue];
    enTwoDrawing = [[settings objectForKey:@"enTwoDrawing"] intValue];

    if (![settings objectForKey:@"charRegIndexRingDistance"])
        charRegIndexRingDistance = 0.3;
    else
        charRegIndexRingDistance = [[settings objectForKey:@"charRegIndexRingDistance"] floatValue];

    if (![settings objectForKey:@"charRegMouseButton"])
        charRegMouseButton = 0;
    else
        charRegMouseButton = [[settings objectForKey:@"charRegMouseButton"] intValue];


    trackpadCommands = [settings objectForKey:@"TrackpadCommands"];
    magicMouseCommands = [settings objectForKey:@"MagicMouseCommands"];
    recognitionCommands = [settings objectForKey:@"RecognitionCommands"];


    void (^optimize)(NSArray*, NSMutableDictionary*) = ^(NSArray *commands, NSMutableDictionary *map) {
        for (NSDictionary *app in commands) {
            NSString *appName = [app objectForKey:@"Application"];
            if (!isPrefPane) {
                if ([appName isEqualToString:@"Chrome"])
                    appName = @"Google Chrome";
                else if ([appName isEqualToString:@"Word"])
                    appName = @"Microsoft Word";
            }

            NSMutableDictionary *gestures = [[NSMutableDictionary alloc] init];
            for (NSDictionary *gesture in [app objectForKey:@"Gestures"]) {
                [gestures setObject:gesture forKey:[gesture objectForKey:@"Gesture"]];
            }
            [map setObject:gestures forKey:appName];
            [gestures release];
        }
    };

    // optimization for trackpad commands
    [trackpadMap release];
    trackpadMap = [[NSMutableDictionary alloc] init];
    optimize(trackpadCommands, trackpadMap);

    // optimization for magicmouse commands
    [magicMouseMap release];
    magicMouseMap = [[NSMutableDictionary alloc] init];
    optimize(magicMouseCommands, magicMouseMap);

    // optimization for recognition commands
    [recognitionMap release];
    recognitionMap = [[NSMutableDictionary alloc] init];
    optimize(recognitionCommands, recognitionMap);


    // load all icons and all apps
    if (isPrefPane) {
        [allApps release];
        [allAppPaths release];

        allApps = [[NSMutableArray alloc] init];
        allAppPaths = [[NSMutableArray alloc] init];

        [allApps addObject:@"Finder"];
        [allAppPaths addObject:@"/System/Library/CoreServices/Finder.app"];

        NSEnumerator* dirEnum = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Applications" error:NULL] objectEnumerator];
        NSString *file;
        while (file = [dirEnum nextObject]) {
            if ([[file pathExtension] isEqualToString: @"app"]) {
                NSString* path = [NSString stringWithFormat:@"/Applications/%@", file];

                NSBundle *bundle = [NSBundle bundleWithPath:path];
                NSDictionary *infoDict = [bundle infoDictionary];
                NSString *displayName = [infoDict objectForKey: @"CFBundleName"];
                if (!displayName)
                    displayName = [infoDict objectForKey: @"CFBundleExecutable"];

                if (displayName) { //TODO: workaround
                    if ([displayName isEqualToString:@"RDC"])
                        displayName = @"Remote Desktop Connection"; //TODO: workaround

                    [allApps addObject:displayName];
                    [allAppPaths addObject:path];
                }
            }
        }
        for (NSDictionary *app in trackpadCommands) {
            if (![[app objectForKey:@"Application"] isEqualToString:@"All Applications"] &&
                ![allApps containsObject:[app objectForKey:@"Application"]]) {
                [allApps addObject:[app objectForKey:@"Application"]];
                [allAppPaths addObject:[app objectForKey:@"Path"]];
            }
        }
        for (NSDictionary *app in magicMouseCommands) {
            if (![[app objectForKey:@"Application"] isEqualToString:@"All Applications"] &&
                ![allApps containsObject:[app objectForKey:@"Application"]]) {
                [allApps addObject:[app objectForKey:@"Application"]];
                [allAppPaths addObject:[app objectForKey:@"Path"]];
            }
        }
        for (NSDictionary *app in recognitionCommands) {
            if (![[app objectForKey:@"Application"] isEqualToString:@"All Applications"] &&
                ![allApps containsObject:[app objectForKey:@"Application"]]) {
                [allApps addObject:[app objectForKey:@"Application"]];
                [allAppPaths addObject:[app objectForKey:@"Path"]];
            }
        }


        [iconDict release];
        iconDict = [[NSMutableDictionary alloc] init];

        NSImage *icon = [NSImage imageNamed:@"NSComputer"];
        [icon setSize:NSMakeSize(16, 16)];
        [iconDict setObject:icon forKey:@"All Applications"];

        for (NSUInteger i = 0; i<[allApps count]; i++) {
            NSString *app = [allApps objectAtIndex:i];
            NSString *path = [allAppPaths objectAtIndex:i];
            if (![path isEqualToString:@""]) {
                NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:path];
                [icon setSize:NSMakeSize(16, 16)];
                [iconDict setObject:icon forKey:app];
            } else {
                NSImage *icon = [NSImage imageNamed:@"NSComputer"];
                [icon setSize:NSMakeSize(16, 16)];
                [iconDict setObject:icon forKey:app];
            }
        }
    }
}


+ (void)loadSettings {
    [settings release];

    settings = [[NSMutableDictionary alloc] init];

    NSString *plistPath = [@"~/Library/Preferences/com.jitouch.Jitouch.plist" stringByStandardizingPath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        [Settings createDefaultPlist];
        hasPreviousVersion = YES; //may have .. because the previous version doesn't have plist
    } else {
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
        NSString *errorDesc = nil;
        [settings setDictionary:[NSPropertyListSerialization
                                 propertyListFromData:plistXML
                                 mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                 format:NULL
                                 errorDescription:&errorDesc]];
    }

    if (isPrefPane) {
        if ([settings objectForKey:@"Revision"] == nil ||
            [[settings objectForKey:@"Revision"] intValue] < kAcceptableOldestRevision) {
            NSAlert *alert = [NSAlert alertWithMessageText:@"Do you want to update the preference file?"
                                             defaultButton:@"Update"
                                           alternateButton:@"Don't Update"
                                               otherButton:nil
                                 informativeTextWithFormat:@"Your jitouch preference file is out of date. Would you like to use the new default settings? Your current settings will be permanently deleted.\n\nAlternately, you may later click \"Restore Defaults\" to use the new default settings."];
            NSModalResponse response = [alert runModal];
            if (response == NSOKButton) {
                [Settings createDefaultPlist];
                [settings release];
                NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
                settings = [[NSMutableDictionary alloc] init];

                NSString *errorDesc = nil;
                [settings setDictionary:[NSPropertyListSerialization
                                         propertyListFromData:plistXML
                                         mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                         format:NULL
                                         errorDescription:&errorDesc]];
                hasPreviousVersion = YES;
            }
        }

        if ([settings objectForKey:@"Revision"] == nil ||
            [[settings objectForKey:@"Revision"] intValue] != kCurrentRevision) {
            hasPreviousVersion = YES;
            [Settings setKey:@"Revision" withInt:kCurrentRevision];
        }
    }

    [Settings readSettings];
}

+ (void)loadSettings:(id)sender {
    if (hasloaded)
        return;
    [Settings loadSettings];
    hasloaded = YES;
}

@end
