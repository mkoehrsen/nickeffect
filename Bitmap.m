//
//  Bitmap.m
//  NickEffect
//
//  Created by Michael Koehrsen on 12/18/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Bitmap.h"

#define BIT_INTSIZE (sizeof(int)*8)

@implementation Bitmap

- initSize:(int)theSize
{
	size = theSize;
	map = NSZoneCalloc([self zone],(theSize/BIT_INTSIZE)+1,sizeof(int));
	return [super init];
}
- (void)dealloc
{
	NSZoneFree([self zone],map);
	[super dealloc];
}

- (int)size
{
	return size;
}

- (void)set:(int)index
{
	NSAssert1(index >= 0 && index < size,@"Index out of range: %d",index);	
	int mapIndex = index/BIT_INTSIZE;
	map[mapIndex] |= (1<<index%BIT_INTSIZE);
}
- (void)clear:(int)index
{
	NSAssert1(index >= 0 && index < size,@"Index out of range: %d",index);
	int mapIndex = index/BIT_INTSIZE;
	map[mapIndex] &= ~(1<<index%BIT_INTSIZE);
}

- (BOOL)isSet:(int)index
{
	NSAssert1(index >= 0 && index < size,@"Index out of range: %d",index);
	int mapIndex = index/BIT_INTSIZE;
	return (map[mapIndex] & (1 << index%BIT_INTSIZE)) != 0;
}

@end
