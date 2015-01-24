//
//  Bitmap.h
//  NickEffect
//
//  Created by Michael Koehrsen on 12/18/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Bitmap : NSObject {
	int size;
	int *map;
}

- initSize:(int)theSize;

- (int)size;

- (void)set:(int)index;
- (void)clear:(int)index;

- (BOOL)isSet:(int)index;

@end
