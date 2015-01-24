//
//  NickEffectView.h
//  NickEffect
//
//  Created by Michael Koehrsen on 12/10/07.
//  Copyright (c) 2007, __MyCompanyName__. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>

#import "AbstractTrailSpace.h"

@interface NickEffectView : ScreenSaverView 
{
	IBOutlet id configureSheet;
	IBOutlet id geometryPopup;
	IBOutlet id pointDensitySlider;
	IBOutlet id trailDensitySlider;
	IBOutlet id animationSpeedSlider;
	
	AbstractTrailSpace *trailSpace;
}

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview;

- (void)startAnimation;
- (void)stopAnimation;
- (void)drawRect:(NSRect)rect;
- (void)animateOneFrame;

- (BOOL)hasConfigureSheet;
- (NSWindow*)configureSheet;

- (IBAction)acceptConfiguration:sender;
- (IBAction)cancelConfiguration:sender;

@end
