//
//  JDGImageStack.m
//  JDGImagePicker
//
//  Created by JDGan on 2020/9/2.
//

#import "JDGImageStack.h"
@interface JDGImageStack ()

@property(nonatomic, retain) NSMutableArray <JDGImagePickerPhoto *> *selectedPhotos;

@end

@implementation JDGImageStack

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.selectedPhotos = [NSMutableArray array];
    }
    return self;
}

- (JDGImagePickerPhoto *)objectForData:(id)data forType:(JDGImagePickerPhotoType)type {
    if(data == nil) return nil;
    NSArray *targets = [self.selectedPhotos filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(JDGImagePickerPhoto * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        if (evaluatedObject.type != type) {return NO;}
        switch (type) {
            case JDGImagePickerPhotoTypePHAsset:
            {
                if(![data isKindOfClass:[PHAsset class]]) {return NO;}
                return [evaluatedObject.asset.localIdentifier isEqualToString:((PHAsset *)data).localIdentifier];
            }
                break;
            case JDGImagePickerPhotoTypeLocalFile:
            {
                if(![data isKindOfClass:[NSString class]]) {return NO;}
                return [evaluatedObject.localPath isEqualToString:(NSString *)data];
            }
                break;
            case JDGImagePickerPhotoTypeRemoteURL:
            {
                if(![data isKindOfClass:[NSURL class]]) {return NO;}
                return [evaluatedObject.remoteURL.absoluteString isEqualToString:((NSURL *)data).absoluteString];
            }
                break;
            default:
                break;
        }
        return NO;
    }]];
    return targets.firstObject;
}

- (BOOL)containsObject:(id)obj forType:(JDGImagePickerPhotoType)type {
    return ([self objectForData:obj forType:type] != nil);
}

- (void)reset:(NSArray<JDGImagePickerPhoto *> *)photos {
    if (photos.count == 0) {
        [[self mutableArrayValueForKey:@"selectedPhotos"] removeAllObjects];
        return;
    }
    [self.selectedPhotos removeAllObjects];
    if(photos.count > 1) {
        NSArray *sub = [photos subarrayWithRange:NSMakeRange(0, photos.count-1)];
        [self.selectedPhotos addObjectsFromArray:sub];
    }
    [[self mutableArrayValueForKey:@"selectedPhotos"] addObject:photos.lastObject];
}

- (void)push:(JDGImagePickerPhoto *)photo {
    [[self mutableArrayValueForKey:@"selectedPhotos"] addObject:photo];
}

- (void)pushPhoto:(JDGImagePickerPhoto *)photo atIndex:(NSUInteger)photoIndex {
    [[self mutableArrayValueForKey:@"selectedPhotos"] insertObject:photo atIndex:photoIndex];
}

- (void)pushPhotosInArray:(NSArray<JDGImagePickerPhoto *> *)photos {
    if(photos.count > 1) {
        NSArray *sub = [photos subarrayWithRange:NSMakeRange(0, photos.count-1)];
        [self.selectedPhotos addObjectsFromArray:sub];
    }
    [[self mutableArrayValueForKey:@"selectedPhotos"] addObject:photos.lastObject];
}

- (void)pop:(JDGImagePickerPhoto *)photo {
    if([self.selectedPhotos containsObject:photo]) {
        [[self mutableArrayValueForKey:@"selectedPhotos"] removeObject:photo];
    }
}

- (void)popPhotoAtIndex:(NSUInteger)photoIndex {
    if (photoIndex < self.selectedPhotos.count) {
        [[self mutableArrayValueForKey:@"selectedPhotos"] removeObjectAtIndex:photoIndex];
    }
}

- (void)popPhotosInArray:(NSArray<JDGImagePickerPhoto *> *)photos {
    if(photos.count > 1) {
        NSArray *sub = [photos subarrayWithRange:NSMakeRange(0, photos.count-1)];
        [self.selectedPhotos removeObjectsInArray:sub];
    }
    [[self mutableArrayValueForKey:@"selectedPhotos"] removeObject:photos.lastObject];
}

- (void)insertItem:(JDGImagePickerPhoto *)source beforeDestination:(JDGImagePickerPhoto *)destination {
    NSUInteger index = [self.selectedPhotos indexOfObject:destination];
    if(index != NSNotFound) {
        [self pop:source];
        [self pushPhoto:source atIndex:index];
    }    
}

@end
