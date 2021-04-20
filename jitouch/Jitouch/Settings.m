//
//  Settings.m
//  Jitouch
//
//  Copyright 2021 Supasorn Suwajanakorn and Sukolsak Sakshuwong. All rights reserved.
//

#import "Settings.h"
#import <CoreFoundation/CFPreferences.h>
#import <CoreFoundation/CoreFoundation.h>

#define kGesture @"Gesture"
#define kCommand @"Command"
#define kIsAction @"IsAction"
#define ModifierFlags @"ModifierFlags"
#define kKeyCode @"KeyCode"
#define kEnable @"Enable"

#define ADD_GESTURE(a, gesture, command) [a addObject:[NSDictionary dictionaryWithObjectsAndKeys:gesture, @"Gesture", command, @"Command", @YES, @"IsAction", @0, @"ModifierFlags", @0, @"KeyCode", [NSNumber numberWithInt:NSOnState], @"Enable", nil]];

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


@implementation Settings

static int notSynchronize;

+ (void)noteSettingsUpdated2 {
    NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName: @"My Notification2"
                                                                   object: @"com.jitouch.Jitouch.PrefpaneTarget2"
                                                                 userInfo: @{
     @"enAll": [NSNumber numberWithInt:enAll]
     }
                                                       deliverImmediately: YES];
    [autoreleasepool release];
}


+ (void)setKey:(NSString*)aKey withInt:(int)aValue{
    CFNumberRef value = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &aValue);
    CFPreferencesSetAppValue((CFStringRef)aKey, value, appID);
    CFRelease(value);
    if (!notSynchronize)
        CFPreferencesAppSynchronize(appID);
}

+ (void)setKey:(NSString*)aKey withFloat:(float)aValue{
    CFNumberRef value = CFNumberCreate(kCFAllocatorDefault, kCFNumberFloatType, &aValue);
    CFPreferencesSetAppValue((CFStringRef)aKey, value, appID);
    CFRelease(value);
    if (!notSynchronize)
        CFPreferencesAppSynchronize(appID);
}

+ (void)setKey:(NSString*)aKey with:(id)aValue {
    CFPropertyListRef value = (CFPropertyListRef)aValue;
    CFPreferencesSetAppValue((CFStringRef)aKey, value, appID);
    //CFRelease(value);
    if (!notSynchronize)
        CFPreferencesAppSynchronize(appID);
}

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

    ADD_GESTURE(gestures1, @"/ Up", @"Maximize");
    ADD_GESTURE(gestures1, @"Left", @"Maximize Left");
    ADD_GESTURE(gestures1, @"Right", @"Maximize Right");
    ADD_GESTURE(gestures1, @"/ Down", @"Un-Maximize");

    NSDictionary *app1 = [NSDictionary dictionaryWithObjectsAndKeys:@"All Applications", @"Application", @"", @"Path", gestures1, @"Gestures", nil];

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

    NSDictionary *app1 = [NSDictionary dictionaryWithObjectsAndKeys:@"All Applications", @"Application", @"", @"Path", gestures1, @"Gestures", nil];

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

    NSDictionary *app1 = [NSDictionary dictionaryWithObjectsAndKeys:@"All Applications", @"Application", @"", @"Path", gestures1, @"Gestures", nil];

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

+ (void)loadSettings2:(NSDictionary*)newSettings {
    if (!newSettings)
        return;

    if (settings != newSettings) {
        [settings release];
        settings = [[NSMutableDictionary alloc] initWithDictionary:newSettings];
    }

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
}

+ (void)loadSettings {
    NSString *plistPath = [@"~/Library/Preferences/com.jitouch.Jitouch.plist" stringByStandardizingPath];

    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSString *errorDesc = nil;
    NSDictionary *newSettings = [NSPropertyListSerialization
                             propertyListFromData:plistXML
                             mutabilityOption:NSPropertyListMutableContainersAndLeaves
                             format:NULL
                             errorDescription:&errorDesc];
    [Settings loadSettings2:newSettings];
}

+ (void)loadSettings:(id)sender {
    @synchronized(sender) {
        if (hasloaded)
            return;
        [Settings loadSettings];
        hasloaded = YES;
    }
}

@end
