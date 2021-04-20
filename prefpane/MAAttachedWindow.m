//
//  MAAttachedWindow.m
//
//  Created by Matt Gemmell on 27/09/2007.
//  Copyright 2007 Magic Aubergine.
//

#import "MAAttachedWindow.h"

#define MAATTACHEDWINDOW_DEFAULT_BACKGROUND_COLOR [NSColor colorWithCalibratedWhite:0.1 alpha:0.75]
#define MAATTACHEDWINDOW_DEFAULT_BORDER_COLOR [NSColor whiteColor]
#define MAATTACHEDWINDOW_SCALE_FACTOR 1.0

@interface MAAttachedWindow (MAPrivateMethods)

// Geometry
- (void)_updateGeometry;
- (float)_arrowInset;

// Drawing
- (void)_updateBackground;
- (NSColor *)_backgroundColorPatternImage;
- (NSBezierPath *)_backgroundPath;
- (void)_appendArrowToPath:(NSBezierPath *)path;
- (void)_redisplay;

@end

@implementation MAAttachedWindow


#pragma mark Initializers


- (MAAttachedWindow *)initWithView:(NSView *)view
                   attachedToPoint:(NSPoint)point
                          inWindow:(NSWindow *)window
                            onSide:(MAWindowPosition)side
                        atDistance:(float)distance
{
    // Insist on having a valid view.
    if (!view) {
        return nil;
    }

    // Create dummy initial contentRect for window.
    NSRect contentRect = NSZeroRect;
    contentRect.size = [view frame].size;

    if ((self = [super initWithContentRect:contentRect
                                 styleMask:NSBorderlessWindowMask
                                   backing:NSBackingStoreBuffered
                                     defer:NO])) {
        _view = view;
        _window = window;
        _point = point;
        _side = side;
        _distance = distance;

        // Configure window characteristics.
        [super setBackgroundColor:[NSColor clearColor]];
        [self setMovableByWindowBackground:NO];
        [self setExcludedFromWindowsMenu:YES];
        [self setAlphaValue:1.0];
        [self setOpaque:NO];
        [self setHasShadow:YES];
        [self useOptimizedDrawing:YES];

        // Set up some sensible defaults for display.
        _MABackgroundColor = [MAATTACHEDWINDOW_DEFAULT_BACKGROUND_COLOR copy];
        borderColor = [MAATTACHEDWINDOW_DEFAULT_BORDER_COLOR copy];
        borderWidth = 2.0;
        viewMargin = 2.0;
        arrowBaseWidth = 20.0;
        arrowHeight = 16.0;
        hasArrow = YES;
        cornerRadius = 8.0;
        drawsRoundCornerBesideArrow = YES;
        _resizing = NO;


        // Configure our initial geometry.
        [self _updateGeometry];

        // Update the background.
        [self _updateBackground];

        // Add view as subview of our contentView.
        [[self contentView] addSubview:_view];

        // Subscribe to notifications for when we change size.
        /*
         [[NSNotificationCenter defaultCenter] addObserver:self
         selector:@selector(windowDidResize:)
         name:NSWindowDidResizeNotification
         object:self];
         */
    }
    return self;
}


- (MAAttachedWindow *)initWithView:(NSView *)view
                   attachedToPoint:(NSPoint)point
                          inWindow:(NSWindow *)window
                        atDistance:(float)distance
{
    return [self initWithView:view attachedToPoint:point
                     inWindow:window onSide:MAPositionAutomatic
                   atDistance:distance];
}


- (MAAttachedWindow *)initWithView:(NSView *)view
                   attachedToPoint:(NSPoint)point
                            onSide:(MAWindowPosition)side
                        atDistance:(float)distance
{
    return [self initWithView:view attachedToPoint:point
                     inWindow:nil onSide:side
                   atDistance:distance];
}


- (MAAttachedWindow *)initWithView:(NSView *)view
                   attachedToPoint:(NSPoint)point
                        atDistance:(float)distance
{
    return [self initWithView:view attachedToPoint:point
                     inWindow:nil onSide:MAPositionAutomatic
                   atDistance:distance];
}


- (MAAttachedWindow *)initWithView:(NSView *)view
                   attachedToPoint:(NSPoint)point
                          inWindow:(NSWindow *)window
{
    return [self initWithView:view attachedToPoint:point
                     inWindow:window onSide:MAPositionAutomatic
                   atDistance:0];
}


