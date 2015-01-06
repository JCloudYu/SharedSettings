/*
    The MIT License (MIT)

    Copyright (c) [year] [fullname]

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

@implementation SharedSettings
{
	NSUserDefaults* _sharedDefaults;
}

- (void)pluginInitialize
{
	_sharedDefaults = [NSUserDefaults standardUserDefaults];
}

- (void)getSetting:(CDVInvokedUrlCommand*)command
{
	id key = command.arguments[0];
	
	if ( [key isKindOfClass:[NSString class]] )
	{
		NSString* value = [_sharedDefaults stringForKey:key];
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
	id key = command.arguments[0];
	
	if ( !key || ![key isKindOfClass:[NSString class]] )
	{
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Given key is invalid"];
		[self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
		return;
	}
	
	id input = command.arguments[1];
	NSString* prev  = [_sharedDefaults stringForKey:key];
	
	if ( !input || [input isKindOfClass:[NSNull class]] )
	{
		[_sharedDefaults removeObjectForKey:key];
		prev = @"";
	}
	else
		[_sharedDefaults setObject:[NSString stringWithFormat:@"%@", input] forKey:key];

	[_sharedDefaults synchronize];

	[self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:(prev) ? prev : @""]
								callbackId:command.callbackId];
}

- (void)querySettings:(CDVInvokedUrlCommand*)command
{
	id ikeys = command.arguments[0];
	
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
		id val = [_sharedDefaults stringForKey:key];
		values[key] = val ? val : @"";
	}
	
	[self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:values]
								callbackId:command.callbackId];
}

- (void)patchSettings:(CDVInvokedUrlCommand*)command
{
	id keyValues = command.arguments[0];
	
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
		id prevVal = [_sharedDefaults stringForKey:key];
		prevSets[key] = (prevVal) ? prevVal : @"";


		id iVal = pairSets[key];
		if ( iVal && ![iVal isKindOfClass:[NSNull class]] )
			[_sharedDefaults setObject:iVal forKey:key];
		else
			[_sharedDefaults removeObjectForKey:key];
	}

	[_sharedDefaults synchronize];
	
	[self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:prevSets]
								callbackId:command.callbackId];
}

- (void)clearSettings:(CDVInvokedUrlCommand*)command
{
	[NSUserDefaults resetStandardUserDefaults];
	_sharedDefaults = [NSUserDefaults standardUserDefaults];
}

@end
