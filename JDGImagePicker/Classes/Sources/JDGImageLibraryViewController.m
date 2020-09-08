//
//  JDGImageLibraryViewController.m
//  JDGImagePicker
//
//  Created by JDGan on 2020/8/31.
//

#import "JDGImageLibraryViewController.h"
#import "JDGImageLibrarySelectionCell.h"
#import "JDGImagePickerAnimations.h"
#import "JDGImagePicker.h"

@interface JDGImageLibraryViewController ()
<
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
UIGestureRecognizerDelegate
>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (retain, nonatomic) NSMutableSet *tempAssets;
@property (assign, nonatomic) BOOL isDetectingSelection;

@end

@implementation JDGImageLibraryViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    self.fromFrame = CGRectNull;
}

- (CGFloat)itemSide {
    JDGImagePickerConfiguration *config = JDGImagePicker.sharedPicker.configuration;
    CGFloat blank = config.libraryItemGap;
    CGFloat count = config.libraryItemMaxCountForLine;
    return floor((self.view.frame.size.width-(count+1)*blank)/count);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tempAssets = [NSMutableSet set];
    
    JDGImagePickerConfiguration *config = JDGImagePicker.sharedPicker.configuration;
    self.view.backgroundColor = UIColor.clearColor;
    self.title = config.libraryViewTitle;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(selectionPan:)];
    pan.delegate = self;
    [self.collectionView addGestureRecognizer:pan];
}

#pragma mark -UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return !self.isDetectingSelection;
}

- (void)selectionPan:(UIPanGestureRecognizer *)pan {
    static CGPoint _startPoint;
    static BOOL _isToDelete = NO;
    CGPoint poi = [pan locationInView:self.collectionView];
    CGPoint velocity = [pan velocityInView:self.collectionView];
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            // 判定为横移
            if(fabs(velocity.x) > 200 && fabs(velocity.y) < 200) {
                self.collectionView.scrollEnabled = NO;
                NSIndexPath *startIndexPath = [self.collectionView indexPathForItemAtPoint:poi];
                PHAsset *asset = JDGAssetManager.shared.libraryAssets[startIndexPath.row];
                JDGImagePickerPhoto *photo = [JDGImagePicker.sharedPicker.photoStack objectForData:asset forType:JDGImagePickerPhotoTypePHAsset];
                if (photo == nil) {
                    _isToDelete = NO;
                } else {
                    _isToDelete = YES;
                }
                _startPoint = poi;
                [self.tempAssets removeAllObjects];
                self.isDetectingSelection = YES;
            } else {
                self.collectionView.scrollEnabled = YES;
                self.isDetectingSelection = NO;
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            if(!self.isDetectingSelection) {return;}
            CGRect frame = CGRectMake(MIN(_startPoint.x, poi.x), MIN(_startPoint.y, poi.y), fabs(_startPoint.x-poi.x), fabs(_startPoint.y-poi.y));
            
            NSArray *vCells = [self.collectionView visibleCells];
            for (JDGImageLibrarySelectionCell *cell in vCells) {
                if (CGRectIntersectsRect(frame, cell.frame)) {
                    [self.tempAssets addObject:cell.asset];
                    [cell setSelected:!_isToDelete animated:NO];
                } else {
                    [self.tempAssets removeObject:cell.asset];
                    BOOL isSelected = [JDGImagePicker.sharedPicker.photoStack containsObject:cell.asset forType:JDGImagePickerPhotoTypePHAsset];
                    [cell setSelected:isSelected animated:NO];
                }
            }
            CGPoint scrollingPoint = [pan locationInView:self.view];
            static BOOL _isAnimating = NO;
            CGFloat animateOffset = 50;
            if(self.collectionView.frame.size.height - scrollingPoint.y < animateOffset && poi.y < self.collectionView.contentSize.height - animateOffset) {
                if (_isAnimating) {return;}
                _isAnimating = YES;
                CGPoint targetPoint;
                targetPoint.y = MIN(self.collectionView.contentSize.height-self.collectionView.frame.size.height, poi.y+animateOffset) ;
                targetPoint.x = 0;
                [UIView animateWithDuration:1 animations:^{
                    [self.collectionView setContentOffset:targetPoint animated:YES];
                } completion:^(BOOL finished) {
                    _isAnimating = NO;
                }];
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            self.collectionView.scrollEnabled = YES;
            if(!self.isDetectingSelection) {return;}
            NSMutableArray *tempPhotoArray = [NSMutableArray array];
            if(_isToDelete) {
                for(PHAsset *asset in self.tempAssets) {
                    JDGImagePickerPhoto *photo = [JDGImagePicker.sharedPicker.photoStack objectForData:asset forType:JDGImagePickerPhotoTypePHAsset];
                    if(photo != nil) {
                        [tempPhotoArray addObject:photo];
                    }
                }
                [JDGImagePicker.sharedPicker.photoStack popPhotosInArray:tempPhotoArray];
            } else {
                for(PHAsset *asset in self.tempAssets) {
                    BOOL isExisted = [JDGImagePicker.sharedPicker.photoStack containsObject:asset forType:JDGImagePickerPhotoTypePHAsset];
                    if(!isExisted) {
                        JDGImagePickerPhoto *photo = [JDGImagePickerPhoto photoWithPHAsset:asset];
                        [tempPhotoArray addObject:photo];
                    }
                }
                [JDGImagePicker.sharedPicker.photoStack pushPhotosInArray:tempPhotoArray];
            }
            [self.tempAssets removeAllObjects];
            self.isDetectingSelection = NO;
        }
            break;
        default:
        {
            self.collectionView.scrollEnabled = YES;
            if(self.isDetectingSelection) {
                self.isDetectingSelection = NO;
                return;
            }
        }
            break;
    }
}

