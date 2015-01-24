//
//  AbstractTrailSpace.h
//  NickEffect
//
//  Created by Michael Koehrsen on 12/15/07.
//  Copyright 2007 Michael Koehrsen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <ScreenSaver/ScreenSaver.h>

#import "TrailSegment.h"

static inline void TSShuffleVertices(int *v,int count) {
	int i;
	for (i=0;i<count;i++) {
		int swapIx = SSRandomIntBetween(0,count-1);
		int tmp = v[i];
		v[i] = v[swapIx];
		v[swapIx] = tmp;
	}
}


// Base class for classes implementing the space that trails live in.   This
// class is responsible for containing the trails and tracking which vertices have
// incident TrailSegments.  
//
// Subclasses should implement the TrailSpace protocol, which has methods for representing the
// geometry of the space, including neighbor relationships between vertices and
// the mapping of vertex ids to points in space.
//
@interface AbstractTrailSpace : NSObject {

@private
	// Bounding rectangle of the space
	NSRect bounds;

	// Value from 1 to 10 giving the density of vertices in the space.   Subclasses
	// can interpret as they choose.
	int vertexDensity;
	
	// List of trails. Trails have a weak reference back to the containing TrailSpace.
	// The base class owns the list but subclasses are responsible for populating it
	NSMutableArray *trails;
}

+ (NSArray *)trailSpaceDisplayNames;
+ (id)trailSpaceClassNamed:(NSString *)theDisplayName;

- initBounds:(NSRect)theRect vertexDensity:(int)theVertexDensity;

- (NSRect)bounds;
- (int)vertexDensity;

// Adds a new trail to this space, consisting of a single TrailSegment with
// the specified head and trail vertex.  Returns the new trail (mostly for testing reasons).
- addTrailWithHead:(int)theHead tail:(int)theTail;

// Does one update step on all the trails and returns the resulting list of
// TrailDeltas.
- (NSArray *)update;

// Creates trails in the space, generally randomly.  density should be 
// a value from 1 to 10.
- (void)createTrailsWithDensity:(int)density;

// Invokes overridden method allNeighborsOfVertex, then shuffles the list
- (void)shuffleNeighborsOfVertex:(int)vertex into:(int*)list;

// Modifies the path object appropriately for drawing the segment from tail to head.
// By default, adds a straight line segment, but subclasses can override to draw arcs, etc.
- (void)updatePath:(NSBezierPath *)path withSegment:(TrailSegment *)seg;

//-------------------------------------------------------------------------------------
// REMAINING METHODS MUST BE OVERRIDDEN
//-------------------------------------------------------------------------------------

// Name to display in config sheet for this space class
+ (NSString *)displayName;

// Two methods for tracking vertex state
- (BOOL)isVertexOccupied:(int)vertex;
- (void)markVertex:(int)vertex asOccupied:(BOOL)occupied;

// Used to iterate over all vertices in the space.   Returns the successor
// of the specified vertex according to whatever ordering the space chooses.
// If the vertex is the last one in the ordering, returns -1.
- (int)nextVertex:(int)vertex;

// Maps a vertex to a point.
- (NSPoint)pointForVertex:(int)vertex;

// Maximum number of neighbors of any vertex in this space,
// so trail can allocate appropriate-sized neighbor buffer
- (int)maxNeighborVertexCount;

// Returns the vertex id for the neighboring vertex in the forward direction,
// given the specified tail vertex 
- (int)forwardNeighborOfVertex:(int)head fromTail:(int)tail;

// Fetchs all neighbors of the specified vertex into list, which should have
// size == maxNeighborVertexCount.   If there are fewer neighbors extra slots
// are filled with -1
- (void)allNeighborsOfVertex:(int)vertex into:(int*)list;

@end
