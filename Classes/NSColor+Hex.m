//
//  NSColor+Hex.m
//  ImageStamp
//
//  Created by Alexander Ney on 08/05/2014.
//  Copyright (c) 2014 Alexander Ney. All rights reserved.
//

#import "NSColor+Hex.h"

@implementation NSColor (Hex)


+ (NSColor *)colorFromHex:(NSString *)colorString
{
    NSColor *result;
    
    if (colorString.length <= 6)
    {
       result = [self colorFromHexRGB:colorString];
    }
    else
    {
       result = [self colorFromHexRGB:colorString];
    }
    
    return result;
}

+ (NSColor *)colorFromHexRGB:(NSString *)colorString
{
	NSColor *color = [self colorFromHexRGBA:colorString];
    
	NSColor *result = [NSColor colorWithCalibratedRed:color.redComponent
                                                green:color.greenComponent
                                                 blue:color.blueComponent
                                                alpha:1.0];
	return result;
}

+ (NSColor *)colorFromHexRGBA:(NSString *)colorString
{
	NSColor *result;
	unsigned int colorCode = 0;
	unsigned char redByte, greenByte, blueByte, alphaByte;
	
	if (nil != colorString)
	{
		NSScanner *scanner = [NSScanner scannerWithString:colorString];
		(void) [scanner scanHexInt:&colorCode];	// ignore error
	}
    alphaByte	= (unsigned char) (colorCode >> 24);
	redByte		= (unsigned char) (colorCode >> 16);
	greenByte	= (unsigned char) (colorCode >> 8);
	blueByte	= (unsigned char) (colorCode);	// masks off high bits
	result = [NSColor colorWithCalibratedRed:(float)redByte	  / 0xff
                                       green:(float)greenByte / 0xff
                                        blue:(float)blueByte  / 0xff
                                       alpha:(float)alphaByte / 0xff];
	return result;
}

@end
