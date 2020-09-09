//
//  JDGImagePickerConfiguration.h
//  JDGImagePicker
//
//  Created by JDGan on 2020/8/28.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface JDGImagePickerConfiguration : NSObject

#pragma mark - UI定义
@property (nonatomic, retain) UIColor *mainColor;
@property (nonatomic, retain) UIColor *maskViewBackgroundColor;
@property (nonatomic, retain) UIColor *cameraButtonColor;
@property (nonatomic, retain) UIColor *cameraButtonHighlightedColor;
@property (nonatomic, retain) UIColor *cameraButtonTitleColor;
@property (nonatomic, retain) UIFont *cameraButtonTitleFont;

@property (nonatomic, retain) UIColor *flashAutoColor;
@property (nonatomic, retain) UIColor *flashOnColor;
@property (nonatomic, retain) UIColor *flashOffColor;

#pragma mark - 自定义属性
@property (nonatomic, assign) BOOL allowVideoSelection;
@property (nonatomic, assign) BOOL allowAudioSession;
@property (nonatomic, assign) BOOL enableFlashMode;
@property (nonatomic, assign) NSUInteger imageStackCount;
@property (nonatomic, retain) NSArray *allowedOrientations;
/// 默认使用屏幕size
@property (nonatomic, assign) CGSize imageSize;
/// 默认采用PHImageRequestOptionsDeliveryModeHighQualityFormat,高质量
@property (nonatomic, assign) PHImageRequestOptionsDeliveryMode imageDeliveryMode;
@property (nonatomic, assign) NSUInteger libraryItemMaxCountForLine;
@property (nonatomic, assign) CGFloat libraryItemGap;
@property (nonatomic, assign) CGFloat libraryLiteItemGap;
@property (nonatomic, assign) CGFloat libraryLiteHeightMax;
@property (nonatomic, assign) CGFloat libraryLiteHeightMin;
@property (nonatomic, assign) CGFloat libraryLiteVelocityBoundary;
@property (nonatomic, assign) CGFloat libraryLiteHeaderHeight;
#pragma mark - 本地化文案
@property (nonatomic, copy) NSString *errorDomain;
@property (nonatomic, copy) NSString *errorPermissionDenied;
@property (nonatomic, copy) NSString *errorImageNotFound;
@property (nonatomic, copy) NSString *cameraUnavailableTitle;
@property (nonatomic, copy) NSString *goSettingsButtonTitle;
@property (nonatomic, copy) NSString *cancelButtonTitle;
@property (nonatomic, copy) NSString *doneButtonTitle;

@property (nonatomic, copy) NSString *libraryViewTitle;
@property (nonatomic, copy) NSString *selectedViewTitle;
@property (nonatomic, copy) NSString *previewViewTitle;

@property (nonatomic, readonly) CGAffineTransform rotationTransform;

@end

#define JDG_IMAGE_BUNDLE_NAME @"JDGImagePickerResources.bundle"
#define JDG_VIEW_BUNDLE_NAME @"JDGImagePickerResources.bundle"


NS_ASSUME_NONNULL_END
