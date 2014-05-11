//
//  ImageStamper.h
//  ImageStamp
//
//  Created by Sony on 03/05/2014.
//  Copyright (c) 2014 Alexander Ney. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const ImageStampParameterInputFile;
FOUNDATION_EXPORT NSString *const ImageStampParameterOutputFile;
FOUNDATION_EXPORT NSString *const ImageStampParameterTemplateJsonFile;
FOUNDATION_EXPORT NSString *const ImageStampParameterTemplatePlistFile;


NSDictionary *replaceParametersFromArguments(NSDictionary *parameters);

@interface ImageStamper : NSObject

@property (nonatomic, strong, readonly) NSImage *stampedImage;

- (instancetype)initWithImage:(NSImage *)image
                    parameter:(NSDictionary *)parameter
                    arguments:(NSDictionary *)arguments;

@end
