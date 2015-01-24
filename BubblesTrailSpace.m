//
//  BubblesTrailSpace.m
//  NickEffect
//
//  Created by Michael Koehrsen on 11/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BubblesTrailSpace.h"

// Lots of copy-and-paste from TrianglesTrailSpace in here, oh well
@implementation BubblesTrailSpace

+ (NSString *)displayName
{
	return @"Bubbles";
}

 - initBounds:(NSRect)theRect vertexDensity:(int)theVertexDensity
{
	NSSize size = theRect.size;
	
	NSAssert1(theVertexDensity >= 1 && theVertexDensity <= 10,@"Illegal vertex density %d",theVertexDensity);
	
	// density == 10 -> spacing = 2; density == 1 -> spacing = 20
	
	columnSpacing = 2 + ((10-theVertexDensity)*2);
	rowSpacing = (float)(columnSpacing * sin(M_PI/4.0));
	width = ((int)size.width-(columnSpacing/2))/columnSpacing;
	height = ((int)size.height)/rowSpacing;
	vertexMap = [[Bitmap alloc] initSize:width*height];
	
	// Remove the lower-left-hand corner from the space, things get stuck
	// there otherwise; also upper-right if we have an even number of rows
	[vertexMap set:0];
	if (height%2 == 0) [vertexMap set:(width*height)-1];
	
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

- (void)updatePath:(NSBezierPath *)path withSegment:(TrailSegment *)seg
{
	int tail = [seg tail];
	int head = [seg head];
	
	NSPoint p1 = [self pointForVertex:tail];
	NSPoint p2 = [self pointForVertex:head];
	
	[path moveToPoint:p1];
	[path lineToPoint:p2];
}

- (int)maxNeighborVertexCount
{
	return 4;
}

#define TTS_ODD_ROW(vertex) (((vertex/width)%2)==1)

// This one is a little complicated.   Asserts that vertex and neighbor are on different rows, with 
//  row(neighbor) - row(vertex) given by delta (must be 1 or -1).   If true, returns neighbor, else returns -1
//   The non-equal case indicates that we're underflowing or overflowing a row
#define TTS_CORRECT_ROW(vertex,neighbor,delta) ((neighbor/width - vertex/width) == delta ? neighbor : -1)

#define TTS_SOUTHWEST_NEIGHBOR(vertex) ((vertex/width) > 0 ? TTS_CORRECT_ROW(vertex,(TTS_ODD_ROW(vertex) ? vertex-width : vertex-width-1),-1) : -1)
#define TTS_NORTHWEST_NEIGHBOR(vertex) ((vertex/width) < (height - 1) ? TTS_CORRECT_ROW(vertex,(TTS_ODD_ROW(vertex) ? vertex+width : vertex+width-1),1) : -1)
#define TTS_SOUTHEAST_NEIGHBOR(vertex) ((vertex/width) > 0 ? TTS_CORRECT_ROW(vertex,(TTS_ODD_ROW(vertex) ? vertex-width+1 : vertex-width),-1) : -1)
#define TTS_NORTHEAST_NEIGHBOR(vertex) ((vertex/width) < (height - 1) ? TTS_CORRECT_ROW(vertex,(TTS_ODD_ROW(vertex) ? vertex+width+1 : vertex+width),1) : -1)

- (int)forwardNeighborOfVertex:(int)head fromTail:(int)tail
{
	int result;
	
	if (head == TTS_NORTHEAST_NEIGHBOR(tail)) result = TTS_ODD_ROW(head) ? TTS_NORTHWEST_NEIGHBOR(head) : TTS_SOUTHEAST_NEIGHBOR(head);
	else if (head == TTS_NORTHWEST_NEIGHBOR(tail)) result = TTS_ODD_ROW(head) ? TTS_NORTHEAST_NEIGHBOR(head) : TTS_SOUTHWEST_NEIGHBOR(head);
	else if (head == TTS_SOUTHEAST_NEIGHBOR(tail)) result = TTS_ODD_ROW(head) ? TTS_SOUTHWEST_NEIGHBOR(head) : TTS_NORTHEAST_NEIGHBOR(head);
	else if (head == TTS_SOUTHWEST_NEIGHBOR(tail)) result = TTS_ODD_ROW(head) ? TTS_SOUTHEAST_NEIGHBOR(head) : TTS_NORTHWEST_NEIGHBOR(head);
	else NSAssert2(false,@"Unexpected value of (head,tail):(%d,%d)",head,tail);
	
	return result;
}

- (void)allNeighborsOfVertex:(int)vertex into:(int*)list
{
	list[0] = TTS_SOUTHWEST_NEIGHBOR(vertex);
	list[1] = TTS_NORTHWEST_NEIGHBOR(vertex);
	list[2] = TTS_SOUTHEAST_NEIGHBOR(vertex);
	list[3] = TTS_NORTHEAST_NEIGHBOR(vertex);
}

@end
