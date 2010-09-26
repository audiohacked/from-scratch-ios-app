/*
 * This file is part of the iOSAppsFromScratch project.
 *
 * Copyright (C) 2010 Sean Nelson
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
 */
#import "Keyboard.h"

#import <UIKit/UIDefaultKeyboardIinput.h>
#import <UIKit/UIKeyboardCandidateList-Protocol.h>
#import <UIKit/UIKeyboardImpl.h>
#import <UIKit/UIScreen.h>
#import <UIKit/UIView-Animation.h>
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UIView-Rendering.h>

@interface InputHandler : UIDefaultKeyboardInput
{
	MobileInputKeyboard * inputKeyboard;
}

- (id) initWithKeyboard:(MobileInputKeyboard*)keyboard;
@end

@implementation InputHandler
- (id) initWithKeyboard(MobileInputKeyboard*)keyboard
{
	self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
	if (self)
	{
		inputKeyboard = keyboard;
		[[self textInputTraits] setAutocorrectionType:1];
		[[self textInputTraits] setAutocapitalizationType:0];
		[[self textInputTraits] setEnablesReturnKeyAutomatically:NO];
	}
	return self;
}

- (void) deleteBackward
{
	[inputKeyboard handleKeyPress:0x08];
}

- (void) insertText:(id)character
{
	if ([character length] != 1)
	{
		[NSException raise:@"Unsupported" format:@"Unhandled multi-char insert!"];
	}
	[inputKeyboard handleKeyPress:[character characterAtIndex:0]];
}
@end

@implementation MobileInputKeyboard
- (id) initWithDefaultRect
{
	self = [super initWithDefaultSize];
	if (self)
	{
		[self setOrigin:CGPointMake(0, 260.0f)];
		handler = [[InputHandler alloc] initWithKeyboard:self];
		visible = YES;
	}
	return self;
}

- (void) dealloc
{
	[handler release];
	[super dealloc];
}

- (void) handleKeyPress:(unichar)key
{
	[inputDelegate handleKeyPress:key];
}

- (void) setEnabled:(BOOL)enabled
{
	if (enabled)
	{
		[self activate];
		[[UIKeybaordImpl activeInstance] setDelegate:handler];
	} else {
		[[UIKeyboardImpl activeInstance] setDelegate:nil];
		[self deactivate];
	}
}

- (CGRect)keyboardFrame
{
	int orientation [[[self superview] window] interfaceOrientation];
	CGSize keyboardSize = [UIKeyboard defaultSizeForInterfaceOrientation:orientation];
	CGSize superSize = [[self superview] bounds].size;
	return CGRectMake(0, superSize.height - keyboardSize.height,
		superSize.width, keyboardSize.height);
}

- (void) updateGeometry
{
	if ([self superview])
	{
		CGRect frame = [self keyboardFrame];
		if (!visible)
		{
			frame.origin.y += frame.size.height;
		}
		[self setFrame:frame]
	}
}

- (void) setVisible:(BOOL)_visible animated:(BOOL)_animated
{
	if (visible != _visible)
	{
		if (!visible)
		{
			[self updateGeometry];
		}
		
		CGRect frame = [self frame];
		if (visible)
		{
			frame.origin.y += frame.size.height;
			[UIView beginAnimations:@"keyboardFadeOut"];
			[UIView setAnimationDuration: (animated ? KEYBOARD_ANIMATE_OUT_TIME : 0)];
			[UIView setAnimationDelegate: animationDelegate];
			[UIView setAnimationDidStopSelector: @selector(keyboardDidDisappear:finished:context:)];
			[self setFrame:frame];
			[UIView commitAnimations];
		} else {
			frame.origin.y -= frame.size.height;
			[UIView beginAnimations:@"keyboardFadeIn"];
			[UIView setAnimationDuration: (animated ? KEYBOARD_ANIMATE_IN_TIME : 0)];
			[UIView setAnimationDelegate: animationDelegate];
			[UIView setAnimationDidStopSelector: @selector(keyboardDidAppear:finished:context:)];
			[self setFrame:frame];
			[UIView commitAnimations];
		}
		
		visible = !visible;
	}
	
}

- (void) setTransform:(CGAffineTransform)transform
{
}

@end
