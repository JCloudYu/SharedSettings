/*
 The MIT License (MIT)
 
 Copyright (c) 2014 J. Cloud Yu
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

#import "SharedSettings.h"
#import <Foundation/Foundation.h>

@interface SharedSettings()
- (NSUserDefaults*)getDefaults:(NSMutableArray*)arguments;
@end

@implementation SharedSettings

- (NSUserDefaults *)getDefaults:(NSMutableArray *)arguments
{
	NSUserDefaults *defaults = nil;
	NSString* domain = arguments[0];
	[arguments removeObjectAtIndex:0];
	
	if ( [domain isEqualToString:@""] )
		return [NSUserDefaults standardUserDefaults];
	else
	{
#if !__has_feature(objc_arc)
		return [[[NSUserDefaults alloc] initWithSuiteName:domain] autorelease];
#else
		return [[NSUserDefaults alloc] initWithSuiteName:domain];
#endif
	}
}

- (void)getSetting:(CDVInvokedUrlCommand*)command
{
	NSMutableArray *arguments = [NSMutableArray arrayWithArray:command.arguments];
	
	id key = arguments[0];
	
	if ( [key isKindOfClass:[NSString class]] )
	{
		NSString* value = [[self getDefaults:arguments] stringForKey:key];
		if ( value )
		{
			[self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:value]
										callbackId:command.callbackId];
			return;
		}
	}
	
	[self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""]
								callbackId:command.callbackId];
}

- (void)setSetting:(CDVInvokedUrlCommand*)command
{
	NSMutableArray *arguments = [NSMutableArray arrayWithArray:command.arguments];
	
	id key = arguments[0];
	
	if ( !key || ![key isKindOfClass:[NSString class]] )
	{
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Given key is invalid"];
		[self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
		return;
	}
	
	id input = arguments[1];
	NSString* prev  = [[self getDefaults:arguments] stringForKey:key];
	
	if ( !input || [input isKindOfClass:[NSNull class]] )
	{
		[[self getDefaults:arguments] removeObjectForKey:key];
		prev = @"";
	}
	else
		[[self getDefaults:arguments] setObject:[NSString stringWithFormat:@"%@", input] forKey:key];
	
	[[self getDefaults:arguments] synchronize];
	
	[self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:(prev) ? prev : @""]
								callbackId:command.callbackId];
}

- (void)querySettings:(CDVInvokedUrlCommand*)command
{
	NSMutableArray *arguments = [NSMutableArray arrayWithArray:command.arguments];
	
	id ikeys = arguments[0];
	
	if ( !ikeys || ![ikeys isKindOfClass:[NSArray class]] )
	{
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Given keys are invalid"];
		[self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
		return;
	}
	
	NSArray* reqKeys = ikeys;
	NSMutableDictionary* values = [NSMutableDictionary dictionary];
	for ( NSString* key in reqKeys )
	{
		id val = [[self getDefaults:arguments] stringForKey:key];
		values[key] = val ? val : @"";
	}
	
	[self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:values]
								callbackId:command.callbackId];
}

- (void)patchSettings:(CDVInvokedUrlCommand*)command
{
	NSMutableArray *arguments = [NSMutableArray arrayWithArray:command.arguments];
	
	id keyValues = arguments[0];
	
	if ( !keyValues || ![keyValues isKindOfClass:[NSDictionary class]] )
	{
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Given key/value pairs are invalid"];
		[self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
		return;
	}
	
	NSDictionary *pairSets = keyValues;
	NSMutableDictionary *prevSets = [NSMutableDictionary dictionary];
	NSArray* reqKeys =  [pairSets allKeys];
	for ( NSString* key in reqKeys )
	{
		id prevVal = [[self getDefaults:arguments] stringForKey:key];
		prevSets[key] = (prevVal) ? prevVal : @"";
		
		
		id iVal = pairSets[key];
		if ( iVal && ![iVal isKindOfClass:[NSNull class]] )
			[[self getDefaults:arguments] setObject:iVal forKey:key];
		else
			[[self getDefaults:arguments] removeObjectForKey:key];
	}
	
	[[self getDefaults:arguments] synchronize];
	
	[self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:prevSets]
								callbackId:command.callbackId];
}

- (void)clearSettings:(CDVInvokedUrlCommand*)command
{
	NSMutableArray *arguments = [NSMutableArray arrayWithArray:command.arguments];
	NSString* domain = arguments[0];
	
	if ([domain isEqualToString:@""])
		[NSUserDefaults resetStandardUserDefaults];
	else
		[[NSUserDefaults standardUserDefaults] removeSuiteNamed:domain];
}

@end