- (MAAttachedWindow *)initWithView:(NSView *)view
                   attachedToPoint:(NSPoint)point
                            onSide:(MAWindowPosition)side
{
    return [self initWithView:view attachedToPoint:point
                     inWindow:nil onSide:side
                   atDistance:0];
}


- (MAAttachedWindow *)initWithView:(NSView *)view
                   attachedToPoint:(NSPoint)point
{
    return [self initWithView:view attachedToPoint:point
                     inWindow:nil onSide:MAPositionAutomatic
                   atDistance:0];
}


- (void)dealloc
{
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
    [borderColor release];
    [_MABackgroundColor release];

    [super dealloc];
}


#pragma mark Geometry


- (void)_updateGeometry
{
    NSRect contentRect = NSZeroRect;
    contentRect.size = [_view frame].size;

    // Account for viewMargin.
    _viewFrame = NSMakeRect(viewMargin * MAATTACHEDWINDOW_SCALE_FACTOR,
                            viewMargin * MAATTACHEDWINDOW_SCALE_FACTOR,
                            [_view frame].size.width, [_view frame].size.height);
    contentRect = NSInsetRect(contentRect,
                              -viewMargin * MAATTACHEDWINDOW_SCALE_FACTOR,
                              -viewMargin * MAATTACHEDWINDOW_SCALE_FACTOR);

    // Account for arrowHeight in new window frame.
    // Note: we always leave room for the arrow, even if it currently set to
    // not be shown. This is so it can easily be toggled whilst the window
    // is visible, without altering the window's frame origin point.
    float scaledArrowHeight = arrowHeight * MAATTACHEDWINDOW_SCALE_FACTOR;
    switch (_side) {
        case MAPositionLeft:
        case MAPositionLeftTop:
        case MAPositionLeftBottom:
            contentRect.size.width += scaledArrowHeight;
            break;
        case MAPositionRight:
        case MAPositionRightTop:
        case MAPositionRightBottom:
            _viewFrame.origin.x += scaledArrowHeight;
            contentRect.size.width += scaledArrowHeight;
            break;
        case MAPositionTop:
        case MAPositionTopLeft:
        case MAPositionTopRight:
            _viewFrame.origin.y += scaledArrowHeight;
            contentRect.size.height += scaledArrowHeight;
            break;
        case MAPositionBottom:
        case MAPositionBottomLeft:
        case MAPositionBottomRight:
            contentRect.size.height += scaledArrowHeight;
            break;
        default:
            break; // won't happen, but this satisfies gcc with -Wall
    }

    // Position frame origin appropriately for _side, accounting for arrow-inset.
    contentRect.origin = (_window) ? [_window convertPointToScreen:_point] : _point;
    float arrowInset = [self _arrowInset];
    float halfWidth = contentRect.size.width / 2.0;
    float halfHeight = contentRect.size.height / 2.0;
    switch (_side) {
        case MAPositionTopLeft:
            contentRect.origin.x -= contentRect.size.width - arrowInset;
            break;
        case MAPositionTop:
            contentRect.origin.x -= halfWidth;
            break;
        case MAPositionTopRight:
            contentRect.origin.x -= arrowInset;
            break;
        case MAPositionBottomLeft:
            contentRect.origin.y -= contentRect.size.height;
            contentRect.origin.x -= contentRect.size.width - arrowInset;
            break;
        case MAPositionBottom:
            contentRect.origin.y -= contentRect.size.height;
            contentRect.origin.x -= halfWidth;
            break;
        case MAPositionBottomRight:
            contentRect.origin.x -= arrowInset;
            contentRect.origin.y -= contentRect.size.height;
            break;
        case MAPositionLeftTop:
            contentRect.origin.x -= contentRect.size.width;
            contentRect.origin.y -= arrowInset;
            break;
        case MAPositionLeft:
            contentRect.origin.x -= contentRect.size.width;
            contentRect.origin.y -= halfHeight;
            break;
        case MAPositionLeftBottom:
            contentRect.origin.x -= contentRect.size.width;
            contentRect.origin.y -= contentRect.size.height - arrowInset;
            break;
        case MAPositionRightTop:
            contentRect.origin.y -= arrowInset;
            break;
        case MAPositionRight:
            contentRect.origin.y -= halfHeight;
            break;
        case MAPositionRightBottom:
            contentRect.origin.y -= contentRect.size.height - arrowInset;
            break;
        default:
            break; // won't happen, but this satisfies gcc with -Wall
    }

    // Account for _distance in new window frame.
    switch (_side) {
        case MAPositionLeft:
        case MAPositionLeftTop:
        case MAPositionLeftBottom:
            contentRect.origin.x -= _distance;
            break;
        case MAPositionRight:
        case MAPositionRightTop:
        case MAPositionRightBottom:
            contentRect.origin.x += _distance;
            break;
        case MAPositionTop:
        case MAPositionTopLeft:
        case MAPositionTopRight:
            contentRect.origin.y += _distance;
            break;
        case MAPositionBottom:
        case MAPositionBottomLeft:
        case MAPositionBottomRight:
            contentRect.origin.y -= _distance;
            break;
        default:
            break; // won't happen, but this satisfies gcc with -Wall
    }

    // Reconfigure window and view frames appropriately.
    [self setFrame:contentRect display:NO];
    [_view setFrame:_viewFrame];
}


