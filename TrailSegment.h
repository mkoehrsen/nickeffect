//
//  TrailSegment.h
//  NickEffect
//
//  Created by Michael Koehrsen on 12/10/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TrailSegment : NSObject {
	
	int tail;
	int head;
	
	TrailSegment *headSegment; // Other segment incident on head, if any
}

- initWithTail:(int)theTail head:(int)theHead;
- (void)dealloc;

- (int)tail;
- (int)head;
- (TrailSegment *)headSegment;

- (void)setHeadSegment:(TrailSegment *)theSegment;

@end
