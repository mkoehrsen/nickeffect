//
//  BubblesTrailSpace.h
//  NickEffect
//
//  Created by Michael Koehrsen on 11/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "AbstractTrailSpace.h"
#import "Bitmap.h"

// TrailSpace implementing a hexagonal coordinate system as with
// TrianglesTrailSpace.  Different in that trails want to stay on a 
// diamond of four vertices until they're forced; the edges will render
// as arcs so that the diamonds show up as circles
@interface BubblesTrailSpace : AbstractTrailSpace {
	
	int columnSpacing;	
	float rowSpacing;
	
	Bitmap *vertexMap;
	
	// number of vertices per row and per column, respectively
	int width;
	int height;
}

- initBounds:(NSRect)theRect vertexDensity:(int)theVertexDensity;

- (int)width;
- (int)height;

// Override to draw arcs instead of line segments
- (void)updatePath:(NSBezierPath *)path withSegment:(TrailSegment *)seg;

// methods requiring overrides
- (BOOL)isVertexOccupied:(int)vertex;
- (void)markVertex:(int)vertex asOccupied:(BOOL)occupied;
- (int)nextVertex:(int)vertex;
- (NSPoint)pointForVertex:(int)vertex;
- (int)maxNeighborVertexCount;
- (int)forwardNeighborOfVertex:(int)head fromTail:(int)tail;
- (void)allNeighborsOfVertex:(int)vertex into:(int*)list;

@end
