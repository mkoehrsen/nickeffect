//
//  NickEffectView.m
//  NickEffect
//
//  Created by Michael Koehrsen on 12/10/07.
//  Copyright (c) 2007, __MyCompanyName__. All rights reserved.
//

#import "NickEffectView.h"

#import "TrailDelta.h"

@implementation NickEffectView

#define NE_GEOMETRY_KEY @"geometry"
#define NE_POINT_DENSITY_KEY @"pointDensity"
#define NE_TRAIL_DENSITY_KEY @"trailDensity"
#define NE_ANIMATION_SPEED_KEY @"animationSpeed"

NSUserDefaults *userDefaults = nil;

+ (NSUserDefaults *)userDefaults
{
	if (userDefaults == nil) {
	
		userDefaults 	= [ScreenSaverDefaults defaultsForModuleWithName:@"NickEffect"];
	
		if ([userDefaults objectForKey:NE_GEOMETRY_KEY] == nil) [userDefaults setObject:@"Cartesian" forKey:NE_GEOMETRY_KEY];
		if ([userDefaults objectForKey:NE_POINT_DENSITY_KEY] == nil) [userDefaults setInteger:5 forKey:NE_POINT_DENSITY_KEY];
		if ([userDefaults objectForKey:NE_TRAIL_DENSITY_KEY] == nil) [userDefaults setInteger:5 forKey:NE_TRAIL_DENSITY_KEY];
		if ([userDefaults objectForKey:NE_ANIMATION_SPEED_KEY] == nil) [userDefaults setInteger:5 forKey:NE_ANIMATION_SPEED_KEY];
		
		[userDefaults synchronize];	
	}	
	
	return userDefaults;
}

- (void)updateAnimationInterval
{
	int animationSpeed = [[[self class] userDefaults] integerForKey:NE_ANIMATION_SPEED_KEY];
	[self setAnimationTimeInterval:1/(3.0 * animationSpeed)];
}

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
		[self updateAnimationInterval];
    }
    return self;
}

- (void)dealloc {
	[trailSpace release];
	[configureSheet release];
	[super dealloc];
}

- (void)reinitTrailSpace
{
	[trailSpace release];
	
	NSUserDefaults *userDefaults = [[self class] userDefaults];
	
	NSString *geometry = [userDefaults stringForKey:NE_GEOMETRY_KEY];
	int pointDensity = [userDefaults integerForKey:NE_POINT_DENSITY_KEY];
	int trailDensity = [userDefaults integerForKey:NE_TRAIL_DENSITY_KEY];
	
	id spaceClass = [AbstractTrailSpace trailSpaceClassNamed:geometry];
	
	trailSpace = [[spaceClass alloc] initBounds:[self bounds] vertexDensity:pointDensity];
	[trailSpace createTrailsWithDensity:trailDensity];
	
	if ([self lockFocusIfCanDraw]) {
		[[NSColor blackColor] setFill];
		[NSBezierPath fillRect:[self bounds]];
		[self unlockFocus];
	}
}

- (void)startAnimation
{
    [super startAnimation];
	[self reinitTrailSpace];
}

- (void)stopAnimation
{
    [super stopAnimation];
	[trailSpace release];
	trailSpace = nil;
}

- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];
}

- (void)animateOneFrame
{
	NSArray *deltas = [trailSpace update];
	int i, dc = [deltas count];
	
	[[NSGraphicsContext currentContext] setShouldAntialias:NO];
	NSBezierPath *extensionPath = [NSBezierPath bezierPath];
	NSBezierPath *truncationPath = [NSBezierPath bezierPath];
	
	[extensionPath setLineCapStyle:NSSquareLineCapStyle];
	
	for (i=0;i<dc;i++) {
		TrailDelta *delta = [deltas objectAtIndex:i];

		if ([delta type] == TDExtension) {
			[[delta color] setStroke];

			[trailSpace updatePath:extensionPath withSegment:[delta segment]];
			[extensionPath stroke];
			[extensionPath removeAllPoints];
		}
		else {
			[trailSpace updatePath:truncationPath withSegment:[delta segment]];
		}
	}
	
	[[NSColor blackColor] setStroke];
	[truncationPath stroke];
	
    return;
}

- (BOOL)hasConfigureSheet
{
    return YES;
}

- (NSWindow*)configureSheet
{
	if (configureSheet == nil) {
		[NSBundle loadNibNamed:@"Options" owner:self];
		
		// Install geometry names on popup:
		[geometryPopup removeAllItems];
		[geometryPopup addItemsWithTitles:[AbstractTrailSpace trailSpaceDisplayNames]];
	}
	
	NSUserDefaults *userDefaults = [[self class] userDefaults];
	NSString *geometry = [userDefaults stringForKey:NE_GEOMETRY_KEY];
	int pointDensity = [userDefaults integerForKey:NE_POINT_DENSITY_KEY];
	int trailDensity = [userDefaults integerForKey:NE_TRAIL_DENSITY_KEY];	
	int animationSpeed = [userDefaults integerForKey:NE_ANIMATION_SPEED_KEY];
	
	[geometryPopup selectItemWithTitle:geometry];
	[pointDensitySlider setIntValue:pointDensity];
	[trailDensitySlider setIntValue:trailDensity];
	[animationSpeedSlider setIntValue:animationSpeed];
	
    return configureSheet;
}


- (IBAction)acceptConfiguration:sender
{
	[[NSApplication sharedApplication] endSheet:configureSheet];
	
	NSUserDefaults *userDefaults = [[self class] userDefaults];
	NSString *geometry = [geometryPopup titleOfSelectedItem];
	int pointDensity = [pointDensitySlider intValue];
	int trailDensity = [trailDensitySlider intValue];
	int animationSpeed = [animationSpeedSlider intValue];
	
	[userDefaults setObject:geometry forKey:NE_GEOMETRY_KEY];
	[userDefaults setInteger:pointDensity forKey:NE_POINT_DENSITY_KEY];
	[userDefaults setInteger:trailDensity forKey:NE_TRAIL_DENSITY_KEY];
	[userDefaults setInteger:animationSpeed forKey:NE_ANIMATION_SPEED_KEY];	

	[userDefaults synchronize];

	[self stopAnimation];
	
 	[self updateAnimationInterval];	

	if ([self lockFocusIfCanDraw]) {
		[[NSColor blackColor] setFill];
		[NSBezierPath fillRect:[self bounds]];
		[self unlockFocus];
	}
	
	[self startAnimation];
}
- (IBAction)cancelConfiguration:sender
{
	[[NSApplication sharedApplication] endSheet:configureSheet];
}

@end
