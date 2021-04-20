//
//  GesturePreviewView.h
//  Jitouch
//
//  Copyright 2021 Supasorn Suwajanakorn and Sukolsak Sakshuwong. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef struct {
    float x[2],y[2];
    float cpx[2], cpy[2];
    double t[4];
    float len;
    int pressed;
    int type;
} FingerGesture;

typedef struct {
    FingerGesture fg[10];
    int n;
    double t;
    int type;
} HandGesture;

@interface GesturePreviewView : NSView {
    NSTimer *timer;
    HandGesture hg;
    int counter;
    int handed;
    NSString *ges;
    int device;
    int lastI;
}

- (id)initWithDevice:(int)aDevice;
- (void)create:(NSString*)gesture forDevice:(int)aDevice;
- (void)startTimer;
- (void)stopTimer;

@property (nonatomic) int handed;
@property (nonatomic, retain) NSString *ges;

@end