- (float)_arrowInset
{
    float cornerInset = (drawsRoundCornerBesideArrow) ? cornerRadius : 0;
    return (cornerInset + (arrowBaseWidth / 2.0)) * MAATTACHEDWINDOW_SCALE_FACTOR;
}


#pragma mark Drawing


- (void)_updateBackground
{
    // Call NSWindow's implementation of -setBackgroundColor: because we override
    // it in this class to let us set the entire background image of the window
    // as an NSColor patternImage.
    NSDisableScreenUpdates();
    [super setBackgroundColor:[self _backgroundColorPatternImage]];
    if ([self isVisible]) {
        [self display];
        [self invalidateShadow];
    }
    NSEnableScreenUpdates();
}


- (NSColor *)_backgroundColorPatternImage
{
    NSImage *bg = [[NSImage alloc] initWithSize:[self frame].size];
    NSRect bgRect = NSZeroRect;
    bgRect.size = [bg size];

    [bg lockFocus];
    NSBezierPath *bgPath = [self _backgroundPath];
    [NSGraphicsContext saveGraphicsState];
    [bgPath addClip];

    // Draw background.
    [_MABackgroundColor set];
    [bgPath fill];
    //[bgPath stroke];

    [NSGraphicsContext restoreGraphicsState];
    [bg unlockFocus];

    return [NSColor colorWithPatternImage:[bg autorelease]];
}


