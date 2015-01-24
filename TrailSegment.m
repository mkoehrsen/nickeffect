//
//  TrailSegment.m
//  NickEffect
//
//  Created by Michael Koehrsen on 12/10/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "TrailSegment.h"


@implementation TrailSegment

- initWithTail:(int)theTail head:(int)theHead
{
	tail = theTail;
	head = theHead;
	headSegment = nil;
	
	return [super init];
}

- (void)dealloc
{
	[headSegment release];
	[super dealloc];
}

- (int)tail 
{
	return tail;
}

- (int)head
{
	return head;
}

- (TrailSegment *)headSegment
{
	return headSegment;
}

- (void)setHeadSegment:(TrailSegment *)theSegment
{
	// Should't be called more than once
	NSAssert(headSegment==nil,@"Segment may only be set if previously nil");
	headSegment = [theSegment retain];
}

@end
