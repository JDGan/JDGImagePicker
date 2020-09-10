//
//  JDGImageBaseViewController.h
//  JDGImagePicker
//
//  Created by JDGan on 2020/8/31.
//

#import <UIKit/UIKit.h>
#import <JDGImagePicker/JDGImagePickerDefines.h>
#import <JDGImagePicker/JDGImagePickerConfiguration.h>

NS_ASSUME_NONNULL_BEGIN

@interface JDGImageBaseViewController : UIViewController <JDGStoryBoardControllerProtocol>

@property (nonatomic, assign) BOOL hideNavigationBar;

@property (nonatomic, retain) UIPercentDrivenInteractiveTransition * _Nullable pdInteractiveTransition;

- (id<UIViewControllerAnimatedTransitioning> _Nullable)navigationAnimationForOperation:(UINavigationControllerOperation)operation;

@end

NS_ASSUME_NONNULL_END
