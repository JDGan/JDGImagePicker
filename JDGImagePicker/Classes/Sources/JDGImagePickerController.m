//
//  JDGImagePickerController.m
//  JDGImagePicker-JDGImagePicker
//
//  Created by JDGan on 2020/8/28.
//

#import "JDGImagePickerController.h"

#import "JDGImagePicker.h"
#import "JDGImageCameraViewController.h"
#import "JDGImageLibraryLiteViewController.h"
#import "JDGImageSelectionViewController.h"

#import "JDGImageLibraryViewController.h"

@interface JDGImagePickerController ()

@property (nonatomic, retain) JDGImageCameraViewController *cameraVC;

@property (nonatomic, retain) JDGImageLibraryLiteViewController *libraryLiteVC;

@property (nonatomic, retain) JDGImageLibraryViewController *libraryVC;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *libraryHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIView *extendBottomView;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *bottomBackgroundView;

@property (weak, nonatomic) IBOutlet UIView *cameraActionButtonFrontView;
@property (weak, nonatomic) IBOutlet UIButton *cameraActionButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (weak, nonatomic) IBOutlet UIButton *imageStackButton;

@property (retain, nonatomic) NSMutableArray *imageViewStacks;

@end

@implementation JDGImagePickerController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Camera"]) {
        self.cameraVC = segue.destinationViewController;
    } else if([segue.identifier isEqualToString:@"LibraryLite"]) {
        self.libraryLiteVC = segue.destinationViewController;
    }
}

