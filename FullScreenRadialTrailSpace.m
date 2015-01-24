//
//  FullScreenRadialTrailSpace.m
//  NickEffect
//
//  Created by Michael Koehrsen on 12/26/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "FullScreenRadialTrailSpace.h"

@implementation FullScreenRadialTrailSpace

+ (NSString *)displayName
{
	return @"Radial full-screen";
}

- initBounds:(NSRect)theRect vertexDensity:(int)theVertexDensity
{
	return [self initBounds:theRect vertexDensity:theVertexDensity minVertexCount:8 fullScreen:YES];
}

@end
