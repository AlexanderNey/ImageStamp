//
//  BashAssertionHandler.m
//  ImageStamp
//
//  Created by Sony on 11/05/2014.
//  Copyright (c) 2014 Alexander Ney. All rights reserved.
//

#import "BashAssertionHandler.h"

@implementation BashAssertionHandler

- (void)handleFailureInMethod:(SEL)selector
                       object:(id)object
                         file:(NSString *)fileName
                   lineNumber:(NSInteger)line
                  description:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    __block NSString *finalMessage = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    NSLog(@"ERROR: %@",finalMessage);
    exit(-1);
}

- (void)handleFailureInFunction:(NSString *)functionName
                           file:(NSString *)fileName
                     lineNumber:(NSInteger)line
                    description:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    __block NSString *finalMessage = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    NSLog(@"ERROR: %@",finalMessage);
    exit(-1);
}

@end
