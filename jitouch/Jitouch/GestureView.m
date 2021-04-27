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

#import "GestureView.h"

@implementation GestureView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        points = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor clearColor] set];
    NSRectFill([self frame]);

    CGContextRef context = [[NSGraphicsContext currentContext]graphicsPort];

    if ([points count] > 0) {
        NSPoint currentPoint;
        CGContextSetLineWidth(context, 12.0);

        currentPoint = [[points objectAtIndex:0] pointValue];
        CGContextSetRGBStrokeColor(context, 0.7, 0, 0, 0.6);
        CGContextStrokeEllipseInRect(context, CGRectMake(currentPoint.x-15, currentPoint.y-15, 30, 30));

        CGContextSetRGBStrokeColor(context, 1, 1, 1, 0.3);
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetLineJoin(context, kCGLineJoinRound);

        NSPoint startPoint = [[points objectAtIndex:0] pointValue];
        CGContextMoveToPoint(context, startPoint.x, startPoint.y);
        float minX = 10000, minY = 10000;
        for (NSUInteger i = 1; i < [points count]; i++) {
            currentPoint = [[points objectAtIndex:i] pointValue];
            CGContextAddLineToPoint(context, currentPoint.x, currentPoint.y);
            if (currentPoint.x < minX)
                minX = currentPoint.x;
            if (currentPoint.y < minY)
                minY = currentPoint.y;
        }
        CGContextStrokePath(context);

        CGContextSetLineWidth(context, 10.0);
        CGContextSetRGBStrokeColor(context, 0, 0, 0, 0.6);
        CGContextMoveToPoint(context, startPoint.x, startPoint.y);
        for (NSUInteger i = 1; i < [points count]; i++) {
            currentPoint = [[points objectAtIndex:i] pointValue];
            CGContextAddLineToPoint(context, currentPoint.x, currentPoint.y);
        }
        CGContextStrokePath(context);

        [[NSString stringWithUTF8String:hintText]
         drawAtPoint:CGPointMake(minX, minY - 70.0)
         withAttributes:@{
                          NSFontAttributeName: [NSFont systemFontOfSize:40.0],
                          NSForegroundColorAttributeName: [NSColor colorWithRed:0.7 green:0.0 blue:0.0 alpha:0.5]
                          }];
    }
}

- (void)addPointX:(float)x Y:(float)y {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    CGFloat width = [self frame].size.width - 30 - 150;
    CGFloat height = [self frame].size.height - 30 - 100;

    NSValue *point = [NSValue valueWithPoint:NSMakePoint(x*width + 15, y*height + 15 + 100)];
    [points addObject:point];
    [pool release];

    [self setNeedsDisplay:YES];
}

- (void)addRelativePointX:(float)x Y:(float)y {
    CGFloat width = [self frame].size.width;
    CGFloat height = [self frame].size.height;

    NSValue *point = [NSValue valueWithPoint:NSMakePoint(width/2 + x, height/2 + y)];
    [points addObject:point];
    [self setNeedsDisplay:YES];
}

- (void)clear {
    [points removeAllObjects];
    [self setNeedsDisplay:YES];
}

- (void)setHintText:(const char*)str {
    strcpy(hintText, str);
}

- (void)dealloc {
    [points release];
    [super dealloc];
}

@end
