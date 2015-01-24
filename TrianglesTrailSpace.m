//
//  TrailSpace.m
//  NickEffect
//
//  Created by Michael Koehrsen on 12/10/07.
//  Copyright 2007 Michael Koehrsen. All rights reserved.
//

#import "TrianglesTrailSpace.h"
#import "Trail.h"

#import <math.h>

@implementation TrianglesTrailSpace

+ (NSString *)displayName
{
	return @"Triangles";
}

 - initBounds:(NSRect)theRect vertexDensity:(int)theVertexDensity
{
	NSSize size = theRect.size;
	
	NSAssert1(theVertexDensity >= 1 && theVertexDensity <= 10,@"Illegal vertex density %d",theVertexDensity);
	
	// density == 10 -> spacing = 2; density == 1 -> spacing = 20
	
	columnSpacing = 2 + ((10-theVertexDensity)*2);
	rowSpacing = (float)(columnSpacing * sin(M_PI/3.0));
	width = ((int)size.width-(columnSpacing/2))/columnSpacing;
	height = ((int)size.height)/rowSpacing;
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
	int row = vertex/width;
	NSPoint result;
	
	result.x = (float)(vertex % width) * columnSpacing;
	result.y = (float)(vertex / width) * rowSpacing;
	
	if (row %2 == 1) result.x += (float)columnSpacing/2;
	
	return result;
}

- (int)maxNeighborVertexCount
{
	return 6;
}

#define TTS_ODD_ROW(vertex) (((vertex/width)%2)==1)

// This one is a little complicated.   Asserts that vertex and neighbor are on different rows, with 
//  row(neighbor) - row(vertex) given by delta (must be 1 or -1).   If true, returns neighbor, else returns -1
//   The non-equal case indicates that we're underflowing or overflowing a row
#define TTS_CORRECT_ROW(vertex,neighbor,delta) ((neighbor/width - vertex/width) == delta ? neighbor : -1)

#define TTS_WEST_NEIGHBOR(vertex) ((vertex%width) > 0 ? vertex-1 : -1) 
#define TTS_EAST_NEIGHBOR(vertex) ((vertex%width) < (width-1) ? vertex+1 : -1)
#define TTS_SOUTHWEST_NEIGHBOR(vertex) ((vertex/width) > 0 ? TTS_CORRECT_ROW(vertex,(TTS_ODD_ROW(vertex) ? vertex-width : vertex-width-1),-1) : -1)
#define TTS_NORTHWEST_NEIGHBOR(vertex) ((vertex/width) < (height - 1) ? TTS_CORRECT_ROW(vertex,(TTS_ODD_ROW(vertex) ? vertex+width : vertex+width-1),1) : -1)
#define TTS_SOUTHEAST_NEIGHBOR(vertex) ((vertex/width) > 0 ? TTS_CORRECT_ROW(vertex,(TTS_ODD_ROW(vertex) ? vertex-width+1 : vertex-width),-1) : -1)
#define TTS_NORTHEAST_NEIGHBOR(vertex) ((vertex/width) < (height - 1) ? TTS_CORRECT_ROW(vertex,(TTS_ODD_ROW(vertex) ? vertex+width+1 : vertex+width),1) : -1)

- (int)forwardNeighborOfVertex:(int)head fromTail:(int)tail
{
	int result;
	
	if (head == TTS_WEST_NEIGHBOR(tail)) result = TTS_WEST_NEIGHBOR(head);
	else if (head == TTS_EAST_NEIGHBOR(tail)) result = TTS_EAST_NEIGHBOR(head);	
	else if (head == TTS_SOUTHWEST_NEIGHBOR(tail)) result = TTS_SOUTHWEST_NEIGHBOR(head);
	else if (head == TTS_NORTHWEST_NEIGHBOR(tail)) result = TTS_NORTHWEST_NEIGHBOR(head);
	else if (head == TTS_SOUTHEAST_NEIGHBOR(tail)) result = TTS_SOUTHEAST_NEIGHBOR(head);
	else if (head == TTS_NORTHEAST_NEIGHBOR(tail)) result = TTS_NORTHEAST_NEIGHBOR(head);
	else NSAssert2(false,@"Unexpected value of (head,tail):(%d,%d)",head,tail);
	
	return result;
}

- (void)allNeighborsOfVertex:(int)vertex into:(int*)list
{
	list[0] = TTS_WEST_NEIGHBOR(vertex);
	list[1] = TTS_EAST_NEIGHBOR(vertex);
	list[4] = TTS_SOUTHWEST_NEIGHBOR(vertex);
	list[5] = TTS_NORTHWEST_NEIGHBOR(vertex);
	list[2] = TTS_SOUTHEAST_NEIGHBOR(vertex);
	list[3] = TTS_NORTHEAST_NEIGHBOR(vertex);
}

@end
