//
//  JDGCameraMananger.h
//  JDGImagePicker
//
//  Created by JDGan on 2020/8/28.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <PhotosUI/PhotosUI.h>

NS_ASSUME_NONNULL_BEGIN
@class JDGCameraMananger;
@protocol JDGCameraManangerDelegate <NSObject>
@optional
- (void)cameraManangerDeviceUnavailable:(JDGCameraMananger *)manager;
- (void)cameraMananger:(JDGCameraMananger *)manager didCatchError:(NSError *)error;
- (void)cameraMananger:(JDGCameraMananger *)manager didStartCaptureSession:(AVCaptureSession *)session;
- (void)cameraMananger:(JDGCameraMananger *)manager didSaveCapturePhoto:(AVCapturePhoto *)photo;
- (void)cameraMananger:(JDGCameraMananger *)manager didChangeInput:(AVCaptureDeviceInput *)input;

@end


@interface JDGCameraMananger : NSObject

@property(nonatomic, weak) id <JDGCameraManangerDelegate> delegate;

- (void)setup:(BOOL)isDefaultBackCamera;

- (void)resume;

- (void)pause;

- (void)takePicture;

- (void)switchCamera;

- (void)focusToPoint:(CGPoint)point;

- (void)zoomToScale:(CGFloat)scale isEnded:(BOOL)isEnded;

@end

NS_ASSUME_NONNULL_END
