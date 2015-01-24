//
//  RadialTrailSpace.m
//  NickEffect
//
//  Created by Michael Koehrsen on 12/20/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "RadialTrailSpace.h"

#import "Bitmap.h"
#import <math.h>

@interface RTSRing : NSObject
{
	float radius;
	Bitmap *vertexMap;
}

- initRadius:(float)theRadius vertexCount:(int)theCount;

- (float)radius;
- (int)vertexCount;

- (BOOL)isVertexOccupied:(int)vertexIx;
- (void)markVertex:(int)vertexIx asOccupied:(BOOL)occupied;

@end

@implementation RTSRing

- initRadius:(float)theRadius vertexCount:(int)theCount
{
	radius = theRadius;
	vertexMap = [[Bitmap alloc] initSize:theCount];
	return [super init];
}

- (float)radius
{
	return radius;
}
- (int)vertexCount
{
	return [vertexMap size];
}

- (BOOL)isVertexOccupied:(int)vertexIx
{
	BOOL result = YES;
	
	if (vertexIx >= 0 && vertexIx < [vertexMap size]) result = [vertexMap isSet:vertexIx];
	
	return result;
}
- (void)markVertex:(int)vertexIx asOccupied:(BOOL)occupied
{
	if (occupied) [vertexMap set:vertexIx];
	else [vertexMap clear:vertexIx];
}

@end

@implementation RadialTrailSpace

+ (NSString *)displayName 
{
	return @"Radial";
}

- initBounds:(NSRect)theRect vertexDensity:(int)theVertexDensity minVertexCount:(int)minVertexCount fullScreen:(BOOL)fullScreen
{
	center.x = theRect.origin.x + theRect.size.width/2;
	center.y = theRect.origin.y + theRect.size.height/2;
	
	// density == 10 -> spacing = 2; density == 1 -> spacing = 20
	vertexSpacing = 2 + ((10-theVertexDensity)*2);
	
	rings = [[NSMutableArray alloc] init];
	
	// radius of innermost ring is big enough to accommodate minVertexCount points with arc length of vertexSpacing
	int vertexCount = minVertexCount; 
	float radius = fmaxf(ceilf((vertexCount*vertexSpacing)/(2*M_PI)),(float)vertexSpacing/2);
	float maxRadius = fminf(theRect.size.width/2,theRect.size.height/2);
	
	if (fullScreen) {
		maxRadius = sqrt(theRect.size.width*theRect.size.width/4 + theRect.size.height*theRect.size.height/4);
	}
	
	while (radius < maxRadius) {
		[rings addObject:[[RTSRing alloc] initRadius:radius vertexCount:vertexCount]];
		radius += vertexSpacing;
		if (radius*2*M_PI > (vertexCount * vertexSpacing * 2)) vertexCount *= 2;
	}
	
	int i;
	ringCount = [rings count];
	ringSizes = NSZoneCalloc(nil,ringCount,sizeof(int));
	
	for (i=0;i<ringCount;i++) ringSizes[i] = [[rings objectAtIndex:i] vertexCount];

	if (fullScreen) {
	// Mark as unreachable all vertices outside of bounds:
		int vertex;
		for (vertex=[self nextVertex:-1];vertex!=-1;vertex=[self nextVertex:vertex]) {
			NSPoint vPoint = [self pointForVertex:vertex];
			if (vPoint.x <= theRect.origin.x || vPoint.y <= theRect.origin.y || vPoint.x >= (theRect.origin.x + theRect.size.width) || vPoint.y >= (theRect.origin.y + theRect.size.height)) {
				[self markVertex:vertex asOccupied:YES];
			}
		}
	}
	
	return [super initBounds:theRect vertexDensity:theVertexDensity];
}

- initBounds:(NSRect)theRect vertexDensity:(int)theVertexDensity 
{
	return [self initBounds:theRect vertexDensity:theVertexDensity minVertexCount:8 fullScreen:NO];
}


- (void)dealloc
{
	NSZoneFree(nil,ringSizes);
}

- (int)ringCount 
{
	return ringCount;
}

- (float)radiusOfRing:(int)ring
{
	return [(RTSRing *)[rings objectAtIndex:ring] radius];
}

- (int)vertexCountOfRing:(int)ring
{
	return [(RTSRing *)[rings objectAtIndex:ring] vertexCount];
}

#define RTS_RING_IX(vertex) (vertex >> 16)
#define RTS_VERTEX_IX(vertex) (vertex & 0xffff)
#define RTS_MAKE_VERTEX(ringIx,vertexIx) ((ringIx << 16) | vertexIx)
#define RTS_RING_SIZE(vertex) (ringSizes[RTS_RING_IX(vertex)])

