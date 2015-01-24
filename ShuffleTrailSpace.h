//
//  ShuffleTrailSpace.h
//  NickEffect
//
//  Created by Michael Koehrsen on 1/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// Not a real trail space itself, just delegates all method calls to the
// underlying real trail space.
@interface ShuffleTrailSpace : NSObject {
	id trailSpace;
}

+ (NSString *)displayName;

- initBounds:(NSRect)theRect vertexDensity:(int)theVertexDensity;
- (void)dealloc;

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector;
- (void)forwardInvocation:(NSInvocation *)anInvocation;

@end
