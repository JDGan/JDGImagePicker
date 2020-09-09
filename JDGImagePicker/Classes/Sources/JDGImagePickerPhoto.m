//
//  JDGImagePickerPhoto.m
//  JDGImagePicker
//
//  Created by JDGan on 2020/9/2.
//

#import "JDGImagePickerPhoto.h"
#import "JDGImagePicker.h"

@interface JDGImagePickerPhoto ()

@property (nonatomic, assign) JDGImagePickerPhotoType type;

@property (nonatomic, retain) PHAsset *asset;

@property (nonatomic, copy) NSString * _Nullable localPath;

@property (nonatomic, retain) NSURL * _Nullable remoteURL;

@end


@implementation JDGImagePickerPhoto

+ (instancetype)photoWithPHAsset:(PHAsset *)asset {
    JDGImagePickerPhoto *photo = [JDGImagePickerPhoto new];
    photo.type = JDGImagePickerPhotoTypePHAsset;
    photo.asset = asset;
    return photo;
}

+ (instancetype)photoWithRemoteURL:(NSURL *)remoteURL {
    JDGImagePickerPhoto *photo = [JDGImagePickerPhoto new];
    photo.type = JDGImagePickerPhotoTypeRemoteURL;
    photo.remoteURL = remoteURL;
    return photo;
}

+ (instancetype)photoWithLocalFilePath:(NSString *)filePath {
    JDGImagePickerPhoto *photo = [JDGImagePickerPhoto new];
    photo.type = JDGImagePickerPhotoTypeLocalFile;
    photo.localPath = filePath;
    return photo;
}

+ (instancetype)photoWithCapturePhoto:(AVCapturePhoto *)capturePhoto {
    JDGImagePickerPhoto *photo = [JDGImagePickerPhoto new];
    [photo trySaveToLibrary:capturePhoto.fileDataRepresentation];
    return photo;
}

- (void)trySaveToLibrary:(NSData *)imageData {
    if(PHPhotoLibrary.authorizationStatus == PHAuthorizationStatusAuthorized) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        PHPhotoLibrary *shareLib = PHPhotoLibrary.sharedPhotoLibrary;
        __block PHObjectPlaceholder *placeHolder = nil;
        [shareLib performChanges:^{
            UIImage *image = [UIImage imageWithData:imageData];
            PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            placeHolder = request.placeholderForCreatedAsset;
            request.creationDate = [NSDate date];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                self.type = JDGImagePickerPhotoTypePHAsset;
                self.asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[placeHolder.localIdentifier] options:nil].firstObject;
                dispatch_semaphore_signal(semaphore);
            } else {
                [self saveToDocument:imageData];
                dispatch_semaphore_signal(semaphore);
            }
            if (error) {
                NSLog(@"%@",error.localizedDescription);
            }
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    } else {
        NSLog(@"用户未授权,无权访问相册");
        [self saveToDocument:imageData];
    }
}

- (void)saveToDocument:(NSData *)imageData {
    static int index = 0;
    NSDate *now = [NSDate date];
    NSDateFormatter *f = [NSDateFormatter new];
    f.dateFormat = @"yyyyMMddHHmmss";
    NSString *fileName = [NSString stringWithFormat:@"IMG_%@%d.png",[f stringFromDate:now],index++];
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    if([imageData writeToFile:path atomically:YES]) {
        self.type = JDGImagePickerPhotoTypeLocalFile;
        self.localPath = path;
    } else {
        NSLog(@"文件写错误,请检查后重试");
    }
}

- (void)getImageInMainQueueForQuality:(PHImageRequestOptionsDeliveryMode)mode completion:(JDGImageResultBlock)completion {
    JDGImagePickerConfiguration *config = JDGImagePicker.sharedPicker.configuration;
    __block NSError *error = nil;
    switch (self.type) {
        case JDGImagePickerPhotoTypePHAsset:
        {
            if (self.asset == nil) {
                dispatch_main_async_jdg_safe(^{
                    error = [NSError errorWithDomain:config.errorDomain code:404 userInfo:@{NSLocalizedDescriptionKey:config.errorImageNotFound}];
                    completion(nil, error);
                });
            } else {
                [JDGAssetManager.shared asyncResolveAsset:self.asset size:config.imageSize deliveryMode:mode completion:^(NSArray<UIImage *> * _Nullable images, NSError * _Nullable error) {
                    dispatch_main_async_jdg_safe(^{
                        completion(images.firstObject, error);
                    });
                }];
            }
        }
            break;
        case JDGImagePickerPhotoTypeLocalFile:
        {
            if (self.localPath == nil) {
                dispatch_main_async_jdg_safe(^{
                    error = [NSError errorWithDomain:config.errorDomain code:404 userInfo:@{NSLocalizedDescriptionKey:config.errorImageNotFound}];
                    completion(nil, error);
                });
            } else {
                UIImage *image = [UIImage imageWithContentsOfFile:self.localPath];
                dispatch_main_async_jdg_safe(^{
                    completion(image, error);
                });
            }
        }
            break;
            
        case JDGImagePickerPhotoTypeRemoteURL:
        {
            if (self.remoteURL == nil) {
                dispatch_main_async_jdg_safe(^{
                    error = [NSError errorWithDomain:config.errorDomain code:404 userInfo:@{NSLocalizedDescriptionKey:config.errorImageNotFound}];
                    completion(nil, error);
                });
            } else {
                NSData *imageData = [NSData dataWithContentsOfURL:self.remoteURL];
                UIImage *image = [UIImage imageWithData:imageData];
                dispatch_main_async_jdg_safe(^{
                    completion(image, error);
                });
            }
        }
            break;
        default:
        {
            dispatch_main_async_jdg_safe(^{
                error = [NSError errorWithDomain:config.errorDomain code:404 userInfo:@{NSLocalizedDescriptionKey:config.errorImageNotFound}];
                completion(nil, error);
            });
        }
            break;
    }
}

- (void)getThumbnailImageInMainQueueCompletion:(JDGImageResultBlock)completion {
    [self getImageInMainQueueForQuality:PHImageRequestOptionsDeliveryModeFastFormat completion:completion];
}

- (void)getOriginImageInMainQueueCompletion:(JDGImageResultBlock)completion {
    [self getImageInMainQueueForQuality:PHImageRequestOptionsDeliveryModeHighQualityFormat completion:completion];
}


@end
