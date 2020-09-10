//
//  JDGAssetManager.m
//  JDGImagePicker
//
//  Created by JDGan on 2020/8/28.
//

#import "JDGAssetManager.h"
#import "JDGImagePickerConfiguration.h"

@interface JDGAssetManager()

@property (nonatomic, retain, readwrite) NSMutableArray<PHAsset *>*libraryAssets;

@end

@implementation JDGAssetManager

static id _sharedAssetManager = nil;
+ (instancetype)shared {
    @synchronized (self) {
        if(_sharedAssetManager == nil){
            _sharedAssetManager = [[self alloc] init];
        }
    }
    return _sharedAssetManager;
}

+ (void)destroyShared {
    _sharedAssetManager = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _libraryAssets = [NSMutableArray array];
    }
    return self;
}

- (void)setupIfNeeded:(JDGCompletionBlock)completion {
    [self checkStatus:^(PHAuthorizationStatus status) {
        if(status == PHAuthorizationStatusAuthorized) {
            [self fetchAssetsCompletion:^(NSArray<PHAsset *> * _Nullable assets, NSError * _Nullable error) {
                completion(YES, assets, error);
            }];
        } else {
            completion(NO, nil, nil);
        }
    }];
}

- (void)checkStatus:(void(^)(PHAuthorizationStatus status))completion {
    PHAuthorizationStatus currentStatus = PHPhotoLibrary.authorizationStatus;
    if(currentStatus == PHAuthorizationStatusAuthorized) {
        dispatch_main_async_jdg_safe(^{
            completion(PHAuthorizationStatusAuthorized);
        });
        return;
    }
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_main_async_jdg_safe(^{
            completion(status);
        });
    }];
}

- (nullable UIImage *)getImageForName:(NSString *)name {
    UITraitCollection *trait = [UITraitCollection traitCollectionWithDisplayScale:3];
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *resourcePath = [bundle.resourcePath stringByAppendingPathComponent:@"JDGImagePickerResources.bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:resourcePath];
    return [UIImage imageNamed:name inBundle:resourceBundle compatibleWithTraitCollection:trait];
}

- (void)fetchAssetsCompletion:(JDGAssetResultBlock)completion {
    JDGImagePickerConfiguration *config = JDGImagePickerConfiguration.shared;
    if(PHPhotoLibrary.authorizationStatus != PHAuthorizationStatusAuthorized) {
        NSError *err = [NSError errorWithDomain:config.errorDomain code:400 userInfo:@{NSLocalizedDescriptionKey:config.errorPermissionDenied}];
        if (completion) {
            dispatch_main_async_jdg_safe(^{
                completion(@[], err);
            });
        }
        return;
    }
    
    dispatch_queue_t queue = dispatch_queue_create("JDGImagePickerQueue", nil);
    dispatch_async(queue, ^{
        PHFetchResult<PHAsset *> * result = nil;
        if (config.allowVideoSelection) {
            result = [PHAsset fetchAssetsWithOptions:[PHFetchOptions new]];
        } else {
            result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:[PHFetchOptions new]];
        }
        if (result.count > 0) {
            NSMutableArray *assets = [NSMutableArray arrayWithCapacity:result.count];
            [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [assets insertObject:obj atIndex:0];
            }];
            [self.libraryAssets removeAllObjects];
            [self.libraryAssets addObjectsFromArray:assets];
            if (completion) {
                dispatch_main_async_jdg_safe(^{
                    completion(assets, nil);
                });
            }
        } else {
         if (completion) {
                dispatch_main_async_jdg_safe(^{
                    completion(@[], nil);
                });
            }
        }
    });
}

- (void)asyncResolveAsset:(PHAsset *)asset
                     size:(CGSize)size
             deliveryMode:(PHImageRequestOptionsDeliveryMode)mode
               completion:(JDGImagesResultBlock)completion {
    PHImageManager *imgManager = PHImageManager.defaultManager;
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.deliveryMode = mode;
    options.networkAccessAllowed = YES;
    options.synchronous = NO;

    [imgManager requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (result) {
            completion(@[result], nil);
        } else {
            JDGImagePickerConfiguration *config = JDGImagePickerConfiguration.shared;
            NSError *err = [NSError errorWithDomain:config.errorDomain code:404 userInfo:@{NSLocalizedDescriptionKey:config.errorPermissionDenied}];
            completion(nil,err);
        }
    }];
}

- (NSArray<UIImage *> *)resolveAssets:(NSArray<PHAsset *> *)assets
{
    JDGImagePickerConfiguration *config = JDGImagePickerConfiguration.shared;
    PHImageManager *imgManager = PHImageManager.defaultManager;
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.deliveryMode = config.imageDeliveryMode;
    options.networkAccessAllowed = YES;
    options.synchronous = YES;
    NSMutableArray<UIImage *> *images = [NSMutableArray arrayWithCapacity:assets.count];
    for(PHAsset *ast in assets) {
        [imgManager requestImageForAsset:ast targetSize:config.imageSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (result) {
                [images addObject:result];
            }
        }];
    }
    return images;
}

@end
