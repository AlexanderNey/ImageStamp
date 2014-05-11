//
//  ImageStamper.m
//  ImageStamp
//
//  Created by Sony on 03/05/2014.
//  Copyright (c) 2014 Alexander Ney. All rights reserved.
//

#import "ImageStamper.h"
#import "NSColor+Hex.h"
#import "TextView.h"

@import Foundation;
@import AppKit;


//CL Parameter
NSString *const ImageStampParameterInputFile    = @"i";
NSString *const ImageStampParameterOutputFile   = @"o";
NSString *const ImageStampParameterTemplatePlistFile = @"tplist";
NSString *const ImageStampParameterTemplateJsonFile  = @"tjson";

//Structure attributes
NSString *const ImageStampAttributeStamps   = @"stamps";
NSString *const ImageStampAttributeType     = @"type";
NSString *const ImageStampAttributeContent  = @"content";
NSString *const ImageStampAttributeKey      = @"attributes";
NSString *const ImageStampAttributePosition = @"position";

//types
NSString *const ImageStampTypeText = @"text";
NSString *const ImageStampTypeImage = @"image";

//View Attributes
NSString *const ImageStampAttributeViewAlpha           = @"alpha";
NSString *const ImageStampAttributeViewCornerRadius    = @"cornerradius";
NSString *const ImageStampAttributeViewTransformRotate = @"rotate";
NSString *const ImageStampAttributeViewTransformScaleX = @"scalex";
NSString *const ImageStampAttributeViewTransformScaleY = @"scaley";

//Position Attributes
NSString *const ImageStampAttributePositionTop      = @"top";
NSString *const ImageStampAttributePositionLeft     = @"left";
NSString *const ImageStampAttributePositionRight    = @"right";
NSString *const ImageStampAttributePositionBottom   = @"bottom";
NSString *const ImageStampAttributePositionCenterX  = @"centerx";
NSString *const ImageStampAttributePositionCenterY  = @"centery";
NSString *const ImageStampAttributePositionWidth    = @"width";
NSString *const ImageStampAttributePositionHeight   = @"height";

//Text attributes
NSString *const ImageStampAttributeTextFontName          = @"fontname";
NSString *const ImageStampAttributeTextFontSize          = @"fontsize";
NSString *const ImageStampAttributeTextColor             = @"color";
NSString *const ImageStampAttributeTextBackgroundColor   = @"backgroundcolor";
NSString *const ImageStampAttributeTextAligment          = @"aligment";
NSString *const ImageStampAttributeTextAligmentLeft      = @"left";
NSString *const ImageStampAttributeTextAligmentRight     = @"right";
NSString *const ImageStampAttributeTextAligmentCenter    = @"center";
NSString *const ImageStampAttributeTextAligmentJustified = @"justified";
NSString *const ImageStampAttributeTextAligmentNatural   = @"natural";

//map from strings to NSLayoutAttribute constants
static NSDictionary *s_positionAttributesMap;

//map from strings to NSTextAlignment constants
static NSDictionary *s_textAligmentAttributesMap;


CGFloat DegreesToRadians(CGFloat degrees)
{
    return degrees * M_PI / 180;
};

CGFloat RadiansToDegrees(CGFloat radians)
{
    return radians * 180 / M_PI;
};




@interface ImageStamper ()

@property (nonatomic, strong, readwrite) NSImage *stampedImage;
@property (nonatomic, strong, readwrite) NSImage *sourceImage;
@property (nonatomic, strong, readwrite) NSDictionary *arguments;


@end


@implementation ImageStamper

+ (void)initialize
{
    s_positionAttributesMap = @{
                              ImageStampAttributePositionTop     : @(NSLayoutAttributeTop),
                              ImageStampAttributePositionLeft    : @(NSLayoutAttributeLeft),
                              ImageStampAttributePositionRight   : @(NSLayoutAttributeRight),
                              ImageStampAttributePositionBottom  : @(NSLayoutAttributeBottom),
                              ImageStampAttributePositionCenterX : @(NSLayoutAttributeCenterX),
                              ImageStampAttributePositionCenterY : @(NSLayoutAttributeCenterY),
                              ImageStampAttributePositionWidth   : @(NSLayoutAttributeWidth),
                              ImageStampAttributePositionHeight  : @(NSLayoutAttributeHeight),
                            };
    
    s_textAligmentAttributesMap = @{
                                    ImageStampAttributeTextAligmentLeft       : @(NSLeftTextAlignment),
                                    ImageStampAttributeTextAligmentRight      : @(NSRightTextAlignment),
                                    ImageStampAttributeTextAligmentCenter     : @(NSCenterTextAlignment),
                                    ImageStampAttributeTextAligmentJustified  : @(NSJustifiedTextAlignment),
                                    ImageStampAttributeTextAligmentNatural    : @(NSNaturalTextAlignment),
                                   };
}

