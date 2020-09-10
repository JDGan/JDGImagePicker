//
//  JDGImageCameraViewController.h
//  JDGImagePicker
//
//  Created by JDGan on 2020/8/31.
//

#import <UIKit/UIKit.h>
#import <JDGImagePicker/JDGImageBaseViewController.h>
NS_ASSUME_NONNULL_BEGIN

@interface JDGImageCameraViewController : JDGImageBaseViewController

- (void)takePhoto;

- (void)rotateUIForOrientation:(UIDeviceOrientation)orientation;

@end

NS_ASSUME_NONNULL_END
