//
//  JDGImageBaseViewController.m
//  JDGImagePicker
//
//  Created by JDGan on 2020/8/31.
//

#import "JDGImageBaseViewController.h"
#import "JDGImagePickerConfiguration.h"
#import "JDGImagePicker.h"

@interface JDGImageBaseViewController ()

@end

@implementation JDGImageBaseViewController

+ (instancetype)create {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *resourcePath = [bundle.resourcePath stringByAppendingPathComponent:JDG_VIEW_BUNDLE_NAME];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:resourcePath];
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"JDGImagePicker" bundle:resourceBundle];
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

- (void)dealloc
{
//    NSLog(@"%@ dealloc", self);
}

@end