//- (void)edgePan:(UIPanGestureRecognizer *)pan {
//    //产生百分比
//    CGFloat process = [pan translationInView:self.view].x / ([UIScreen mainScreen].bounds.size.width);
//
//    process = MIN(1.0,(MAX(0.0, process)));
//
//    if (pan.state == UIGestureRecognizerStateBegan) {
//        self.pdInteractiveTransition = [UIPercentDrivenInteractiveTransition new];
//        //触发pop转场动画
//        [self.navigationController popViewControllerAnimated:YES];
//
//    }else if (pan.state == UIGestureRecognizerStateChanged){
//        [self.pdInteractiveTransition updateInteractiveTransition:process];
//    }else if (pan.state == UIGestureRecognizerStateEnded
//              || pan.state == UIGestureRecognizerStateCancelled){
//        if (process > 0.5) {
//            [ self.pdInteractiveTransition finishInteractiveTransition];
//        }else{
//            [ self.pdInteractiveTransition cancelInteractiveTransition];
//        }
//        self.pdInteractiveTransition = nil;
//    }
//}

- (id<UIViewControllerAnimatedTransitioning>)navigationAnimationForOperation:(UINavigationControllerOperation)operation {
    if(CGRectIsNull(self.fromFrame)) {return nil;}
    JDGImagePickerConfiguration *config = JDGImagePicker.sharedPicker.configuration;
    if (operation == UINavigationControllerOperationPush) {
        JDGImagePickerPushWithPopoverAnimation *ani = [JDGImagePickerPushWithPopoverAnimation animationForViewController:self];
        ani.willBeginAnimtaionBlock = ^(UIView * _Nonnull fromView, UIView * _Nonnull toView) {
            self.view.frame = self.fromFrame;
            self.view.alpha = 0;
            CGFloat scale = self.itemScaledSide/[self itemSide];
            CGFloat offsetScale = (scale-1)/scale;
            CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
            transform = CGAffineTransformTranslate(transform, (self.view.frame.size.width/2)*offsetScale-config.libraryItemGap, (self.view.frame.size.height/2)*offsetScale+44+config.libraryLiteHeaderHeight/scale-config.libraryItemGap*offsetScale);
            self.collectionView.transform = transform;
        };
        ani.animationBlock = ^(UIView * _Nonnull fromView, UIView * _Nonnull toView) {
            self.view.frame = UIScreen.mainScreen.bounds;
            self.view.alpha = 1;
            self.collectionView.transform = CGAffineTransformIdentity;
        };
        ani.animationCompleteBlock = ^(BOOL isFinished) {
            
        };
        return ani;
    }
    
    if (operation == UINavigationControllerOperationPop) {
        JDGImagePickerPopWithPopoverAnimation *ani = [JDGImagePickerPopWithPopoverAnimation animationForViewController:self];
        ani.willBeginAnimtaionBlock = ^(UIView * _Nonnull fromView, UIView * _Nonnull toView) {
            self.view.frame = UIScreen.mainScreen.bounds;
            self.view.alpha = 1;
            self.collectionView.transform = CGAffineTransformIdentity;
        };
        ani.animationBlock = ^(UIView * _Nonnull fromView, UIView * _Nonnull toView) {
            self.view.frame = self.fromFrame;
            self.view.alpha = 0;
            CGFloat scale = self.itemScaledSide/[self itemSide];
            CGFloat offsetScale = (scale-1)/scale;
            CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
            transform = CGAffineTransformTranslate(transform, (self.view.frame.size.width/2)*offsetScale-config.libraryItemGap, (self.view.frame.size.height/2)*offsetScale+44+config.libraryLiteHeaderHeight/scale-config.libraryItemGap*offsetScale);
            self.collectionView.transform = transform;
        };
        ani.animationCompleteBlock = ^(BOOL isFinished) {
            
        };
        return ani;
    }
    
    return nil;
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return JDGAssetManager.shared.libraryAssets.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:@"JDGImageLibrarySelectionCell" forIndexPath:indexPath];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)aCell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (![aCell isKindOfClass:[JDGImageLibrarySelectionCell class]]) {return;}
    JDGImageLibrarySelectionCell *cell = (JDGImageLibrarySelectionCell *)aCell;
    PHAsset *asset = JDGAssetManager.shared.libraryAssets[indexPath.row];
    BOOL isSelected = [JDGImagePicker.sharedPicker.photoStack containsObject:asset forType:JDGImagePickerPhotoTypePHAsset];
    [cell customizeWithData:asset isSelected:isSelected];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat h = [self itemSide];
    return CGSizeMake(h, h);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    JDGImagePickerConfiguration *config = JDGImagePicker.sharedPicker.configuration;
    return config.libraryItemGap;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    JDGImagePickerConfiguration *config = JDGImagePicker.sharedPicker.configuration;
    return config.libraryItemGap;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    JDGImagePickerConfiguration *config = JDGImagePicker.sharedPicker.configuration;
    CGFloat sideGap = config.libraryItemGap;
    return UIEdgeInsetsMake(sideGap, sideGap, sideGap, sideGap);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    JDGImageLibrarySelectionCell *cell = (JDGImageLibrarySelectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    JDGImagePickerPhoto *photo = [JDGImagePicker.sharedPicker.photoStack objectForData:cell.asset forType:JDGImagePickerPhotoTypePHAsset];
    BOOL isSelected = photo != nil;
    if (!isSelected) {
        photo = [JDGImagePickerPhoto photoWithPHAsset:JDGAssetManager.shared.libraryAssets[indexPath.row]];
        [JDGImagePicker.sharedPicker.photoStack push:photo];
    } else {
        [JDGImagePicker.sharedPicker.photoStack pop:photo];
    }
    
    [cell setSelected:!isSelected animated:YES];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
