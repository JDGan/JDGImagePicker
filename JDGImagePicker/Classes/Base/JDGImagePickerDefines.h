//
//  JDGImagePickerDefines.h
//  JDGImagePicker
//
//  Created by JDGan on 2020/9/9.
//

#ifndef JDGImagePickerDefines_h
#define JDGImagePickerDefines_h

@class PHAsset, AVCaptureDevice;

typedef void(^JDGVoidBlock)(void);

typedef void(^JDGAssetResultBlock)(NSArray<PHAsset *> * _Nullable assets, NSError * _Nullable error);
typedef void(^JDGImagesResultBlock)(NSArray<UIImage *> * _Nullable images, NSError * _Nullable error);
typedef void(^JDGImageResultBlock)(UIImage * _Nullable image, NSError * _Nullable error);

typedef void(^JDGLockInputDeviceBlock)(AVCaptureDevice * _Nonnull device);
typedef BOOL(^JDGCheckIsInputDeviceSupportBlock)(AVCaptureDevice * _Nonnull device);

typedef void(^JDGCompletionBlock)(BOOL success, id _Nullable data, NSError * _Nullable error);
typedef void(^JDGAnimationBlock)(UIView * _Nonnull fromView, UIView * _Nonnull toView);
typedef void(^JDGAnimationCompleteBlock)(BOOL isFinished);


#ifndef dispatch_main_async_jdg_safe
#define dispatch_main_async_jdg_safe(block)\
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {\
        block();\
    } else {\
        dispatch_async(dispatch_get_main_queue(), block);\
    }
#endif

@protocol JDGStoryBoardControllerProtocol <NSObject>
/// 一定要在类中实现该方法,才能通过create创建控制器,默认使用ImagePicker中的storyboard
+ (UIStoryboard * _Nullable)getStoryboard;
/// 使用create方法创建storyboard中的控制器
+ (_Nullable instancetype)create;

@end

/// 单例模式协议,必须实现单例及摧毁单例方法
@protocol JDGSingletonProtocol <NSObject>
/// 销毁创建的单例
+ (void)destroyShared;
/// 访问单例
+ (instancetype _Nullable)shared;

@end

#endif /* JDGImagePickerDefines_h */