// vertex ix of the inner neighbor, assuming not on the innermost ring.   Used by RTS_INNER_NEIGHBOR
#define RTS_INNER_VERTEX_IX(vertex) ((RTS_VERTEX_IX(vertex)%(ringSizes[RTS_RING_IX(vertex)]/ringSizes[RTS_RING_IX(vertex)-1]))==0?(RTS_VERTEX_IX(vertex)/(ringSizes[RTS_RING_IX(vertex)]/ringSizes[RTS_RING_IX(vertex)-1])):-1)
// vertex ix of the outer neighbor, assuming not on the outermost ring.  Used by RTS_OUTER_NEIGHBOR
#define RTS_OUTER_VERTEX_IX(vertex) (RTS_VERTEX_IX(vertex) * (ringSizes[RTS_RING_IX(vertex)+1]/ringSizes[RTS_RING_IX(vertex)]))

#define RTS_INNER_NEIGHBOR(vertex) (RTS_RING_IX(vertex) > 0 ? RTS_MAKE_VERTEX((RTS_RING_IX(vertex)-1),RTS_INNER_VERTEX_IX(vertex)) : -1 )
#define RTS_OUTER_NEIGHBOR(vertex) (RTS_RING_IX(vertex) < (ringCount-1) ? RTS_MAKE_VERTEX((RTS_RING_IX(vertex)+1),RTS_OUTER_VERTEX_IX(vertex)) : -1 )

#define RTS_CLKWISE_NEIGHBOR(vertex) (RTS_MAKE_VERTEX(RTS_RING_IX(vertex),(RTS_VERTEX_IX(vertex)+RTS_RING_SIZE(vertex)-1)%RTS_RING_SIZE(vertex)))
#define RTS_CCLKWISE_NEIGHBOR(vertex) (RTS_MAKE_VERTEX(RTS_RING_IX(vertex),(RTS_VERTEX_IX(vertex)+1)%RTS_RING_SIZE(vertex)))

- (BOOL)isVertexOccupied:(int)vertex
{
	int ringIx = RTS_RING_IX(vertex);
	int vertexIx = RTS_VERTEX_IX(vertex);
	BOOL result = YES;
	
	if (ringIx >= 0 && ringIx < [rings count]) 
		result = [(RTSRing*)[rings objectAtIndex:ringIx] isVertexOccupied:vertexIx];
	
	return result;
}

- (void)markVertex:(int)vertex asOccupied:(BOOL)occupied
{
	int ringIx = RTS_RING_IX(vertex);
	int vertexIx = RTS_VERTEX_IX(vertex);
	
	NSAssert2(ringIx>=0 && ringIx<[rings count],@"Ring index out of bounds:%d; vertex:%d",ringIx,vertex);
	[(RTSRing*)[rings objectAtIndex:ringIx] markVertex:vertexIx asOccupied:occupied];
}
	
- (int)nextVertex:(int)vertex
{
	if (vertex < 0) return 0;

	int ringIx = RTS_RING_IX(vertex);
	int vertexIx = RTS_VERTEX_IX(vertex);		
	NSAssert2(ringIx>=0 && ringIx<[rings count],@"Ring index out of bounds:%d; vertex:%d",ringIx,vertex);
	
	RTSRing *ring = [rings objectAtIndex:ringIx];
	
	if (vertexIx < [ring vertexCount]-1) {
		return RTS_MAKE_VERTEX(ringIx,vertexIx+1);
	}
	else {
		if (ringIx < [rings count] - 1) {
			return RTS_MAKE_VERTEX((ringIx+1),0);
		}
		else {
			return -1;
		}
	} 
}

- (NSPoint)pointForVertex:(int)vertex
{
	int ringIx = RTS_RING_IX(vertex);
	int vertexIx = RTS_VERTEX_IX(vertex);
	NSAssert2(ringIx>=0 && ringIx<[rings count],@"Ring index out of bounds:%d; vertex:%d",ringIx,vertex);

	NSPoint result;
	RTSRing *ring = [rings objectAtIndex:ringIx];
	float radius = [ring radius];
	float angle = (2*M_PI*vertexIx)/[ring vertexCount];
	
	result.x = center.x + radius * cos(angle);
	result.y = center.y + radius * sin(angle);
	
	return result;
}
- (int)maxNeighborVertexCount
{
	return 4;
}

- (int)forwardNeighborOfVertex:(int)head fromTail:(int)tail
{
	int result;
	
	if (head == RTS_INNER_NEIGHBOR(tail)) result = RTS_INNER_NEIGHBOR(head);
	else if (head == RTS_OUTER_NEIGHBOR(tail)) result = RTS_OUTER_NEIGHBOR(head);	
	else if (head == RTS_CLKWISE_NEIGHBOR(tail)) result = RTS_CLKWISE_NEIGHBOR(head);
	else if (head == RTS_CCLKWISE_NEIGHBOR(tail)) result = RTS_CCLKWISE_NEIGHBOR(head);
	else NSAssert2(false,@"Unexpected value of (head,tail):(%d,%d)",head,tail);
	
	return result;
}

- (void)allNeighborsOfVertex:(int)vertex into:(int*)list
{
	list[0] = RTS_INNER_NEIGHBOR(vertex);
	list[1] = RTS_OUTER_NEIGHBOR(vertex);
	list[2] = RTS_CLKWISE_NEIGHBOR(vertex);
	list[3] = RTS_CCLKWISE_NEIGHBOR(vertex);
}
@end
