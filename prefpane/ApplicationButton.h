//
//  ApplicationButton.h
//  Jitouch
//
//  Copyright 2021 Supasorn Suwajanakorn and Sukolsak Sakshuwong. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ApplicationButton : NSPopUpButton

- (void)addApplication:(NSString*)path;
- (NSString*)pathOfSelectedItem;

@end