- (NSBezierPath *)_backgroundPath
{
    /*
     Construct path for window background, taking account of:
     1. hasArrow
     2. _side
     3. drawsRoundCornerBesideArrow
     4. arrowBaseWidth
     5. arrowHeight
     6. cornerRadius
     */

    float scaleFactor = MAATTACHEDWINDOW_SCALE_FACTOR;
    float scaledRadius = cornerRadius * scaleFactor;
    float scaledArrowWidth = arrowBaseWidth * scaleFactor;
    float halfArrowWidth = scaledArrowWidth / 2.0;
    NSRect contentArea = NSInsetRect(_viewFrame,
                                     -viewMargin * scaleFactor,
                                     -viewMargin * scaleFactor);
    float minX = ceilf(NSMinX(contentArea) * scaleFactor + 0.5f);
    //float midX = NSMidX(contentArea) * scaleFactor;
    float maxX = floorf(NSMaxX(contentArea) * scaleFactor - 0.5f);
    float minY = ceilf(NSMinY(contentArea) * scaleFactor + 0.5f);
    float midY = NSMidY(contentArea) * scaleFactor;
    float maxY = floorf(NSMaxY(contentArea) * scaleFactor - 0.5f);

    NSBezierPath *path2;

    if (_device == 0) { //Trackpad

        path2 = [NSBezierPath bezierPath];
        [path2 moveToPoint:NSMakePoint(0,0)];
        [path2 appendBezierPathWithRoundedRect:NSMakeRect(minX, minY, maxX-minX, maxY-minY) xRadius:scaledRadius yRadius:scaledRadius];
        [path2 closePath];

        NSBezierPath *path3 = [NSBezierPath bezierPath];
        [path3 moveToPoint:NSMakePoint(maxX, midY + halfArrowWidth)];
        [self _appendArrowToPath:path3];
        [path3 closePath];

        [path2 appendBezierPath:path3];

    } else {

        float w = maxX - minX;
        float h = maxY - minY;
        /*
        path2 = [NSBezierPath bezierPath];
        [path2 moveToPoint:NSMakePoint((0.5-0.163)*w,(0.5-0.495)*h)];
        [path2 curveToPoint:NSMakePoint(0.5*w, 0*h) controlPoint1:NSMakePoint((0.5-0.079)*w, (0.5-0.499)*h) controlPoint2:NSMakePoint((0.5-0.079)*w, (0.5-0.499)*h)];
        [path2 curveToPoint:NSMakePoint((0.5+0.163)*w, (0.5-0.495)*h) controlPoint1:NSMakePoint((0.5+0.079)*w, (0.5-0.499)*h) controlPoint2:NSMakePoint((0.5+0.084)*w, (0.5-0.499)*h)];
        [path2 curveToPoint:NSMakePoint((0.5+0.48)*w, (0.5-0.316)*h) controlPoint1:NSMakePoint((0.5+0.321)*w, (0.5-0.483)*h) controlPoint2:NSMakePoint((0.5+0.449)*w, (0.5-0.451)*h)];
        [path2 curveToPoint:NSMakePoint((0.5+0.48)*w, (0.5+0.316)*h) controlPoint1:NSMakePoint((0.5+0.516)*w, (0.5-0.177)*h) controlPoint2:NSMakePoint((0.5+0.516)*w, (0.5+0.177)*h)];
        [path2 curveToPoint:NSMakePoint((0.5+0.163)*w, (0.5+0.495)*h) controlPoint1:NSMakePoint((0.5+0.449)*w, (0.5+0.451)*h) controlPoint2:NSMakePoint((0.5+0.321)*w, (0.5+0.483)*h)];
        [path2 curveToPoint:NSMakePoint(0.5*w, 1*h) controlPoint1:NSMakePoint((0.5+0.084)*w, (0.5+0.499)*h) controlPoint2:NSMakePoint((0.5+0.079)*w, (0.5+0.499)*h) ];
        [path2 curveToPoint:NSMakePoint((0.5-0.163)*w,(0.5+0.495)*h) controlPoint1:NSMakePoint((0.5-0.079)*w, (0.5+0.499)*h) controlPoint2:NSMakePoint((0.5-0.079)*w, (0.5+0.499)*h) ];
        [path2 curveToPoint:NSMakePoint((0.5-0.48)*w, (0.5+0.316)*h) controlPoint1:NSMakePoint((0.5-0.321)*w, (0.5+0.483)*h) controlPoint2:NSMakePoint((0.5-0.449)*w, (0.5+0.451)*h)];
        [path2 curveToPoint:NSMakePoint((0.5-0.48)*w, (0.5-0.316)*h) controlPoint1:NSMakePoint((0.5-0.516)*w, (0.5+0.177)*h) controlPoint2:NSMakePoint((0.5-0.516)*w, (0.5-0.177)*h)];
        [path2 curveToPoint:NSMakePoint((0.5-0.163)*w, (0.5-0.495)*h) controlPoint1:NSMakePoint((0.5-0.449)*w, (0.5-0.451)*h) controlPoint2:NSMakePoint((0.5-0.321)*w, (0.5-0.483)*h)];
        [path2 closePath];
         */

        path2 = [NSBezierPath bezierPath];
        [path2 moveToPoint:NSMakePoint((0.5-0.163)*w,(0.5+0.495)*h)];
        [path2 curveToPoint:NSMakePoint(0.5*w, 1*h) controlPoint1:NSMakePoint((0.5-0.079)*w, (0.5+0.499)*h) controlPoint2:NSMakePoint((0.5-0.079)*w, (0.5+0.499)*h)];
        [path2 curveToPoint:NSMakePoint((0.5+0.163)*w, (0.5+0.495)*h) controlPoint1:NSMakePoint((0.5+0.079)*w, (0.5+0.499)*h) controlPoint2:NSMakePoint((0.5+0.084)*w, (0.5+0.499)*h)];
        [path2 curveToPoint:NSMakePoint((0.5+0.48)*w, (0.5+0.316)*h) controlPoint1:NSMakePoint((0.5+0.321)*w, (0.5+0.483)*h) controlPoint2:NSMakePoint((0.5+0.449)*w, (0.5+0.451)*h)];

        [path2 curveToPoint:NSMakePoint(maxX-1, midY + halfArrowWidth) controlPoint1:NSMakePoint((0.5+0.516 - (0.516-0.48)/2)*w, (0.5+0.177 - (0.177-0.316)/2)*h) controlPoint2:NSMakePoint(maxX-1, midY + halfArrowWidth)];

        //[path2 lineToPoint:NSMakePoint(maxX-2, midY + halfArrowWidth)];
        [self _appendArrowToPath:path2];

        [path2 curveToPoint:NSMakePoint((0.5+0.48)*w, (0.5-0.316)*h) controlPoint1:NSMakePoint(maxX-1, midY - halfArrowWidth) controlPoint2:NSMakePoint((0.5+0.516 - (0.516-0.48)/2)*w, (0.5-0.177 - (-0.177+0.316)/2)*h)];

        //[path2 curveToPoint:NSMakePoint((0.5+0.48)*w, (0.5-0.316)*h) controlPoint1:NSMakePoint((0.5+0.516)*w, (0.5+0.177)*h) controlPoint2:NSMakePoint((0.5+0.516)*w, (0.5-0.177)*h)];

        [path2 curveToPoint:NSMakePoint((0.5+0.163)*w, (0.5-0.495)*h) controlPoint1:NSMakePoint((0.5+0.449)*w, (0.5-0.451)*h) controlPoint2:NSMakePoint((0.5+0.321)*w, (0.5-0.483)*h)];
        [path2 curveToPoint:NSMakePoint(0.5*w, 0*h) controlPoint1:NSMakePoint((0.5+0.084)*w, (0.5-0.499)*h) controlPoint2:NSMakePoint((0.5+0.079)*w, (0.5-0.499)*h) ];
        [path2 curveToPoint:NSMakePoint((0.5-0.163)*w,(0.5-0.495)*h) controlPoint1:NSMakePoint((0.5-0.079)*w, (0.5-0.499)*h) controlPoint2:NSMakePoint((0.5-0.079)*w, (0.5-0.499)*h) ];
        [path2 curveToPoint:NSMakePoint((0.5-0.48)*w, (0.5-0.316)*h) controlPoint1:NSMakePoint((0.5-0.321)*w, (0.5-0.483)*h) controlPoint2:NSMakePoint((0.5-0.449)*w, (0.5-0.451)*h)];
        [path2 curveToPoint:NSMakePoint((0.5-0.48)*w, (0.5+0.316)*h) controlPoint1:NSMakePoint((0.5-0.516)*w, (0.5-0.177)*h) controlPoint2:NSMakePoint((0.5-0.516)*w, (0.5+0.177)*h)];
        [path2 curveToPoint:NSMakePoint((0.5-0.163)*w, (0.5+0.495)*h) controlPoint1:NSMakePoint((0.5-0.449)*w, (0.5+0.451)*h) controlPoint2:NSMakePoint((0.5-0.321)*w, (0.5+0.483)*h)];

         [path2 closePath];
    }

    return path2;
}


