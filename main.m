//
//  main.m
//  BTLog
//
//  Created by Vinny Coyne on 11/06/2010.
//  Copyright Vincent Coyne 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "BTLog.h"

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
    return retVal;
}