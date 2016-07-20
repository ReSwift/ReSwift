//
//  NSExceptionCatcher.m
//  ReSwift
//
//  Created by Madhava Jay on 20/07/2016.
//  Copyright © 2016 Benjamin Encz. All rights reserved.
//

#import "NSExceptionCatcher.h"

@implementation NSExceptionCatcher

+ (BOOL) caughtException:(void (^_Nonnull)(void))handler {
  BOOL exceptionRaised = NO;
  @try {
    handler();
  }
  @catch (NSException *exception) {
    exceptionRaised = YES;
  }
  return exceptionRaised;
}

@end