+ (NSDictionary *)parameterSubstitutesFromArguments:(NSDictionary *)arguments
{
    NSMutableDictionary *templateParameters = [NSMutableDictionary dictionary];
    
    NSArray *defaultParameters = @[ImageStampParameterInputFile, ImageStampParameterOutputFile, ImageStampParameterTemplatePlistFile, ImageStampParameterTemplateJsonFile];
    
    [arguments enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        if (! [defaultParameters containsObject:key])
        {
            NSString *templateKey = [NSString stringWithFormat:@"%%%@%%", key];
            templateParameters[templateKey] = value;
        }
    }];
    
    return [templateParameters copy];
}

+ (NSDictionary *)substitudeParameterValues:(NSDictionary *)arguments
                 placeholderArguments:(NSDictionary *)placeholder
{
    NSMutableDictionary *replacedArguments = [arguments mutableCopy];
    
    [arguments enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
        if ([value isKindOfClass:NSString.class])
        {
            __block NSMutableString *replacedValue;
            
            [placeholder enumerateKeysAndObjectsUsingBlock:^(NSString *placeHolderKey, NSString *placeHolderValue, BOOL *stop) {
                
                if ([value rangeOfString:placeHolderKey].location != NSNotFound)
                {
                    if(!replacedValue)
                    {
                        replacedValue = [value mutableCopy];
                    }
                    
                    [replacedValue replaceOccurrencesOfString:placeHolderKey
                                                   withString:placeHolderValue
                                                      options:NSCaseInsensitiveSearch
                                                        range:NSMakeRange(0, replacedValue.length)];
                }
            }];
            
            if (replacedValue)
            {
                replacedArguments[key] = replacedValue;
            }
        }
        else if ([value isKindOfClass:NSArray.class])
        {
            NSArray *arrayValue = (NSArray *)value;
            NSMutableArray *replacedArrayValue = [NSMutableArray array];
            [arrayValue enumerateObjectsUsingBlock:^(id value, NSUInteger idx, BOOL *stop) {
                NSDictionary *replacementDictionary = [self substitudeParameterValues:@{@"": value} placeholderArguments:placeholder];
                
                if (replacementDictionary[@""])
                {
                    [replacedArrayValue addObject:replacementDictionary[@""]];
                }
                else
                {
                    [replacedArrayValue addObject:value];
                }
            }];
            replacedArguments[key] = [replacedArrayValue copy];
        }
        else if ([value isKindOfClass:NSDictionary.class])
        {
            replacedArguments[key] = [self substitudeParameterValues:replacedArguments[key] placeholderArguments:placeholder];
        }
    }];
    
    return [replacedArguments copy];
}

- (instancetype)initWithImage:(NSImage *)image
                    parameter:(NSDictionary *)parameter
                    arguments:(NSDictionary *)arguments
{
    self = [super init];
    if (self)
    {
        self.sourceImage = image;
        
        NSDictionary *parameterSubstitutes = [ImageStamper parameterSubstitutesFromArguments:arguments];
        self.arguments = [ImageStamper substitudeParameterValues:parameter
                                     placeholderArguments:parameterSubstitutes];
    }
    return self;
}

- (NSImage *)stampedImage
{
    if (!_stampedImage)
    {
        [self generateStampedImage];
    }
    
    return _stampedImage;
}

- (void)generateStampedImage
{
    //create composing view
    CGRect sourceRect = CGRectMake(0, 0, self.sourceImage.size.width, self.sourceImage.size.height);
    NSImageView *composingView = [[NSImageView alloc] initWithFrame:sourceRect];
    composingView.wantsLayer = YES;
    composingView.image = self.sourceImage;
    composingView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSWindow *window = [[[NSApplication sharedApplication] windows] firstObject];
    [window.contentView addSubview:composingView];
    
    NSArray *stamps = self.arguments[ImageStampAttributeStamps];
    NSAssert([stamps isKindOfClass:NSArray.class], @"'%@' array not defined", ImageStampAttributeStamps);
    
    [stamps enumerateObjectsUsingBlock:^(NSDictionary *stampInfo, NSUInteger idx, BOOL *stop) {
        NSString *contentType = stampInfo[ImageStampAttributeType];
        NSAssert(contentType, @"'%@' for stamp %lu not defined",ImageStampAttributeType, (unsigned long)idx);
        
        if ([contentType isEqualToString:ImageStampTypeText])
        {
            [self addTextStamp:stampInfo  toCompositeView:composingView];
        }
        else if ([contentType isEqualToString:ImageStampTypeImage])
        {
            [self addImageStamp:stampInfo toCompositeView:composingView];
        }
        else
        {
            
        }
    }];
    [composingView display];
    
    //create NSImage from composite view
    NSBitmapImageRep *bitmapImageRep = [composingView bitmapImageRepForCachingDisplayInRect:composingView.bounds];
    [composingView cacheDisplayInRect:composingView.bounds toBitmapImageRep:bitmapImageRep];
    self.stampedImage = [[NSImage alloc] initWithSize:bitmapImageRep.size];
    [self.stampedImage addRepresentation:bitmapImageRep];
}

