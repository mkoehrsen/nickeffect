//
//  TrailDelta.m
//  NickEffect
//
//  Created by Michael Koehrsen on 12/11/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "TrailDelta.h"


@implementation TrailDelta

+ (TrailDelta *)extension:(TrailSegment *)seg color:(NSColor *)color
{
	return [[[TrailDelta alloc] initWithType:TDExtension segment:seg color:color] autorelease];
}
+ (TrailDelta *)truncation:(TrailSegment *)seg
{
	return [[[TrailDelta alloc] initWithType:TDTruncation segment:seg color:nil] autorelease];
}

- initWithType:(TDType)theType segment:(TrailSegment *)theSegment color:(NSColor *)theColor
{
	type = theType;
	segment = [theSegment retain];
	color = [theColor retain];
	
	return [super init];
}

- (void)dealloc {
	[segment release];
	[color release];
	[super dealloc];
}

- (TDType)type
{
	return type;
}
- (TrailSegment *)segment
{
	return segment;
}
- (NSColor *)color
{
	return color;
}

@end
