//
//  JDGImagePickerNavigationController.m
//  JDGImagePicker
//
//  Created by JDGan on 2020/8/28.
//

#import "JDGImagePickerNavigationController.h"
#import "JDGImagePickerAnimations.h"
#import "JDGImageBaseViewController.h"

@interface JDGImagePickerNavigationController () <UINavigationControllerDelegate>

@end

@implementation JDGImagePickerNavigationController

- (void)dealloc
{
//    NSLog(@"%@ dealloc", self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    if (operation == UINavigationControllerOperationPush && [toVC isKindOfClass:[JDGImageBaseViewController class]]) {
        return [(JDGImageBaseViewController *)toVC navigationAnimationForOperation:operation];
    }
    
    if (operation == UINavigationControllerOperationPop && [fromVC isKindOfClass:[JDGImageBaseViewController class]]) {
        return [(JDGImageBaseViewController *)fromVC navigationAnimationForOperation:operation];
    }
    
    return nil;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    if ([animationController isKindOfClass:[JDGImagePickerAnimation class]]) {
        JDGImageBaseViewController *vc = [(JDGImagePickerAnimation *)animationController viewController];
        return vc.pdInteractiveTransition;
    }
    return nil;
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if(![viewController isKindOfClass:[JDGImageBaseViewController class]]) {return;}
    JDGImageBaseViewController *vc = (JDGImageBaseViewController *)viewController;
    [self setNavigationBarHidden:vc.hideNavigationBar animated:animated];
}


- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(nonnull UIViewController *)viewController animated:(BOOL)animated {
    if(![viewController isKindOfClass:[JDGImageBaseViewController class]]) {return;}
    JDGImageBaseViewController *vc = (JDGImageBaseViewController *)viewController;
    [self setNavigationBarHidden:vc.hideNavigationBar animated:animated];
}

- (UIInterfaceOrientationMask)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController {
    return navigationController.topViewController.supportedInterfaceOrientations;
}

+ (UIStoryboard *)getStoryboard {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *resourcePath = [bundle.resourcePath stringByAppendingPathComponent:@"JDGImagePickerResources.bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:resourcePath];
    return [UIStoryboard storyboardWithName:@"JDGImagePicker" bundle:resourceBundle];
}

+ (instancetype)create {
    UIStoryboard *s = [self getStoryboard];
    id vc = [s instantiateViewControllerWithIdentifier:NSStringFromClass(self)];
    if ([vc isKindOfClass:self]) {
        return vc;
    } else {
        return nil;
    }
}

@end
