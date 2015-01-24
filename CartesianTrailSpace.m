//
//  TrailSpace.m
//  NickEffect
//
//  Created by Michael Koehrsen on 12/10/07.
//  Copyright 2007 Michael Koehrsen. All rights reserved.
//

#import "CartesianTrailSpace.h"
#import "Trail.h"

@implementation CartesianTrailSpace

+ (NSString *)displayName 
{
	return @"Cartesian";
}

 - initBounds:(NSRect)theRect vertexDensity:(int)theVertexDensity
{
	NSSize size = theRect.size;
	
	NSAssert1(theVertexDensity >= 1 && theVertexDensity <= 10,@"Illegal vertex density %d",theVertexDensity);
	
	// density == 10 -> spacing = 2; density == 1 -> spacing = 20
	vertexSpacing = 2 + ((10-theVertexDensity)*2);
	width = ((int)size.width)/vertexSpacing;
	height = ((int)size.height)/vertexSpacing;
	
	vertexMap = [[Bitmap alloc] initSize:width*height];
	
	return [super initBounds:theRect vertexDensity:theVertexDensity];
}


- (int)width 
{
	return width;
}

- (int)height
{
	return height;
}

- (BOOL)isVertexOccupied:(int)vertex
{
	BOOL result = YES;
	
	if (vertex >= 0 && vertex < [vertexMap size]) result = [vertexMap isSet:vertex];
	return result;
}

- (void)markVertex:(int)vertex asOccupied:(BOOL)occupied
{
	if (occupied) [vertexMap set:vertex];
	else [vertexMap clear:vertex];
}

- (int)nextVertex:(int)vertex
{
	if (vertex < width*height) return vertex+1;
	else return -1;
}

- (NSPoint)pointForVertex:(int)vertex
{
	NSPoint result;
	
	result.x = (float)(vertex % width) * vertexSpacing;
	result.y = (float)(vertex / width) * vertexSpacing;
	
	return result;
}

- (int)maxNeighborVertexCount
{
	return 4;
}

#define CTS_NORTH_NEIGHBOR(vertex) ((vertex/width) < (height-1) ? vertex + width : -1)
#define CTS_SOUTH_NEIGHBOR(vertex) ((vertex/width) > 0 ? vertex - width : -1)
#define CTS_EAST_NEIGHBOR(vertex) ((vertex%width) < (width-1) ? vertex+1 : -1)
#define CTS_WEST_NEIGHBOR(vertex) ((vertex%width) > 0 ? vertex-1 : -1) 

- (int)forwardNeighborOfVertex:(int)head fromTail:(int)tail
{
	int result;
	
	if (head == CTS_WEST_NEIGHBOR(tail)) result = CTS_WEST_NEIGHBOR(head);
	else if (head == CTS_EAST_NEIGHBOR(tail)) result = CTS_EAST_NEIGHBOR(head);	
	else if (head == CTS_SOUTH_NEIGHBOR(tail)) result = CTS_SOUTH_NEIGHBOR(head);
	else if (head == CTS_NORTH_NEIGHBOR(tail)) result = CTS_NORTH_NEIGHBOR(head);
	else NSAssert2(false,@"Unexpected value of (head,tail):(%d,%d)",head,tail);
	
	return result;
}

- (void)allNeighborsOfVertex:(int)vertex into:(int*)list
{
	list[0] = CTS_WEST_NEIGHBOR(vertex);
	list[1] = CTS_EAST_NEIGHBOR(vertex);
	list[2] = CTS_SOUTH_NEIGHBOR(vertex);
	list[3] = CTS_NORTH_NEIGHBOR(vertex);
}

@end
