//
//  SizeHistory.h
//  Jitouch
//
//  Copyright 2021 Supasorn Suwajanakorn and Sukolsak Sakshuwong. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SizeHistory : NSObject {
    NSRect curRect, savRect;
}
@property (readonly) NSRect curRect;
@property (readonly) NSRect savRect;
- (id)initWithCurRect:(NSRect)curRect SaveRect:(NSRect) savRect;

@end


@interface SizeHistoryKey : NSObject<NSCopying> {
    const CFTypeRef *windowRef;
}
- (void)setWindowRef:(CFTypeRef) a;
- (id)initWithKey:(CFTypeRef)a;
- (id) copyWithZone:(NSZone *)zone;
- (BOOL) isEqual:(id)other;
- (NSUInteger) hash;
@end
