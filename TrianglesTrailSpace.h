//
//  TrianglesTrailSpace.h
//  NickEffect
//
//  Created by Michael Koehrsen on 12/10/07.
//  Copyright 2007 Michael Koehrsen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "AbstractTrailSpace.h"
#import "Bitmap.h"

// TrailSpace in which vertices lie on a hexagonal coordinate system
@interface TrianglesTrailSpace : AbstractTrailSpace {
	
	int columnSpacing;	
	float rowSpacing;
	
	Bitmap *vertexMap;
	
	// number of vertices per row and per column, respectively
	int width;
	int height;
}

- initBounds:(NSRect)theRect vertexDensity:(int)theVertexDensity;
- (void)dealloc;

- (int)width;
- (int)height;

// methods requiring overrides
- (BOOL)isVertexOccupied:(int)vertex;
- (void)markVertex:(int)vertex asOccupied:(BOOL)occupied;
- (int)nextVertex:(int)vertex;
- (NSPoint)pointForVertex:(int)vertex;
- (int)maxNeighborVertexCount;
- (int)forwardNeighborOfVertex:(int)head fromTail:(int)tail;
- (void)allNeighborsOfVertex:(int)vertex into:(int*)list;

@end
