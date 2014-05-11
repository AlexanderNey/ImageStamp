//
//  main.m
//  ImageStamp
//
//  Created by Alexander Ney on 02/05/2014.
//  Copyright (c) 2014 Alexander Ney. All rights reserved.
//

#import "ImageStampApplicationDelegate.h"


@import Foundation;
@import AppKit;

ImageStampApplicationDelegate *appDelegate;

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        
        NSApplication *applicationObject = [NSApplication sharedApplication];
        
        [applicationObject setActivationPolicy:NSApplicationActivationPolicyProhibited];
        appDelegate = [[ImageStampApplicationDelegate alloc] init];
        applicationObject.delegate = appDelegate;
        
        [applicationObject run];
	}
	
	return 0;
}


