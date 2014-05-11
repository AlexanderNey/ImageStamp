//
//  NSColor+Hex.h
//  ImageStamp
//
//  Created by Alexander Ney on 08/05/2014.
//  Copyright (c) 2014 Alexander Ney. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSColor (Hex)

+ (NSColor *)colorFromHex:(NSString *)colorString;
+ (NSColor *)colorFromHexRGB:(NSString *)colorString;
+ (NSColor *)colorFromHexRGBA:(NSString *)colorString;

@end
