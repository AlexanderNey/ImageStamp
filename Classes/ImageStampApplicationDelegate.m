//
//  ImageStampApplicationDelegate.m
//  ImageStamp
//
//  Created by Alexander Ney on 07/05/2014.
//  Copyright (c) 2014 Alexander Ney. All rights reserved.
//

#import "ImageStampApplicationDelegate.h"
#import "ImageStamper.h"
#import "Paths.h"
#import "BashAssertionHandler.h"


@interface ImageStampApplicationDelegate ()
@property (nonatomic, strong, readwrite) NSWindow *window;
@end

@implementation ImageStampApplicationDelegate

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    NSAssertionHandler *assertionHandler = [[BashAssertionHandler alloc] init];
    [[[NSThread currentThread] threadDictionary] setValue:assertionHandler
                                                   forKey:NSAssertionHandlerKey];
    
    
    self.window = [[NSWindow alloc] initWithContentRect:CGRectMake(0, 0, 100, 100)
                                                       styleMask:NSBorderlessWindowMask
                                                         backing:NSBackingStoreBuffered
                                                           defer:YES];
    ((NSView *)self.window.contentView).wantsLayer = YES;
    [self.window makeKeyAndOrderFront:self];
    [self.window orderOut:self];
    
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    NSString *inputFile = [standardDefaults stringForKey:ImageStampParameterInputFile];
    

    NSString *plistParameterFile = [standardDefaults stringForKey:ImageStampParameterTemplatePlistFile];
    //@TODO: support json NSString *jsonParameter = [standardDefaults stringForKey:ImageStampParameterTemplateJsonFile];
    
    
    NSString *outputFile = [standardDefaults stringForKey:ImageStampParameterOutputFile];
    
    //load image
    NSCAssert(inputFile, @"source file not defined");
    NSString *inputFilePath = absolutePath(inputFile);
    NSCAssert([[NSFileManager defaultManager] fileExistsAtPath:inputFilePath], @"input file '%@' does not exist!", inputFilePath);
    NSImage *sourceImage = [[NSImage alloc] initWithContentsOfFile:inputFilePath];
    NSCAssert(sourceImage, @"could not load source image %@", inputFilePath);
    
    //load parameters plist
    NSCAssert(plistParameterFile, @"parameter file not defined");
    NSString *plistParameterFilePath = absolutePath(plistParameterFile);
    NSCAssert([[NSFileManager defaultManager] fileExistsAtPath:plistParameterFilePath], @"configuration file '%@' does not exist!", plistParameterFilePath);
    NSDictionary *parameters = [NSDictionary dictionaryWithContentsOfFile:plistParameterFilePath];
    NSCAssert(parameters, @"could not load configuration file %@", plistParameterFilePath);
    
    
    ImageStamper *stamper = [[ImageStamper alloc] initWithImage:sourceImage
                                                      parameter:parameters
                                                      arguments:standardDefaults.dictionaryRepresentation];
    
    NSImage *stampedImage = stamper.stampedImage;
    
    //try to save to output file
   if (!outputFile)
   {
       outputFile = inputFile;
   }
    NSString *outputFilePath = [[outputFile stringByExpandingTildeInPath] stringByStandardizingPath];
    NSBitmapImageRep *imgRep = [[stampedImage representations] objectAtIndex: 0];
    NSData *data = [imgRep representationUsingType:NSPNGFileType properties:nil];
    [data writeToFile:outputFilePath atomically:NO];
    
    exit(0);
}

@end
