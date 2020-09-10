//
//  JDGImagePickerAnimations.m
//  JDGImagePicker
//
//  Created by JDGan on 2020/9/4.
//

#import "JDGImagePickerAnimations.h"

@interface JDGImagePickerAnimation ()

@property (nonatomic, retain) JDGImageBaseViewController *viewController;

@end

@implementation JDGImagePickerAnimation

+ (instancetype)animationForViewController:(JDGImageBaseViewController *)viewController {
    JDGImagePickerAnimation *animation = [[[self class] alloc] init];
    animation.viewController = viewController;
    return animation;
}

- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
    
}

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return 0;
}

@end

@implementation JDGImagePickerPushWithPopoverAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    //from
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
   //to
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView* toView = nil;
    UIView* fromView = nil;
    //UITransitionContextFromViewKey和UITransitionContextToViewKey定义在iOS8.0以后的SDK中，所以在iOS8.0以下SDK中将toViewController和fromViewController的view设置给toView和fromView
    //iOS8.0 之前和之后view的层次结构发生变化，所以iOS8.0以后UITransitionContextFromViewKey获得view并不是fromViewController的view
    if ([transitionContext respondsToSelector:@selector(viewForKey:)]) {
        fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
        toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    } else {
        fromView = fromViewController.view;
        toView = toViewController.view;
    }
    //这个非常重要，将toView加入到containerView中
    [[transitionContext containerView]  addSubview:toView];
    
    if(self.willBeginAnimtaionBlock) {
        self.willBeginAnimtaionBlock(fromView,toView);
    }
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        if(self.animationBlock) {
            self.animationBlock(fromView,toView);
        }
    } completion:^(BOOL finished) {
        if(self.animationCompleteBlock) {
            self.animationCompleteBlock(finished);
        }
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

@end

@implementation JDGImagePickerPopWithPopoverAnimation

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext{
    return 0.3;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView* toView = nil;
    UIView* fromView = nil;
   
    if ([transitionContext respondsToSelector:@selector(viewForKey:)]) {
        fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
        toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    } else {
        fromView = fromViewController.view;
        toView = toViewController.view;
    }
    
    //将toView加到fromView的下面，非常重要！！！
    [[transitionContext containerView] insertSubview:toView belowSubview:fromView];
    
    if(self.willBeginAnimtaionBlock) {
        self.willBeginAnimtaionBlock(fromView,toView);
    }
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        if(self.animationBlock) {
            self.animationBlock(fromView,toView);
        }
    } completion:^(BOOL finished) {
        if(self.animationCompleteBlock) {
            self.animationCompleteBlock(finished);
        }
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

@end
