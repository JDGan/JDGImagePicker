//
//  JDGImageLibrarySelectionCell.m
//  JDGImagePicker
//
//  Created by JDGan on 2020/9/3.
//

#import "JDGImageLibrarySelectionCell.h"
#import "JDGImagePicker.h"

@implementation JDGImageLibrarySelectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    NSArray *viewsNeedRoundCorner = @[self.imageView,self.selectedImageView];
    for (UIView *view in viewsNeedRoundCorner) {
        view.layer.masksToBounds = YES;
        view.layer.cornerRadius = 5;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    if(animated) {
        self.selectedImageView.hidden = NO;
        self.selectedImageView.transform = selected ? CGAffineTransformMakeScale(0.1, 0.1) : CGAffineTransformIdentity;
        [UIView animateWithDuration:0.2 animations:^{
            self.selectedImageView.transform = selected ? CGAffineTransformIdentity : CGAffineTransformMakeScale(0.1, 0.1);
        } completion:^(BOOL finished) {
            self.selectedImageView.hidden = !selected;
        }];
    } else {
        self.selectedImageView.hidden = !selected;
    }
    self.selected = selected;
}

- (void)customizeWithData:(PHAsset *)asset isSelected:(BOOL)isSelected {
    self.asset = asset;
    JDGImagePickerConfiguration *config = JDGImagePickerConfiguration.shared;
    [JDGAssetManager.shared asyncResolveAsset:asset size:config.imageSize deliveryMode:PHImageRequestOptionsDeliveryModeFastFormat completion:^(NSArray<UIImage *> * _Nullable images, NSError * _Nullable error) {
        dispatch_main_async_jdg_safe(^{
            self.imageView.image = images.firstObject;
        });
    }];
    [self setSelected:isSelected animated:NO];
}

@end
