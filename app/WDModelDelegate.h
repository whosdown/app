//
//  WDModelDelegate.h
//  app
//
//  Created by Joseph Schaffer on 2/24/14.
//  Copyright (c) 2014 Who's Down. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WDConstants.h"

@protocol WDModelDelegate <NSObject>

- (void)didReceiveData:(NSDictionary *)data fromInteractionMode:(WDInteractionMode)mode;

- (void)didReceiveError:(NSError *)error fromInteractionMode:(WDInteractionMode)mode;

@end
