//
//  JDGImagePickerAnimations.h
//  JDGImagePicker
//
//  Created by JDGan on 2020/9/4.
//

#import <UIKit/UIKit.h>
#import <JDGImagePicker/JDGImageBaseViewController.h>
NS_ASSUME_NONNULL_BEGIN

typedef void(^JDGAnimationBlock)(UIView *fromView, UIView *toView);
typedef void(^JDGAnimationCompleteBlock)(BOOL isFinished);

/// 虚类,需要子类实现
@interface JDGImagePickerAnimation : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, retain ,readonly) JDGImageBaseViewController *viewController;

@property (nonatomic, copy) _Nullable JDGAnimationBlock willBeginAnimtaionBlock;

@property (nonatomic, copy) _Nullable JDGAnimationBlock animationBlock;

@property (nonatomic, copy) _Nullable JDGAnimationCompleteBlock animationCompleteBlock;

+ (instancetype)animationForViewController:(JDGImageBaseViewController *)viewController;

@end

@interface JDGImagePickerPushWithPopoverAnimation : JDGImagePickerAnimation

@end

@interface JDGImagePickerPopWithPopoverAnimation : JDGImagePickerAnimation

@end

NS_ASSUME_NONNULL_END
