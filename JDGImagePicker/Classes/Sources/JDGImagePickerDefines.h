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

#endif /* JDGImagePickerDefines_h */
