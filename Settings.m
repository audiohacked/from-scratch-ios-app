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
#import "Settings.h"
#import <Foundation/NSUserDefaults.h>
#import "Menu.h"

@implementation mobileConfig
@synthesize autosize;
@synthesize width;
@synthesize font;
@synthesize fontSize;
@synthesize fontWidth;
@synthesize args;

+ (mobileConfig *)getConfig
{
	return [[[Settings sharedInstance] mobileConfigs] objectAtIndex:0];
}

- (id) init
{
	if ((self = [super init]))
	{
		autosize = YES;
		width = 45;
		fontSize = 12;
		fontWidth = 0.6f;
		font = @"CourierNewPS-BoldMT";
		args = @"";
	}
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

- (NSString *)fontDescription
{
	return [NSString stringWithFormat:@"%@ %d", font, fontSize];
}

@end

@implementation Settings
@synthesize arguments;
@synthesize mobileConfigs;
@synthesize menu;

+ (Settings *)sharedInstance
{
	static Settings * instance = nil;
	if (instance == nil)
	{
		instance = [[Settings alloc] init];
	}
	return instance;
}

- (id) init
{
	if ((self = [super init]))
	{
		mobileConfigs = [[NSArray arrayWithObjects:
			[[mobileConfig alloc] init], nil] retain];
			
		arguments = @"";
	}
	return self;
}

- (void) dealloc
{
	[mobileConfigs release];
	[super dealloc];
}

- (void)registerDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:2];

    // menu buttons

    NSArray *menuArray = [NSArray arrayWithContentsOfFile:@"/Applications/Terminal.app/menu.plist"];
    if (menuArray == nil)
        menuArray = [[Menu menu] getArray];
    [d setObject:menuArray forKey:@"menu"];

    // swipe gestures

    NSMutableDictionary *gestures = [NSMutableDictionary dictionaryWithCapacity:16];

    int i = 0;
    while (DEFAULT_SWIPE_GESTURES[i][0]) {
        [gestures setObject:DEFAULT_SWIPE_GESTURES[i][1] forKey:DEFAULT_SWIPE_GESTURES[i][0]];
        i++;
    }
    [d setObject:gestures forKey:@"swipeGestures"];

    // terminals

    NSMutableArray *tcs = [NSMutableArray arrayWithCapacity:MAX_TERMINALS];
    for (i = 0; i < MAX_TERMINALS; i++) {
        NSMutableDictionary *tc = [NSMutableDictionary dictionaryWithCapacity:10];
        [tc setObject:[NSNumber numberWithBool:YES] forKey:@"autosize"];
        [tc setObject:[NSNumber numberWithInt:45] forKey:@"width"];
        [tc setObject:[NSNumber numberWithInt:12] forKey:@"fontSize"];
        [tc setObject:[NSNumber numberWithFloat:0.6f] forKey:@"fontWidth"];
        [tc setObject:@"CourierNewPS-BoldMT" forKey:@"font"];
        [tc setObject:(i > 0 ? @"clear" : @"")forKey:@"args"];

        NSMutableArray *ca = [NSMutableArray arrayWithCapacity:NUM_TERMINAL_COLORS];
        [ca addObject:[NSArray arrayWithColor:[UIColor blackColor]]]; // bg color
        [ca addObject:[NSArray arrayWithColor:[UIColor whiteColor]]]; // fg color
        [ca addObject:[NSArray arrayWithColor:[UIColor yellowColor]]]; // bold color
        [ca addObject:[NSArray arrayWithColor:[UIColor redColor]]]; // cursor text
        [ca addObject:[NSArray arrayWithColor:[UIColor yellowColor]]]; // cursor color

        [tc setObject:ca forKey:@"colors"];
        [tcs addObject:tc];
    }
    [d setObject:tcs forKey:@"terminals"];

    NSArray *colorValues = [NSArray arrayWithColor:colorWithRGBA(1, 1, 1, 0.05f)];
    [d setObject:colorValues forKey:@"gestureFrameColor"];

    [defaults registerDefaults:d];
}

#pragma mark Read/Write methods

- (void)readUserDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *tcs = [defaults arrayForKey:@"terminals"];

    for (int i = 0; i < MAX_TERMINALS; i++) {
        TerminalConfig *config = [terminalConfigs objectAtIndex:i];
        NSDictionary *tc = [tcs objectAtIndex:i];
        config.autosize =   [[tc objectForKey:@"autosize"] boolValue];
        config.width =      [[tc objectForKey:@"width"] intValue];
        config.fontSize =   [[tc objectForKey:@"fontSize"] intValue];
        config.fontWidth =  [[tc objectForKey:@"fontWidth"] floatValue];
        config.font =        [tc objectForKey:@"font"];
        config.args =        [tc objectForKey:@"args"];
        for (int c = 0; c < NUM_TERMINAL_COLORS; c++) {
            config.colors[c] = [[UIColor alloc] initWithArray:[[tc objectForKey:@"colors"] objectAtIndex:c]];
            [[ColorMap sharedInstance] setTerminalColor:config.colors[c] atIndex:c termid:i];
        }
    }

    menu = [[defaults arrayForKey:@"menu"] retain];
    swipeGestures = [[NSMutableDictionary dictionaryWithCapacity:24] retain];
    [swipeGestures setDictionary:[defaults objectForKey:@"swipeGestures"]];
    self.gestureFrameColor = [UIColor colorWithArray:[defaults arrayForKey:@"gestureFrameColor"]];
}

- (void)writeUserDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *tcs = [NSMutableArray arrayWithCapacity:MAX_TERMINALS];

    for (int i = 0; i < MAX_TERMINALS; i++) {
        TerminalConfig *config = [terminalConfigs objectAtIndex:i];
        NSMutableDictionary *tc = [NSMutableDictionary dictionaryWithCapacity:10];
        [tc setObject:[NSNumber numberWithBool:config.autosize] forKey:@"autosize"];
        [tc setObject:[NSNumber numberWithInt:config.width] forKey:@"width"];
        [tc setObject:[NSNumber numberWithInt:config.fontSize] forKey:@"fontSize"];
        [tc setObject:[NSNumber numberWithFloat:config.fontWidth] forKey:@"fontWidth"];
        [tc setObject:config.font forKey:@"font"];
        [tc setObject:config.args ? config.args : @"" forKey:@"args"];

        NSMutableArray *ca = [NSMutableArray arrayWithCapacity:NUM_TERMINAL_COLORS];

        for (int c = 0; c < NUM_TERMINAL_COLORS; c++)
            [ca addObject:[NSArray arrayWithColor:config.colors[c]]];

        [tc setObject:ca forKey:@"colors"];
        [tcs addObject:tc];
    }
    [defaults setObject:tcs forKey:@"terminals"];
    [defaults setObject:[[MobileTerminal menu] getArray] forKey:@"menu"];
    [defaults setObject:swipeGestures forKey:@"swipeGestures"];
    [defaults setObject:[NSArray arrayWithColor:gestureFrameColor] forKey:@"gestureFrameColor"];
    [defaults synchronize];
    [[[MobileTerminal menu] getArray] writeToFile:[NSHomeDirectory() stringByAppendingString:@"/Library/Preferences/com.googlecode.mobileterminal.menu.plist"] atomically:YES];
}

@end
