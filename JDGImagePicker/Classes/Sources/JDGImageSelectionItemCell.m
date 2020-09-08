//
//  JDGImageSelectionItemCell.m
//  JDGImagePicker
//
//  Created by JDGan on 2020/9/1.
//

#import "JDGImageSelectionItemCell.h"
#import "JDGImagePicker.h"

@interface JDGImageSelectionItemCell ()
@property (nonatomic, weak) id cellData;
@end

@implementation JDGImageSelectionItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    CGSize size = [self.class getItemSize];
    self.imageView.frame = CGRectMake(0, 0, size.width, size.height);
    self.imageView.layer.cornerRadius = 5;
    self.imageView.layer.masksToBounds = YES;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.cellData = nil;
    self.imageView.image = nil;
}

- (void)customizeWithData:(id)data {
    if(![data isKindOfClass:[JDGImagePickerPhoto class]]) {return;}
    if(self.cellData == data) {return;}
    JDGImagePickerPhoto *photo = data;
    self.cellData = photo;
    JDGImagePickerConfiguration *config = JDGImagePicker.sharedPicker.configuration;
    [JDGAssetManager.shared asyncResolveAsset:photo.asset size:config.imageSize deliveryMode:PHImageRequestOptionsDeliveryModeFastFormat completion:^(NSArray<UIImage *> * _Nullable images, NSError * _Nullable error) {
        dispatch_main_async_jdg_safe(^{
            self.imageView.image = images.firstObject;
        });
    }];
}

- (IBAction)deleteButtonPressed:(UIButton *)sender {
    if(self.deleteBlock) {
        self.deleteBlock(self.cellData);
    }
}

+ (CGSize)getItemSize {
    JDGImagePickerConfiguration *config = JDGImagePicker.sharedPicker.configuration;
    CGFloat blank = config.libraryItemGap;
    CGFloat count = config.libraryItemMaxCountForLine;
    CGFloat width = floor((UIScreen.mainScreen.bounds.size.width-(count+1)*blank)/count);
    return CGSizeMake(width, width);
}

@end
