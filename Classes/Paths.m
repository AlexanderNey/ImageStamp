//
//  Paths.cpp
//  ImageStamp
//
//  Created by Sony on 05/05/2014.
//  Copyright (c) 2014 Alexander Ney. All rights reserved.
//

#include "Paths.h"

NSString * absolutePath(NSString *path)
{
    NSString *expandedPath = [[path stringByExpandingTildeInPath] stringByStandardizingPath];
    const char *cpath = [expandedPath cStringUsingEncoding:NSUTF8StringEncoding];
    char *resolved = NULL;
    char *returnValue = realpath(cpath, resolved);
    
    if (returnValue == NULL && resolved != NULL) {
        printf("Error with path: %s\n", resolved);
        // if there is an error then resolved is set with the path which caused the issue
        // returning nil will prevent further action on this path
        return nil;
    }
    
    return [NSString stringWithCString:returnValue encoding:NSUTF8StringEncoding];
}