- (void)addGestures {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(libraryPanGesture:)];
    [self.libraryLiteVC.view addGestureRecognizer:pan];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hideNavigationBar = YES;
    
    self.libraryVC = [JDGImageLibraryViewController create];
    
    JDGImagePickerConfiguration *config = [JDGImagePicker.sharedPicker configuration];
    self.bottomView.backgroundColor = config.maskViewBackgroundColor;
    self.extendBottomView.backgroundColor = self.bottomView.backgroundColor;
    self.libraryLiteVC.view.backgroundColor = self.bottomView.backgroundColor;
    
    CGFloat height = self.cameraActionButton.frame.size.height;
    self.cameraActionButton.layer.cornerRadius = height/2;
    self.cameraActionButton.layer.masksToBounds = YES;
    [self.cameraActionButton setTitleColor:config.cameraButtonTitleColor forState:UIControlStateNormal];
    self.cameraActionButton.titleLabel.font = config.cameraButtonTitleFont;
    self.cameraActionButton.layer.borderWidth = 2;
    self.cameraActionButtonFrontView.layer.cornerRadius = self.cameraActionButtonFrontView.frame.size.height/2;
    self.cameraActionButtonFrontView.layer.masksToBounds = YES;
    [self updateCameraButtonWhileHighlighted:NO];
    
    [self.cancelButton setTitle:config.cancelButtonTitle forState:UIControlStateNormal];
    
    self.imageViewStacks = [NSMutableArray arrayWithCapacity:config.imageStackCount];
    CGFloat h = self.imageStackButton.frame.size.height;
    CGFloat w = self.imageStackButton.frame.size.width;
    for (NSUInteger i=0;i<config.imageStackCount;i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        imageView.layer.borderColor = UIColor.whiteColor.CGColor;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.borderWidth = 1;
        imageView.layer.cornerRadius = 2;
        imageView.layer.masksToBounds = YES;
        CGFloat offset = (config.imageStackCount/2.0)*1.5 - i*1.5;
        imageView.center = CGPointMake(w/2+offset, h/2+offset);
        imageView.hidden = YES;
        [self.imageStackButton addSubview:imageView];
        [self.imageViewStacks addObject:imageView];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidChangeOrientation:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [JDGImagePicker.sharedPicker.photoStack addObserver:self forKeyPath:@"selectedPhotos" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
    [self addGestures];
}

- (void)updateCameraButtonWhileHighlighted:(BOOL)isHighlighted {
    JDGImagePickerConfiguration *config = [JDGImagePicker.sharedPicker configuration];
    self.cameraActionButtonFrontView.backgroundColor = isHighlighted ? config.cameraButtonHighlightedColor : config.cameraButtonColor;
    self.cameraActionButton.layer.borderColor = self.cameraActionButtonFrontView.backgroundColor.CGColor;
}

- (void)updateCameraButtonTitle {
    JDGImagePickerConfiguration *config = [JDGImagePicker.sharedPicker configuration];
    NSUInteger selectedCount = JDGImagePicker.sharedPicker.photoStack.selectedPhotos.count;
    if(selectedCount > 1) {
        [self.cameraActionButton setTitle:[NSString stringWithFormat:@"%lu",(unsigned long)selectedCount] forState:UIControlStateNormal];
    } else {
        [self.cameraActionButton setTitle:@"" forState:UIControlStateNormal];
    }
    if(selectedCount > 0) {
        [self.cancelButton setTitle:config.doneButtonTitle forState:UIControlStateNormal];
    } else {
        [self.cancelButton setTitle:config.cancelButtonTitle forState:UIControlStateNormal];
    }
}

- (IBAction)cameraButtonTouchCancel:(id)sender {
    [self updateCameraButtonWhileHighlighted:NO];
}

- (IBAction)cameraButtonTouchDown:(id)sender {
    [self updateCameraButtonWhileHighlighted:YES];
}

- (IBAction)cameraButtonTouchUpOutside:(id)sender {
    [self updateCameraButtonWhileHighlighted:NO];
}

- (IBAction)cameraButtonPressed:(UIButton *)sender {
    [self updateCameraButtonWhileHighlighted:NO];
    [self.cameraVC takePhoto];
}

- (IBAction)cancelPressed:(UIButton *)sender {
    [JDGImagePicker.sharedPicker dismiss];
}

- (IBAction)imageStackButtonPressed:(UIButton *)sender {
    if(JDGImagePicker.sharedPicker.photoStack.selectedPhotos.count <= 0) {return;}
    JDGImageSelectionViewController *previewVC = [JDGImageSelectionViewController create];
    [self.navigationController pushViewController:previewVC animated:YES];
}

- (void)updateImageStackUI {
    JDGImagePickerConfiguration *config = JDGImagePicker.sharedPicker.configuration;
    NSArray *currentAssets = JDGImagePicker.sharedPicker.photoStack.selectedPhotos;
    NSUInteger length = MIN(config.imageStackCount, currentAssets.count);
    NSArray *result = [currentAssets subarrayWithRange:NSMakeRange(currentAssets.count-length, length)];
    for(NSUInteger i=0;i<self.imageViewStacks.count;i++) {
        UIImageView *imageView = self.imageViewStacks[i];
        if (result.count > i) {
            JDGImagePickerPhoto *photo = result[i];
            [photo getThumbnailImageInMainQueueCompletion:^(UIImage * _Nullable image, NSError * _Nullable error) {
                if (error == nil) {
                    imageView.image = image;
                    imageView.hidden = NO;
                }
            }];
        } else {
            imageView.hidden = YES;
        }
    }
}

- (void)libraryPanGesture:(UIPanGestureRecognizer *)ges {
    static CGRect libraryInitialFrame;
    static CGPoint libraryInitialContentOffset;
    static BOOL libraryInitialAnimation = YES;
    CGPoint translation = [ges translationInView:self.view];
    CGPoint velocity = [ges velocityInView:self.view];
    
    CGFloat height = libraryInitialFrame.size.height - translation.y;
    CGAffineTransform transform = self.libraryLiteVC.collectionView.transform;
    UIEdgeInsets inset = self.libraryLiteVC.collectionView.contentInset;
    
    JDGImagePickerConfiguration *config = JDGImagePicker.sharedPicker.configuration;
    if (height > config.libraryLiteHeightMax || !libraryInitialAnimation) {
        [self panToShowLibrary:ges isBegan:libraryInitialAnimation];
        if(libraryInitialAnimation) {
            libraryInitialAnimation = NO;
        }
    }
    switch (ges.state) {
        case UIGestureRecognizerStateBegan:
        {
            libraryInitialFrame = self.libraryLiteVC.view.frame;
            libraryInitialContentOffset = self.libraryLiteVC.collectionView.contentOffset;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            if(height > config.libraryLiteHeightMax) {
                height = config.libraryLiteHeightMax;
                CGFloat scale = (height-config.libraryLiteHeaderHeight)/(config.libraryLiteHeightMin-config.libraryLiteHeaderHeight);
                inset.right = self.view.frame.size.width*(scale-1)/scale;
                transform = CGAffineTransformMakeScale(scale, scale);
            } else if(height < config.libraryLiteHeaderHeight) {
                height = config.libraryLiteHeaderHeight;
                inset = UIEdgeInsetsZero;
                transform = CGAffineTransformIdentity;
            } else {
                if(height >= config.libraryLiteHeightMin) {
                    CGFloat scale = (height-config.libraryLiteHeaderHeight)/(config.libraryLiteHeightMin-config.libraryLiteHeaderHeight);
                    inset.right = self.view.frame.size.width*(scale-1)/scale;
                    transform = CGAffineTransformMakeScale(scale, scale);
                } else {
                    inset = UIEdgeInsetsZero;
                    transform = CGAffineTransformIdentity;
                }
            }
            
            self.libraryLiteVC.collectionView.transform = transform;
            self.libraryLiteVC.collectionView.contentInset = inset;
            self.libraryHeightConstraint.constant = height;
            [self.view updateConstraintsIfNeeded];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            if(self.libraryHeightConstraint.constant < config.libraryLiteHeightMin && velocity.y < 0) {
                height = config.libraryLiteHeightMin;
                transform = CGAffineTransformIdentity;
                inset = UIEdgeInsetsZero;
            } else if (velocity.y > -config.libraryLiteVelocityBoundary && height > config.libraryLiteHeightMax) {
                height = config.libraryLiteHeightMax;
                CGFloat scale = (height-config.libraryLiteHeaderHeight)/(config.libraryLiteHeightMin-config.libraryLiteHeaderHeight);
                inset.right = self.view.frame.size.width*(scale-1)/scale;
                transform = CGAffineTransformMakeScale(scale, scale);
            } else if (velocity.y > config.libraryLiteVelocityBoundary || height < config.libraryLiteHeightMin) {
                height = config.libraryLiteHeaderHeight;
                transform = CGAffineTransformIdentity;
                inset = UIEdgeInsetsZero;
            } else {
                return;
            }

            [UIView animateWithDuration:0.3 animations:^{
                self.libraryLiteVC.collectionView.transform = transform;
                self.libraryHeightConstraint.constant = height;
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                self.libraryLiteVC.collectionView.contentInset = inset;
                libraryInitialAnimation = YES;
            }];
        }
            break;
        default:
        {
            libraryInitialAnimation = YES;
        }
            break;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == JDGImagePicker.sharedPicker.photoStack) {
        if ([keyPath isEqualToString:@"selectedPhotos"]) {
            dispatch_main_async_jdg_safe(^{
                [self updateImageStackUI];
                [self updateCameraButtonTitle];
            });
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)panToShowLibrary:(UIPanGestureRecognizer *)pan isBegan:(BOOL)isBegan {
    if (self.libraryVC == nil) { return; }
    if (isBegan) {
        CGRect targetFrame = self.bottomBackgroundView.frame;
        self.libraryVC.fromFrame = targetFrame;
        JDGImagePickerConfiguration *config = JDGImagePicker.sharedPicker.configuration;
        CGFloat h = config.libraryLiteHeightMin - config.libraryLiteHeaderHeight;
        self.libraryVC.itemScaledSide = h * self.libraryLiteVC.collectionView.transform.a;
    }
    //产生百分比
    CGPoint location = [pan locationInView:self.view];
    CGFloat process = (self.libraryVC.fromFrame.origin.y - location.y) / (self.libraryVC.fromFrame.origin.y);
    process = MIN(1.0,(MAX(0.0, process)));

    if (isBegan) {
        self.libraryVC.pdInteractiveTransition = [UIPercentDrivenInteractiveTransition new];
        //触发转场动画
        [self.navigationController pushViewController:self.libraryVC animated:YES];

    } else if (pan.state == UIGestureRecognizerStateChanged){
        [self.libraryVC.pdInteractiveTransition updateInteractiveTransition:process];
    } else if (pan.state == UIGestureRecognizerStateEnded
              || pan.state == UIGestureRecognizerStateCancelled){
        if (process > 0.5) {
            [self.libraryVC.pdInteractiveTransition finishInteractiveTransition];
        }else{
            [self.libraryVC.pdInteractiveTransition cancelInteractiveTransition];
        }
        self.libraryVC.pdInteractiveTransition = nil;
    }
}

- (void)rotatoUIForOrientation:(UIDeviceOrientation)orientation {
//    if(self.previousOrientation == orientation) {return;}
    CGAffineTransform transform;
    switch (orientation) {
        case UIDeviceOrientationPortraitUpsideDown:
        {
            transform = CGAffineTransformMakeRotation(M_PI);
        }
            break;
        case UIDeviceOrientationLandscapeRight:
        {
            transform = CGAffineTransformMakeRotation(-M_PI_2);
        }
            break;
        case UIDeviceOrientationLandscapeLeft:
        {
            transform = CGAffineTransformMakeRotation(M_PI_2);
        }
            break;
        default:
        {
            transform = CGAffineTransformIdentity;
        }
            break;
    }
    NSArray *transformAnimateArray = @[self.imageStackButton,self.cameraActionButton,self.cancelButton];
    [UIView animateWithDuration:0.3 animations:^{
        for(UIView *view in transformAnimateArray) {
            view.transform = transform;
        }
    }];
    
    [self.libraryLiteVC rotateUIForOrientation:orientation];
    [self.cameraVC rotateUIForOrientation:orientation];
}

- (void)deviceDidChangeOrientation:(NSNotification *)note {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation == UIDeviceOrientationUnknown || orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown) {return;}
    [self rotatoUIForOrientation:orientation];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