#pragma mark - Text

- (void)addTextStamp:(NSDictionary *)stampInfo toCompositeView:(NSView *)compositeView
{
    NSView *containerView = [[NSView alloc] init];
    containerView.wantsLayer = YES;
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [compositeView addSubview:containerView];
    
    TextView *textView = [[TextView alloc] init];
    textView.backgroundColor = NSColor.clearColor;
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    textView.wantsLayer = YES;
    [containerView addSubview:textView];
    
    NSString *text = stampInfo[ImageStampAttributeContent];
    NSAssert(text, @"missing '%@' for text stamp", ImageStampAttributeContent);
    
    //view attributes
    [self applyDefaultViewParameter:stampInfo toView:textView];
    
    //text attributes
    NSDictionary *attributes = stampInfo[ImageStampAttributeKey];
    NSRange textRange = NSMakeRange(0, text.length);
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    
    //font name
    NSString *fontName = attributes[ImageStampAttributeTextFontName];
    CGFloat fontSize = [(NSNumber *)attributes[ImageStampAttributeTextFontSize] floatValue];

    if (fontSize == 0)
    {
        fontSize = NSFont.systemFontSize;
    }
    
    NSFont *font;
    if (fontName.length > 0)
    {
        font = [NSFont fontWithName:fontName size:fontSize];
    }
    
    if (!font)
    {
        font = [NSFont systemFontOfSize:fontSize];
    }
    
    [attributedString addAttribute:NSFontAttributeName value:font range:textRange];
    
    //font color
    NSString *fontColorAttribute = attributes[ImageStampAttributeTextColor];
    NSColor *fontColor;
    if (fontColorAttribute.length > 0)
    {
        fontColor = [NSColor colorFromHexRGB:fontColorAttribute];
    }
    else
    {
        //default font color
        fontColor = NSColor.whiteColor;
    }
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:fontColor range:textRange];
    
    //background color
    NSString *backgroundColorAttribute = attributes[ImageStampAttributeTextBackgroundColor];
    NSColor *backgroundColor = backgroundColorAttribute ? [NSColor colorFromHexRGB:backgroundColorAttribute] : NSColor.clearColor;
    [attributedString addAttribute:NSBackgroundColorAttributeName value:backgroundColor range:textRange];
    
    //set attributed string
    [[textView textStorage] appendAttributedString:attributedString];
    
    //aligment
    [textView setAlignment:NSLeftTextAlignment];
    NSString *aligmentAttribute = attributes[ImageStampAttributeTextAligment];
    
    if (aligmentAttribute.length > 0)
    {
        NSNumber *algimentValue = s_textAligmentAttributesMap[aligmentAttribute];
        if (algimentValue)
        {
            [textView setAlignment:algimentValue.unsignedIntegerValue];
        }
    }
    
    [self positionElement:containerView parameter:stampInfo];
    textView.frame = containerView.bounds;
    [self applyTransformParameter:stampInfo toView:textView];
}

#pragma mark - Image

- (void)addImageStamp:(NSDictionary *)stampInfo toCompositeView:(NSView *)compositeView
{
    NSImageView *imageView = [[NSImageView alloc] init];
    [compositeView addSubview:imageView];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    imageView.imageScaling = NSImageScaleProportionallyUpOrDown;
    
    NSString *imageDestinatin = stampInfo[ImageStampAttributeContent];
    NSAssert(imageDestinatin, @"missing '%@' for image stamp", ImageStampAttributeContent);
    
    NSURL *url = [NSURL URLWithString:imageDestinatin];
    
    NSImage *image;
    if (url)
    {
        image = [[NSImage alloc] initWithContentsOfURL:url];
    }
    
    imageView.image = image;
    
    [self applyDefaultViewParameter:stampInfo toView:imageView];
    
    [self positionElement:imageView parameter:stampInfo];
}

#pragma mark - View Parameter

