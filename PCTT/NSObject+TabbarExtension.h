//
//  NSObject+TabbarExtension.h
//  TourGuide
//
//  Created by Mac on 7/23/18.
//  Copyright © 2018 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@interface NSObject (TabbarExtension)

- (void)customTab;

- (NSString *)numerize:(NSString *)string;

@end

@interface NSObject (obj)

- (UIImage*)getImage:(NSString*)base64String;

@end