- (void)_appendArrowToPath:(NSBezierPath *)path
{
    if (!hasArrow) {
        return;
    }

    float scaleFactor = MAATTACHEDWINDOW_SCALE_FACTOR;
    float scaledArrowWidth = arrowBaseWidth * scaleFactor;
    float halfArrowWidth = scaledArrowWidth / 2.0;
    float scaledArrowHeight = arrowHeight * scaleFactor;
    NSPoint currPt = [path currentPoint];
    NSPoint tipPt = currPt;
    NSPoint endPt = currPt;

    // Note: we always build the arrow path in a clockwise direction.
    switch (_side) {
        case MAPositionLeft:
        case MAPositionLeftTop:
        case MAPositionLeftBottom:
            // Arrow points towards right. We're starting from the top.
            tipPt.x += scaledArrowHeight;
            tipPt.y -= halfArrowWidth;
            endPt.y -= scaledArrowWidth;
            break;
        case MAPositionRight:
        case MAPositionRightTop:
        case MAPositionRightBottom:
            // Arrow points towards left. We're starting from the bottom.
            tipPt.x -= scaledArrowHeight;
            tipPt.y += halfArrowWidth;
            endPt.y += scaledArrowWidth;
            break;
        case MAPositionTop:
        case MAPositionTopLeft:
        case MAPositionTopRight:
            // Arrow points towards bottom. We're starting from the right.
            tipPt.y -= scaledArrowHeight;
            tipPt.x -= halfArrowWidth;
            endPt.x -= scaledArrowWidth;
            break;
        case MAPositionBottom:
        case MAPositionBottomLeft:
        case MAPositionBottomRight:
            // Arrow points towards top. We're starting from the left.
            tipPt.y += scaledArrowHeight;
            tipPt.x += halfArrowWidth;
            endPt.x += scaledArrowWidth;
            break;
        default:
            break; // won't happen, but this satisfies gcc with -Wall
    }

    [path lineToPoint:tipPt];
    [path lineToPoint:endPt];
}


- (void)_redisplay
{
    if (_resizing) {
        return;
    }

    _resizing = YES;
    NSDisableScreenUpdates();
    [self _updateGeometry];
    [self _updateBackground];
    NSEnableScreenUpdates();
    _resizing = NO;
}


