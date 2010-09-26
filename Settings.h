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

#import <Foundation/Foundation.h>

@interface MobileConfig : NSObject
{
	BOOL autosize;
	int width;
	NSString * font;
	int fontSize;
	float fontWidth;	
	NSString * args;
}
@property(nonatomic) BOOL autosize;
@property(nonatomic) int fontSize;
@property(nonatomic) float fontWidth;
@property(nonatomic, copy) NSString *font;
@property int width;
@property(copy) NSString *args;
+ (MobileConfig *) getConfig;
- (NSString *)fontDescription;
@end

@interface Settings : NSObject
{
	NSString * arguments;
	NSArray * mobileConfigs;
	NSArray * menu;
}
@property(copy) NSString *arguments;
@property(nonatomic, readonly) NSArray * mobileConfigs;
@property(nonatomic, readonly) NSArray * menu;
+ (Settings *)sharedInstance;
- (id) init;
- (void) registerDefaults;
- (void) readUserDefaults;
- (void) writeUserDefaults;
@end
