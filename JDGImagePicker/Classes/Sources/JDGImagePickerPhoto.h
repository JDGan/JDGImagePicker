//
//  JDGImagePickerPhoto.h
//  JDGImagePicker
//
//  Created by JDGan on 2020/9/2.
//

#import <Foundation/Foundation.h>
#import <JDGImagePicker/JDGAssetManager.h>
NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    JDGImagePickerPhotoTypeError = 0,
    JDGImagePickerPhotoTypePHAsset = 1U << 0,
    JDGImagePickerPhotoTypeLocalFile = 1U << 1,
    JDGImagePickerPhotoTypeRemoteURL = 1U << 2,
} JDGImagePickerPhotoType;

@interface JDGImagePickerPhoto : NSObject

@property (nonatomic, readonly) JDGImagePickerPhotoType type;

@property (nonatomic, retain, readonly) PHAsset * _Nullable asset;

@property (nonatomic, copy, readonly) NSString * _Nullable localPath;

@property (nonatomic, retain, readonly) NSURL * _Nullable remoteURL;

+ (instancetype)photoWithPHAsset:(PHAsset *)asset;

+ (instancetype)photoWithLocalFilePath:(NSString *)filePath;

+ (instancetype)photoWithRemoteURL:(NSURL *)remoteURL;

+ (instancetype)photoWithCapturePhoto:(AVCapturePhoto *)capturePhoto;

- (void)getImageCompleteInMainQueue:(JDGImageResultBlock)completion;

@end

NS_ASSUME_NONNULL_END
