//
//  JDGAssetManager.h
//  JDGImagePicker
//
//  Created by JDGan on 2020/8/28.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^JDGAssetResultBlock)(NSArray<PHAsset *> * _Nullable, NSError * _Nullable );
typedef void(^JDGImagesResultBlock)(NSArray<UIImage *> * _Nullable, NSError * _Nullable );
typedef void(^JDGImageResultBlock)(UIImage * _Nullable, NSError * _Nullable );

@interface JDGAssetManager : NSObject

@property (nonatomic, retain, readonly) NSMutableArray<PHAsset *> *libraryAssets;

+ (instancetype)shared;

+ (void)destroyShared;

- (nullable UIImage *)getImageForName:(NSString *)name;

- (void)fetchAssetsCompletion:(JDGAssetResultBlock)completion;

- (void)asyncResolveAsset:(PHAsset *)asset
                     size:(CGSize)size
             deliveryMode:(PHImageRequestOptionsDeliveryMode)mode
               completion:(JDGImagesResultBlock)completion;

- (NSArray<UIImage *> *)resolveAssets:(NSArray<PHAsset *> *)assets;

@end

NS_ASSUME_NONNULL_END
