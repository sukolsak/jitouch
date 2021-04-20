//
//  KeyTextField.h
//  Jitouch
//
//  Copyright 2021 Supasorn Suwajanakorn and Sukolsak Sakshuwong. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface KeyTextField : NSTextField {
    NSUInteger modifierFlags;
    unsigned short keyCode;
}

@property (nonatomic) NSUInteger modifierFlags;
@property (nonatomic) unsigned short keyCode;

@end
