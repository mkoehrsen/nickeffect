//
//  ShuffleTrailSpace.m
//  NickEffect
//
//  Created by Michael Koehrsen on 1/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ShuffleTrailSpace.h"
#import "AbstractTrailSpace.h"

#import <ScreenSaver/ScreenSaver.h> // For SSRandomIntBetween

@implementation ShuffleTrailSpace

+ (NSString *)displayName 
{
	return @"Shuffle";
}

- initBounds:(NSRect)theRect vertexDensity:(int)theVertexDensity
{
	NSArray *spaceNames = [AbstractTrailSpace trailSpaceDisplayNames];
	NSString *name = nil;
	
	while (name == nil) {
		name = [spaceNames objectAtIndex:SSRandomIntBetween(0,[spaceNames count]-1)];
		if ([name isEqualToString:[[self class] displayName]]) name = nil;
	}
	
	return [[[AbstractTrailSpace trailSpaceClassNamed:name] alloc] initBounds:theRect vertexDensity:theVertexDensity];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
	return [AbstractTrailSpace instanceMethodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
	[anInvocation invokeWithTarget:trailSpace];
}

@end
