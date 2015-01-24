//
//  TrailDelta.h
//  NickEffect
//
//  Created by Michael Koehrsen on 12/11/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TrailSegment.h"

typedef enum _TDType {
	TDExtension,
	TDTruncation
} TDType;

@interface TrailDelta : NSObject {
	TDType type;
	TrailSegment *segment;
	NSColor *color;
}

+ (TrailDelta *)extension:(TrailSegment *)seg color:(NSColor *)color;
+ (TrailDelta *)truncation:(TrailSegment *)seg;

- initWithType:(TDType)theType segment:(TrailSegment *)theSegment color:(NSColor *)color;

- (TDType)type;
- (TrailSegment *)segment;
- (NSColor *)color;

@end
