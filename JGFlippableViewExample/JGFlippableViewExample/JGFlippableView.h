//
//  JGFlippableView.h
//  JGFlippableViewExample
//
//  Created by Jaden Geller on 3/27/14.
//  Copyright (c) 2014 Jaden Geller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JGFlippableView : UIView <UIGestureRecognizerDelegate>

+(instancetype)verticallyFlippableView;
+(instancetype)horizontallyFlippableView;

@property (nonatomic) UIView *frontView;
@property (nonatomic) UIView *backView;

@end
