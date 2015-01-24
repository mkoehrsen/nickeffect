//
//  Trail.h
//  NickEffect
//
//  Created by Michael Koehrsen on 12/10/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "AbstractTrailSpace.h"
#import "TrailDelta.h"
#import "TrailSegment.h"

@interface Trail : NSObject {

	AbstractTrailSpace *trailSpace; // weak reference
	
	TrailSegment *headSegment;
	TrailSegment *tailSegment;
	
	NSColor *color;
}

+ (Trail *)trailInSpace:(AbstractTrailSpace *)theSpace tail:(int)theTail head:(int)theHead;

- initWithSpace:(AbstractTrailSpace *)theSpace tail:(int)theTail head:(int)theHead;

- (TrailDelta *)update;

- (NSString *)toString;

@end
