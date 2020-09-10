//
//  JDGImageBaseViewController.m
//  JDGImagePicker
//
//  Created by JDGan on 2020/8/31.
//

#import "JDGImageBaseViewController.h"

@interface JDGImageBaseViewController ()

@end

@implementation JDGImageBaseViewController

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

- (id<UIViewControllerAnimatedTransitioning>)navigationAnimationForOperation:(UINavigationControllerOperation)operation {
    return nil;
}


@end
