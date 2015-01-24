//
//  RadialTrailSpace.h
//  NickEffect
//
//  Created by Michael Koehrsen on 12/20/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "AbstractTrailSpace.h";

@interface RadialTrailSpace : AbstractTrailSpace {
	NSPoint center;
	int vertexSpacing;
	NSMutableArray *rings;
	
@private
	// stored values so updates can be computed without method calls
	int ringCount;
	int *ringSizes;
}


- initBounds:(NSRect)theRect vertexDensity:(int)theVertexDensity minVertexCount:(int)minVertexCount fullScreen:(BOOL)fullScreen;
- initBounds:(NSRect)theRect vertexDensity:(int)theVertexDensity;
- (void)dealloc;

- (int)ringCount;
- (float)radiusOfRing:(int)ring;
- (int)vertexCountOfRing:(int)ring;

- (BOOL)isVertexOccupied:(int)vertex;
- (void)markVertex:(int)vertex asOccupied:(BOOL)occupied;
- (int)nextVertex:(int)vertex;
- (NSPoint)pointForVertex:(int)vertex;
- (int)maxNeighborVertexCount;
- (int)forwardNeighborOfVertex:(int)head fromTail:(int)tail;
- (void)allNeighborsOfVertex:(int)vertex into:(int*)list;

@end
