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

#import "AutoSetDelegate.h"
#import "Settings.h"

#define TOUCHEXAM 10
#define px normalized.pos.x
#define py normalized.pos.y

@implementation AutoSetDelegate

// Based on the code at http://steike.com/code/multitouch
typedef struct { float x, y; } MTPoint;
typedef struct { MTPoint pos, vel; } MTReadout;

typedef struct {
    int frame;
    double timestamp;
    int identifier, state, fingerId, handId;
    MTReadout normalized;
    float size;
    int zero1;
    float angle, majorAxis, minorAxis; // ellipsoid
    MTReadout mm;
    int zero2[2];
    float zDensity;
} Finger;

typedef void *MTDeviceRef;
typedef int (*MTContactCallbackFunction)(int, Finger*, int, double, int);

MTDeviceRef MTDeviceCreateDefault(void);
void MTRegisterContactFrameCallback(MTDeviceRef, MTContactCallbackFunction);
void MTDeviceStart(MTDeviceRef, int);

static int touchState = 0;

static float dx[2][TOUCHEXAM];
static int dxCount[2];

static NSTextField *_counter;
static NSTextField *_fingersName;
static NSWindow *_autoSetWindow;
static NSSlider *_indexRing;

static void setIndexRing() {
    charRegIndexRingDistance = [_indexRing floatValue] / 100;
    [Settings setKey:@"charRegIndexRingDistance" withFloat:charRegIndexRingDistance];
    [Settings noteSettingsUpdated];
}

static int callback(int device, Finger *data, int nFingers, double timestamp, int frame) {
    static int waitForRelease = 1;
    if (touchState == 1) {
        if (!waitForRelease && nFingers == 2) {
            dx[dxCount[0]][dxCount[1]++] = fabs(data[0].px - data[1].px);
            if (dxCount[1] == TOUCHEXAM) {
                dxCount[0]++;
                dxCount[1] = 0;
                if (dxCount[0] == 1)
                    [_fingersName setStringValue:@"Index and Ring fingers"];
                if (dxCount[0] == 2) {
                    touchState = 2;
                    [_fingersName setStringValue:@"Index and Middle fingers"];
                }
            }
            [_counter setStringValue:[NSString stringWithFormat:@"%d Time%c", TOUCHEXAM - dxCount[1], TOUCHEXAM - dxCount[1] == 1 ? ' ' : 's'] ];
            waitForRelease = 1;
        } else if (nFingers == 0) {
            waitForRelease = 0;
        }
    } else if (touchState == 2) {
        touchState = 0;
        waitForRelease = 1;

        float val;
        float minV = 1, maxV = 0;
        for (int i = 0; i < TOUCHEXAM; i++) {
            if (dx[0][i] > maxV)
                maxV = dx[0][i];
            if (dx[1][i] < minV)
                minV = dx[1][i];
        }
        val = (maxV + minV) / 2 * 100;
        [_indexRing setFloatValue:val];
        setIndexRing();

        [NSApp performSelectorOnMainThread:@selector(endSheet:) withObject:_autoSetWindow waitUntilDone:NO];
    }
    return 0;
}

- (IBAction)done:(id)sender {
    [NSApp endSheet:advancedWindow];
}

- (IBAction)doneAutoSet:(id)sender {
    [NSApp endSheet:autoSetWindow];
    touchState = 0;
    //[_window orderOut:nil];
    [Settings setKey:@"charRegIndexRingDistance" withFloat:charRegIndexRingDistance];
    [Settings noteSettingsUpdated];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo{
    [sheet orderOut:self];
}

- (IBAction)change:(id)sender {
    if (sender == autoSetButton || sender == restartButton) {
        if (sender == autoSetButton) {
            /*[autoSetWindow display];
            [autoSetWindow setLevel:NSScreenSaverWindowLevel];
            [autoSetWindow makeKeyAndOrderFront:nil];
            */
            [NSApp beginSheet: autoSetWindow
               modalForWindow: advancedWindow
                modalDelegate: self
               didEndSelector: @selector(didEndSheet:returnCode:contextInfo:)
                  contextInfo: nil];
        }
        touchState = 1;
        dxCount[0] = 0;
        dxCount[1] = 0;
        [_fingersName setStringValue:@"Index and Middle fingers"];
        [_counter setStringValue:[NSString stringWithFormat:@"%d Times", TOUCHEXAM]];

        // Temporarily disable character recognition by setting the dist = 1
        [Settings setKey:@"charRegIndexRingDistance" withFloat:1.0];
        [Settings noteSettingsUpdated];
    } else if (sender == indexRing) {
        setIndexRing();
    } else if (sender == resetButton) {
        [indexRing setFloatValue:33];
        setIndexRing();
    } else if (sender == mouseButton) {
        charRegMouseButton = (int)[sender selectedColumn];
        [Settings setKey:@"charRegMouseButton" withInt:charRegMouseButton];
        [Settings noteSettingsUpdated];
    } else if (sender == oneDrawing) {
        enOneDrawing = ([sender state] == NSOnState);
        [Settings setKey:@"enOneDrawing" withInt:enOneDrawing];
        [Settings noteSettingsUpdated];
    } else if (sender == twoDrawing) {
        enTwoDrawing = ([sender state] == NSOnState);
        [Settings setKey:@"enTwoDrawing" withInt:enTwoDrawing];
        [Settings noteSettingsUpdated];
    }
}

- (void)awakeFromNib {
    MTDeviceRef dev = MTDeviceCreateDefault();
    MTRegisterContactFrameCallback(dev, callback);
    MTDeviceStart(dev, 0);

    _counter = counter;
    _fingersName = fingersName;
    _autoSetWindow = autoSetWindow;
    _indexRing = indexRing;
}

@end
