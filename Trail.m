//
//  Trail.m
//  NickEffect
//
//  Created by Michael Koehrsen on 12/10/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Trail.h"

#import <ScreenSaver/ScreenSaver.h> // For SSRandomFloatBetween

@implementation Trail

+ (Trail *)trailInSpace:(AbstractTrailSpace *)theSpace tail:(int)theTail head:(int)theHead
{
	return [[[Trail alloc] initWithSpace:theSpace tail:theTail head:theHead] autorelease];
}

- initWithSpace:(AbstractTrailSpace *)theSpace tail:(int)theTail head:(int)theHead
{
	trailSpace = theSpace;
	headSegment = [[TrailSegment alloc] initWithTail:theTail head:theHead];
	
	// tailSegment reference retains separately so we don't have to special-case later
	tailSegment = [headSegment retain];

	[trailSpace markVertex:theTail asOccupied:YES];
	[trailSpace markVertex:theHead asOccupied:YES];
	
	color = [[NSColor colorWithDeviceHue:SSRandomFloatBetween(0.0,1.0) 
								saturation:SSRandomFloatBetween(0.0,1.0) 
								brightness:SSRandomFloatBetween(0.0,1.0) alpha:1.0] retain];
	
	return [super init];
}

- (void)dealloc 
{
	[headSegment release];
	[tailSegment release];
	[color release];

	[super dealloc];
}

- (TrailDelta *)update
{
	int newHead = -1;
	int forwardNeighbor = [trailSpace forwardNeighborOfVertex:[headSegment head] fromTail:[headSegment tail]];
	TrailDelta *delta = nil;
	
	/*
	float newSaturation = [color saturationComponent] + SSRandomFloatBetween(-.1,.1);
	if (newSaturation < 0) newSaturation = .01;
	if (newSaturation > 1) newSaturation = 1.0;
	
	[color autorelease];
	color = [[NSColor colorWithDeviceHue:[color hueComponent]
						saturation:newSaturation
						brightness:[color brightnessComponent]
						alpha:1.0] retain];
	*/
	
	if (![trailSpace isVertexOccupied:forwardNeighbor]) {
		newHead = forwardNeighbor;
	}
	else {
		int neighborCount = [trailSpace maxNeighborVertexCount];
		int neighborBuffer[neighborCount];
		int i;
		[trailSpace shuffleNeighborsOfVertex:[headSegment head] into:neighborBuffer];
		
		for (i=0;(newHead < 0) && (i<neighborCount);i++) {
			if (![trailSpace isVertexOccupied:neighborBuffer[i]]) {
				newHead = neighborBuffer[i];
			}
		}
	}
	
	if (newHead >= 0) {
		TrailSegment *newHeadSegment = [[TrailSegment alloc] initWithTail:[headSegment head] head:newHead];
		[headSegment autorelease];
		[headSegment setHeadSegment:newHeadSegment];
		headSegment = [newHeadSegment retain];
		[trailSpace markVertex:newHead asOccupied:YES];
		delta = [TrailDelta extension:newHeadSegment color:color];
	}
	else if (headSegment != tailSegment) {
		[tailSegment autorelease];
		delta = [TrailDelta truncation:tailSegment];
		[trailSpace markVertex:[tailSegment tail] asOccupied:NO];
		tailSegment = [tailSegment headSegment];
	}
	
	return delta;
}


- (NSString *)toString 
{
	NSMutableString *result = [NSMutableString stringWithFormat:@"%d",[tailSegment tail]];
	TrailSegment *currSeg = tailSegment;
	
	while (currSeg != nil) {
		[result appendFormat:@",%d",[currSeg head]];
		currSeg = [currSeg headSegment];
	}
	
	return result;
}

@end
