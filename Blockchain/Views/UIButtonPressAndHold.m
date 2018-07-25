//
//  UIButtonPressAndHold.m
//  Tube Delays
//
//  Created by Ben Reeves on 06/12/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UIButtonPressAndHold.h"


@implementation UIButtonPressAndHold

@synthesize timer, event, touch;

-(void)touchesBegan:(NSSet*)_touches withEvent:(UIEvent*)_event {
	self.event = _event;
	self.touch = _touches;
	self.timer = [NSTimer scheduledTimerWithTimeInterval:0.10 target:self selector:@selector(fire:) userInfo:nil repeats:YES];
	
	[super touchesBegan:_touches withEvent:_event];
}

-(void)fire:(NSTimer*)_timer {
	if (touch && event) {
		[self sendActionsForControlEvents:UIControlEventTouchUpInside];
	} else {
		[_timer invalidate];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)_event {
	[timer invalidate];
	self.timer = nil;
	self.touch = nil;
	self.event = nil;
	
	[super touchesEnded:touches withEvent:_event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)_event {
	[timer invalidate];
	self.timer = nil;
	self.touch = nil;
	self.event = nil;
	
	[super touchesCancelled:touches withEvent:_event];
}


@end
