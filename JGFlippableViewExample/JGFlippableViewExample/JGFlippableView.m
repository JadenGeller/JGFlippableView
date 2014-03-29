//
//  JGFlippableView.m
//  JGFlippableViewExample
//
//  Created by Jaden Geller on 3/27/14.
//  Copyright (c) 2014 Jaden Geller. All rights reserved.
//

#import "JGFlippableView.h"

CGFloat const JGFlipSpeedMultiplier = 2;
CGFloat const JGFlipDeceleration = .1;


@interface JGFlippableView ()
{
    CATransform3D transform;
    CGFloat velocity;
}

@property (nonatomic) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, readonly) BOOL flipsVertically;
@property (nonatomic) CADisplayLink *displayLink;

@property (nonatomic) CGFloat flips;
@property (nonatomic) CGFloat staticFlip;
@property (nonatomic) CGFloat deltaFlip;
@property (nonatomic, readonly) BOOL backsideVisible;

@end

@implementation JGFlippableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedInitializer_JGFlippableView];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self sharedInitializer_JGFlippableView];
    }
    return self;
}

-(void)sharedInitializer_JGFlippableView{
    _panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panEvent:)];
    _panRecognizer.delegate = self;
    [_panRecognizer setMinimumNumberOfTouches:1];
    [_panRecognizer setMaximumNumberOfTouches:1];
    
    [self addGestureRecognizer:_panRecognizer];
    
    self.frontView = [[UIView alloc]init];
    self.backView = [[UIView alloc]init];
    
    self.frontView.translatesAutoresizingMaskIntoConstraints = NO;
    self.backView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:self.frontView];
    [self addSubview:self.backView];
    
    NSDictionary *views = @{@"f":self.frontView, @"b":self.backView};
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[f]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[f]|" options:0 metrics:nil views:views]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[b]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[b]|" options:0 metrics:nil views:views]];

    
    self.frontView.backgroundColor = [UIColor purpleColor];
    self.backView.backgroundColor = [UIColor orangeColor];
}

-(id)initWithVerticalFlipping:(BOOL)flipsVertically{
    self = [super init];
    if (self) {
        _flipsVertically = flipsVertically;
        [self sharedInitializer_JGFlippableView];
    }
    return self;
}

+(instancetype)verticallyFlippableView{
    return [[self alloc]initWithVerticalFlipping:YES];
}

+(instancetype)horizontallyFlippableView{
    return [[self alloc]initWithVerticalFlipping:NO];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isEqual:self.panRecognizer]) {
        if (gestureRecognizer.numberOfTouches > 0) {
            CGPoint translation = [self.panRecognizer velocityInView:self];
            return (fabs(translation.y) > fabs(translation.x) == self.flipsVertically);
        } else {
            return NO;
        }
    }
    return YES;
}

-(void)panEvent:(UIPanGestureRecognizer*)sender{
    CGFloat total = self.flipsVertically ? self.bounds.size.height : self.bounds.size.width;

    if (sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateChanged) {
        if (sender.state == UIGestureRecognizerStateBegan){
            [self updateStaticFlip];
        }
        // rotate 180 when moved width/height of view
        CGFloat distance = self.flipsVertically ? [sender translationInView:self.superview].y : [sender translationInView:self.superview].x;
        
        self.deltaFlip = distance / total;
    }
    else if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled){
        
        velocity = .1 * (self.flipsVertically ? [sender velocityInView:self.superview].y : [sender velocityInView:self.superview].x)/(2 * M_PI * total);

        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        
//       
//        
//        
//        CGFloat cutOff = fabs(flips) + .5;
//        while (cutOff > 2) cutOff-= 2; // just in case
//        
//        
//        CGFloat time = (cutOff < 1) ? cutOff : 2-cutOff;
//        
//            [UIView animateWithDuration:time / JGFlipSpeedMultiplier animations:^{
//                if ((NSInteger)(fabs(flips) + .5) % 4) {
//                    self.layer.transform = CATransform3DMakeRotation(M_PI, self.flipsVertically, !self.flipsVertically, 0);
//                }
//                else{
//                    self.layer.transform = CATransform3DIdentity;
//
//                }
//
//            } completion:nil];
//        
    }
}

-(CADisplayLink*)displayLink{
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateRotation:)];
    }
    return _displayLink;
}

-(void)updateRotation:(CADisplayLink*)sender{
    
    velocity -= JGFlipDeceleration * sender.duration;
    if (velocity > 0) {
        self.layer.transform = CATransform3DRotate(self.layer.transform,velocity, self.flipsVertically, !self.flipsVertically, 0);

    }
    else{
        [self.displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
}

-(void)setFlips:(CGFloat)flips{
    while (flips >= 2) flips -= 2;
    while (flips < 0) flips+= 2;
    
    _flips = flips;
    [self updateBacksideVisible];
    
    self.layer.transform = CATransform3DMakeRotation(flips * M_PI, self.flipsVertically, !self.flipsVertically, 0);
}

-(void)updateBacksideVisible{
    self.backsideVisible = (self.flips > .5 && self.flips < 1.5);
}

-(void)setBacksideVisible:(BOOL)backsideVisible{
    if (_backsideVisible != backsideVisible) {
        _backsideVisible = backsideVisible;
        [self updateDisplayedViews];
    }
}

-(void)updateDisplayedViews{
    self.backView.hidden = !self.backsideVisible;
    self.frontView.hidden = self.backsideVisible;
}

-(void)setDeltaFlip:(CGFloat)deltaFlip{
    _deltaFlip = deltaFlip;
    
    self.flips = self.staticFlip + self.deltaFlip;
}

-(void)updateStaticFlip{
    self.staticFlip = self.flips;
    self.deltaFlip = 0;
}

-(void)setFrontView:(UIView *)frontView{
    _frontView = frontView;
    frontView.hidden = self.backsideVisible;
}

-(void)setBackView:(UIView *)backView{
    _backView = backView;
    backView.hidden = !self.backsideVisible;
}



//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    if ([gestureRecognizer isEqual:self.panRecognizer] && [otherGestureRecognizer isEqual:[(UIScrollView*)self.superview panGestureRecognizer]]){
//        return YES;
//    }
//    return NO;
//}

@end
