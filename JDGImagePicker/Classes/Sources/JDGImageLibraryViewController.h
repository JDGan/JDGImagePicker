//
//  JDGImageLibraryViewController.h
//  JDGImagePicker
//
//  Created by JDGan on 2020/8/31.
//

#import <UIKit/UIKit.h>
#import <JDGImagePicker/JDGImageBaseViewController.h>
NS_ASSUME_NONNULL_BEGIN

@interface JDGImageLibraryViewController : JDGImageBaseViewController

@property (nonatomic, assign) CGRect fromFrame;

@property (nonatomic, assign) CGFloat itemScaledSide;

@end

NS_ASSUME_NONNULL_END
