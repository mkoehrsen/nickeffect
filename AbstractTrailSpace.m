//
//  AbstractTrailSpace.m
//  NickEffect
//
//  Created by Michael Koehrsen on 12/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "AbstractTrailSpace.h"
#import "Trail.h"

#import "BubblesTrailSpace.h"
#import "CartesianTrailSpace.h"
#import "TrianglesTrailSpace.h"
#import "RadialTrailSpace.h"
#import "FullScreenRadialTrailSpace.h"
#import "ShuffleTrailSpace.h"

#import <ScreenSaver/ScreenSaver.h> // For SSRandomIntBetween

#define TRAIL_SPACE_CLASSES {[CartesianTrailSpace class],[TrianglesTrailSpace class],\
                             [RadialTrailSpace class],[FullScreenRadialTrailSpace class],[ShuffleTrailSpace class],nil}

@implementation AbstractTrailSpace

+ (NSArray *)trailSpaceDisplayNames
{
	NSMutableArray *result = [NSMutableArray array];
	int i;
	id trailSpaceClasses[] = TRAIL_SPACE_CLASSES;
	
	for (i=0;trailSpaceClasses[i] != nil;i++) {
		[result addObject:[trailSpaceClasses[i] displayName]];
	}
	
	return result;
}

+ (id)trailSpaceClassNamed:(NSString *)theDisplayName
{
	id result = nil;
	int i;
	id trailSpaceClasses[] = TRAIL_SPACE_CLASSES;
	
	for (i=0;trailSpaceClasses[i] != nil;i++) {
		if ([theDisplayName isEqualToString:[trailSpaceClasses[i] displayName]]) {
			result = trailSpaceClasses[i];
		}
	}
	
	return result;
}

- initBounds:(NSRect)theRect vertexDensity:(int)theVertexDensity
{
	trails = [[NSMutableArray alloc] init];
	
	return [super init];
}


- (NSRect)bounds
{
	return bounds;
}

- (int)vertexDensity
{
	return vertexDensity;
}

- addTrailWithHead:(int)theHead tail:(int)theTail
{
	Trail *result = [Trail trailInSpace:self tail:theTail head:theHead];
	[trails addObject:result];
	return result;
}

- (NSArray *)update
{
	int i;
	int trailCount = [trails count];
	NSMutableArray *result = [NSMutableArray array];
	for (i=0;i<trailCount;i++) {
		Trail *trail = [trails objectAtIndex:i];
		TrailDelta *delta = [trail update];
		if (delta != nil) [result addObject:delta];
	}
	return result;
}

- (void)createTrailsWithDensity:(int)density
{
	int i;
	int currVertex;
	int neighborCount = [self maxNeighborVertexCount];
	int neighborBuffer[neighborCount];
	
	// density == 1 -> .5% probability of edge per vertex
	// density == 10 -> 5% probability of edge per vertex
	
	for (currVertex = [self nextVertex:-1];currVertex >= 0; currVertex = [self nextVertex:currVertex]) {
		if (![self isVertexOccupied:currVertex] && (SSRandomIntBetween(1,200) <= density)) {
			[self shuffleNeighborsOfVertex:currVertex into:neighborBuffer];
			for (i=0;i<neighborCount;i++) {
				if (![self isVertexOccupied:neighborBuffer[i]]) {
					[self addTrailWithHead:currVertex tail:neighborBuffer[i]];
					break;
				}
			}
		}
	}
}

- (void)shuffleNeighborsOfVertex:(int)vertex into:(int*)list
{
	[self allNeighborsOfVertex:vertex into:list];
	TSShuffleVertices(list,[self maxNeighborVertexCount]);
}

- (void)updatePath:(NSBezierPath *)path withSegment:(TrailSegment *)seg
{
	NSPoint p1 = [self pointForVertex:[seg tail]];
	NSPoint p2 = [self pointForVertex:[seg head]];
	
	[path moveToPoint:p1];
	[path lineToPoint:p2];
}

+ (NSString *)displayName
{
	[NSException raise:@"UnimplementedMethod" format:@"displayName must be overridden"];
	return nil;
}

- (BOOL)isVertexOccupied:(int)vertex
{
	[NSException raise:@"UnimplementedMethod" format:@"isVertexOccupied: must be overridden"];
	return NO;
}
- (void)markVertex:(int)vertex asOccupied:(BOOL)occupied
{
	[NSException raise:@"UnimplementedMethod" format:@"markVertex:asOccupied: must be overridden"];
}

- (int)nextVertex:(int)vertex
{
	[NSException raise:@"UnimplementedMethod" format:@"nextVertex: must be overridden"];
	return -1;	
}

- (NSPoint)pointForVertex:(int)vertex
{
	NSPoint result;
	[NSException raise:@"UnimplementedMethod" format:@"pointForVertex: must be overridden"];
	return result;
}

- (int)maxNeighborVertexCount
{
	[NSException raise:@"UnimplementedMethod" format:@"maxNeighborVertexCount must be overridden"];
	return 0;
}

- (int)forwardNeighborOfVertex:(int)head fromTail:(int)tail
{
	[NSException raise:@"UnimplementedMethod" format:@"forwardNeighborOfVertex:fromTail: must be overridden"];
	return 0;
}

- (void)allNeighborsOfVertex:(int)vertex into:(int*)list
{
	[NSException raise:@"UnimplementedMethod" format:@"allNeighborsOfVertex:into: must be overridden"];
}

@end
