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

#import "KeyTextView.h"
#import <Carbon/Carbon.h>
#import "KeyTextField.h"
#import "CommandTableView.h"
#import "Settings.h"

@implementation KeyTextView

- (BOOL)becomeFirstResponder {
    if (eventKeyboard) CGEventTapEnable(eventKeyboard, true);
    return YES;
}

- (BOOL)resignFirstResponder {
    if (eventKeyboard) CGEventTapEnable(eventKeyboard, false);
    return YES;
}

- (void)handleEventKeyCode:(int64_t)keyCode flags:(CGEventFlags)flags {
    NSString *modifierKeys = @"";

    if (flags & kCGEventFlagMaskControl) {
        modifierKeys = [modifierKeys stringByAppendingString:@"⌃"];
    }
    if (flags & kCGEventFlagMaskAlternate) {
        modifierKeys = [modifierKeys stringByAppendingString:@"⌥"];
    }
    if (flags & kCGEventFlagMaskShift) {
        modifierKeys = [modifierKeys stringByAppendingString:@"⇧"];
    }
    if (flags & kCGEventFlagMaskCommand) {
        modifierKeys = [modifierKeys stringByAppendingString:@"⌘"];
    }

    NSString *chr;
    if (keyCode == 123) { //left
        chr = @"←";
    } else if (keyCode == 124) { //right
        chr = @"→";
    } else if (keyCode == 125) { //down
        chr = @"↓";
    } else if (keyCode == 126) { //up
        chr = @"↑";
    } else if (keyCode == 36) { //return
        chr = @"↩";
    } else if (keyCode == 48) { //tab
        chr = @"⇥";
    } else if (keyCode == 49) { //space
        chr = @"Space";
    } else if (keyCode == 51) { //delete
        chr = @"⌫";
    } else if (keyCode == 53) { //escape
        chr = @"⎋";
    } else if (keyCode == 117) { //forward delete
        chr = @"⌦";
    } else if (keyCode == 76) { //enter
        chr = @"⌅";
    } else if (keyCode == 116) { //page up
        chr = @"Page Up";
    } else if (keyCode == 121) { //page down
        chr = @"Page Down";
    } else if (keyCode == 115) { //home
        chr = @"Home";
    } else if (keyCode == 119) { //end
        chr = @"End";
    } else if (keyCode == 122) { //
        chr = @"F1";
    } else if (keyCode == 120) { //
        chr = @"F2";
    } else if (keyCode == 99) { //
        chr = @"F3";
    } else if (keyCode == 118) { //
        chr = @"F4";
    } else if (keyCode == 96) { //
        chr = @"F5";
    } else if (keyCode == 97) { //
        chr = @"F6";
    } else if (keyCode == 98) { //
        chr = @"F7";
    } else if (keyCode == 100) { //
        chr = @"F8";
    } else if (keyCode == 101) { //
        chr = @"F9";
    } else if (keyCode == 109) { //
        chr = @"F10";
    } else if (keyCode == 103) { //
        chr = @"F11";
    } else if (keyCode == 111) { //
        chr = @"F12";
    } else {
        UInt32 deadKeyState = 0;
        UniCharCount actualCount = 0;
        UniChar baseChar;
        TISInputSourceRef sourceRef = TISCopyCurrentKeyboardLayoutInputSource();
        CFDataRef keyLayoutPtr = (CFDataRef)TISGetInputSourceProperty( sourceRef, kTISPropertyUnicodeKeyLayoutData);
        CFRelease( sourceRef);
        UCKeyTranslate( (UCKeyboardLayout*)CFDataGetBytePtr(keyLayoutPtr),
                       keyCode,
                       kUCKeyActionDown,
                       0,
                       LMGetKbdType(),
                       kUCKeyTranslateNoDeadKeysBit,
                       &deadKeyState,
                       1,
                       &actualCount,
                       &baseChar);
        chr = [[NSString stringWithFormat:@"%c", baseChar] capitalizedString];
    }


    modifierKeys = [modifierKeys stringByAppendingString:chr];
    [self replaceCharactersInRange:NSMakeRange(0, [[self.textStorage mutableString] length])
                        withString:modifierKeys];
    if ([[self delegate] isKindOfClass:[KeyTextField class]]) {
        KeyTextField *textField = (KeyTextField*)[self delegate];
        textField.modifierFlags = flags;
        textField.keyCode = keyCode;
        [self selectAll:nil];
        //[self didChangeText];
        //[textField textDidChange:nil];
        [textField sendAction:[textField action] to:[textField target]];
    }
}

- (void)keyDown:(NSEvent *)theEvent {
    if (eventKeyboard)
        CGEventTapEnable(eventKeyboard, true); //in case something goes wrong
}

@end