# pragma mark Window Behaviour


- (BOOL)canBecomeMainWindow
{
    return NO;
}


- (BOOL)canBecomeKeyWindow
{
    return YES;
}


- (BOOL)isExcludedFromWindowsMenu
{
    return YES;
}


- (BOOL)validateMenuItem:(NSMenuItem *)item
{
    if (_window) {
        return [_window validateMenuItem:item];
    }
    return [super validateMenuItem:item];
}


- (IBAction)performClose:(id)sender
{
    if (_window) {
        [_window performClose:sender];
    } else {
        [super performClose:sender];
    }
}


# pragma mark Notification handlers


- (void)windowDidResize:(NSNotification *)note
{
    [self _redisplay];
}


#pragma mark Accessors


- (void)setPoint:(NSPoint)point side:(MAWindowPosition)side
{
    // Thanks to Martin Redington.
    _point = point;
    _side = side;
    NSDisableScreenUpdates();
    [self _updateGeometry];
    [self _updateBackground];
    NSEnableScreenUpdates();
}


- (NSColor *)windowBackgroundColor {
    return [[_MABackgroundColor retain] autorelease];
}


- (void)setBackgroundColor:(NSColor *)value {
    if (_MABackgroundColor != value) {
        [_MABackgroundColor release];
        _MABackgroundColor = [value copy];

        [self _updateBackground];
    }
}


- (NSColor *)borderColor {
    return [[borderColor retain] autorelease];
}


- (void)setBorderColor:(NSColor *)value {
    if (borderColor != value) {
        [borderColor release];
        borderColor = [value copy];

        [self _updateBackground];
    }
}


- (float)borderWidth {
    return borderWidth;
}


- (void)setBorderWidth:(float)value {
    if (borderWidth != value) {
        float maxBorderWidth = viewMargin;
        if (value <= maxBorderWidth) {
            borderWidth = value;
        } else {
            borderWidth = maxBorderWidth;
        }

        [self _updateBackground];
    }
}


- (float)viewMargin {
    return viewMargin;
}


- (void)setViewMargin:(float)value {
    if (viewMargin != value) {
        viewMargin = MAX(value, 0.0);

        // Adjust cornerRadius appropriately (which will also adjust arrowBaseWidth).
        [self setCornerRadius:cornerRadius];
    }
}


- (float)arrowBaseWidth {
    return arrowBaseWidth;
}


- (void)setArrowBaseWidth:(float)value {
    float maxWidth = (MIN(_viewFrame.size.width, _viewFrame.size.height) +
                      (viewMargin * 2.0)) - cornerRadius;
    if (drawsRoundCornerBesideArrow) {
        maxWidth -= cornerRadius;
    }
    if (value <= maxWidth) {
        arrowBaseWidth = value;
    } else {
        arrowBaseWidth = maxWidth;
    }

    [self _redisplay];
}


- (float)arrowHeight {
    return arrowHeight;
}


- (void)setArrowHeight:(float)value {
    if (arrowHeight != value) {
        arrowHeight = value;

        [self _redisplay];
    }
}


- (float)hasArrow {
    return hasArrow;
}


- (void)setHasArrow:(float)value {
    if (hasArrow != value) {
        hasArrow = value;

        [self _updateBackground];
    }
}


- (float)cornerRadius {
    return cornerRadius;
}


- (void)setCornerRadius:(float)value {
    float maxRadius = ((MIN(_viewFrame.size.width, _viewFrame.size.height) +
                        (viewMargin * 2.0)) - arrowBaseWidth) / 2.0;
    if (value <= maxRadius) {
        cornerRadius = value;
    } else {
        cornerRadius = maxRadius;
    }
    cornerRadius = MAX(cornerRadius, 0.0);

    // Adjust arrowBaseWidth appropriately.
    [self setArrowBaseWidth:arrowBaseWidth];
}


- (float)drawsRoundCornerBesideArrow {
    return drawsRoundCornerBesideArrow;
}


- (void)setDrawsRoundCornerBesideArrow:(float)value {
    if (drawsRoundCornerBesideArrow != value) {
        drawsRoundCornerBesideArrow = value;

        [self _redisplay];
    }
}


- (void)setBackgroundImage:(NSImage *)value
{
    if (value) {
        [self setBackgroundColor:[NSColor colorWithPatternImage:value]];
    }
}

- (void)setDevice:(int)device
{
    _device = device;
    [self _updateBackground];
}

@end