- (void)applyDefaultViewParameter:(NSDictionary *)parameter toView:(NSView *)view
{
    //view.layer.masksToBounds = YES;

    NSDictionary *attributes = parameter[ImageStampAttributeKey];
 
    //Alpha
    NSNumber *alphaAttribute = attributes[ImageStampAttributeViewAlpha];
    view.alphaValue = alphaAttribute ? alphaAttribute.floatValue : 1.0;
    
    //Corner Radius
    NSNumber *cornerRadius = attributes[ImageStampAttributeViewCornerRadius];
    view.layer.cornerRadius = cornerRadius.floatValue;
}

- (void)applyTransformParameter:(NSDictionary *)parameter toView:(NSView *)view
{
    NSDictionary *attributes = parameter[ImageStampAttributeKey];
    
    
    CGRect frame = view.layer.frame;
    CGPoint center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
    view.layer.position = center;
    view.layer.anchorPoint = CGPointMake(0.5, 0.5);
    
    //Transform scale
    NSNumber *scaleXAttribute = attributes[ImageStampAttributeViewTransformScaleX] ? : @(1.0);
    NSNumber *scaleYAttribute = attributes[ImageStampAttributeViewTransformScaleY] ? : @(1.0);
    
    if (scaleXAttribute.floatValue != 1.0 || scaleYAttribute.floatValue != 1.0)
    {
        view.layer.affineTransform = CGAffineTransformScale(view.layer.affineTransform, scaleXAttribute.floatValue, scaleYAttribute.floatValue);
    }
    
    //Transform rotate
    NSNumber *rotateAttribute = attributes[ImageStampAttributeViewTransformRotate] ? : @(0.0);

    if (rotateAttribute.floatValue != 0.0)
    {
        view.layer.transform = CATransform3DRotate(CATransform3DIdentity, DegreesToRadians(rotateAttribute.floatValue), 0.0, 0.0, 1.0);
    }

}

#pragma mark - Position

- (void)positionElement:(NSView *)view parameter:(NSDictionary *)parameter
{
    //position & size
    NSDictionary *positionParameter = parameter[ImageStampAttributePosition];
    NSAssert([positionParameter isKindOfClass:NSDictionary.class], @"'%@' not defined", ImageStampAttributePosition);
    
    NSView *superView = view.superview;
    NSAssert(superView, @"view must have superview to be able to positioning");
 
    //iterate & add nslayout contraints
    [positionParameter enumerateKeysAndObjectsUsingBlock:^(NSString *attributeName, NSString *attributeValueString, BOOL *stop) {
        
        NSNumber *attributeTypeNumber = s_positionAttributesMap[attributeName];
        NSAssert(attributeTypeNumber, @"unknown position attribute '%@'", attributeName);
        
        NSLayoutAttribute layoutAttribute = attributeTypeNumber.integerValue;
        
        CGFloat attributeValue = [ImageStamper positionAttribute:attributeValueString horizontal:NO relatedToView:superView];
        
        NSLog(@"Attribute %@ added with %f", attributeName, attributeValue);
        
        if (layoutAttribute == NSLayoutAttributeWidth || layoutAttribute == NSLayoutAttributeHeight)
        {
            [superView addConstraint:({
                [NSLayoutConstraint constraintWithItem:view
                                             attribute:layoutAttribute
                                             relatedBy:NSLayoutRelationEqual
                                                toItem:nil
                                             attribute:NSLayoutAttributeNotAnAttribute
                                            multiplier:1.0
                                              constant:attributeValue];
            })];
        }
        else
        {
            [superView addConstraint:({
                [NSLayoutConstraint constraintWithItem:view
                                             attribute:layoutAttribute
                                             relatedBy:NSLayoutRelationEqual
                                                toItem:superView
                                             attribute:layoutAttribute
                                            multiplier:1.0
                                              constant:attributeValue];
            })];
        }
        
    }];
    
    [superView layoutSubtreeIfNeeded];
}

+ (CGFloat)positionAttribute:(NSString *)attribute
                     horizontal:(BOOL)horizontal
                  relatedToView:(NSView *)view
{
    CGFloat relatedLenght = horizontal ? view.bounds.size.width : view.bounds.size.height;
    NSCharacterSet *numberCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"+-.,0123456789"];
    NSString *cleanedAttribute = [attribute stringByTrimmingCharactersInSet:[numberCharacterSet invertedSet]];
    CGFloat attributeValue = [cleanedAttribute floatValue];
    
    CGFloat finalLength;
    if ([attribute hasSuffix:@"%"])
    {
        finalLength = attributeValue / 100 * relatedLenght;
    }
    else
    {
        finalLength = attributeValue;
    }
    
    return finalLength;
}

@end
