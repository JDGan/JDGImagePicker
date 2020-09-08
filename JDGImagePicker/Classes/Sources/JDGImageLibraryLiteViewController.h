//
//  JDGImageLibraryLiteViewController.h
//  JDGImagePicker
//
//  Created by JDGan on 2020/9/3.
//

#import <UIKit/UIKit.h>
#import <JDGImagePicker/JDGImageBaseViewController.h>
NS_ASSUME_NONNULL_BEGIN

@interface JDGImageLibraryLiteViewController : JDGImageBaseViewController

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (void)rotateUIForOrientation:(UIDeviceOrientation)orientation;

@end

NS_ASSUME_NONNULL_END
