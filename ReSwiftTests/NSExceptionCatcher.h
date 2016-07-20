//
//  NSExceptionCatcher.h
//  ReSwift
//
//  Created by Madhava Jay on 20/07/2016.
//  Copyright © 2016 Benjamin Encz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSExceptionCatcher : NSObject

+ (BOOL) caughtException:(void (^_Nonnull)(void))handler;

@end
