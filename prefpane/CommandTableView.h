//
//  CommandTableView.h
//  Jitouch
//
//  Copyright 2021 Supasorn Suwajanakorn and Sukolsak Sakshuwong. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CommandTableView : NSTableView {
    NSUInteger modifierFlags;
    unsigned short keyCode;
}

@property NSUInteger modifierFlags;
@property unsigned short keyCode;

@end
