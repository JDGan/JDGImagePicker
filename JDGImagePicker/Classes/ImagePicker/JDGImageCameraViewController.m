//
//  JDGImageCameraViewController.m
//  JDGImagePicker
//
//  Created by JDGan on 2020/8/31.
//

#import "JDGImageCameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <PhotosUI/PhotosUI.h>

#import "JDGImagePicker.h"
#import "JDGAssetManager.h"
#import "JDGCameraMananger.h"

@interface JDGImageCameraViewController () <JDGCameraManangerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *focusImageView;

@property (nonatomic, retain) NSTimer *animationTimer;

@property (nonatomic, retain) JDGCameraMananger *cameraManager;

@property (retain, nonatomic) UIView *cameraActionBoardView;

@property (weak, nonatomic) IBOutlet UIView *cameraNotAvailableView;

@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UIButton *switchCameraButton;

@property (nonatomic, assign) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation JDGImageCameraViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.focusImageView];
    self.focusImageView.alpha = 0;
    self.focusImageView.backgroundColor = UIColor.clearColor;
    self.cameraNotAvailableView.hidden = YES;

    [self updateFlashButtonUI];
    
    self.cameraManager = [JDGCameraMananger new];
    self.cameraManager.delegate = self;
    // 启动相机
    [self.cameraManager setup:YES];
    
    UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
    view.backgroundColor = UIColor.blackColor;
    view.userInteractionEnabled = NO;
    view.alpha = 0;
    [self.view addSubview:view];
    self.cameraActionBoardView = view;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    JDGImagePickerConfiguration *config = JDGImagePickerConfiguration.shared;
    if(config.allowAudioSession) {
        NSError *error = nil;
        [AVAudioSession.sharedInstance setActive:YES error:&error];
        if(error) {
            NSLog(@"%@",error.localizedDescription);
        }
    }
    [self.cameraManager resume];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.cameraManager pause];
}

- (IBAction)tapGesture:(UITapGestureRecognizer *)sender {
    if(!self.cameraNotAvailableView.hidden) {return;}
    CGPoint touchPoint = [sender locationInView:self.view];
    self.focusImageView.transform = CGAffineTransformIdentity;
    [self.animationTimer invalidate];
    self.animationTimer = nil;
    CGPoint convertedPoint = CGPointMake(touchPoint.x/self.view.frame.size.width, touchPoint.y/self.view.frame.size.height);
    [self.cameraManager focusToPoint:convertedPoint];
    self.focusImageView.center = touchPoint;
    [UIView animateWithDuration:0.5 animations:^{
        self.focusImageView.alpha = 1;
        self.focusImageView.transform = CGAffineTransformMakeScale(0.6, 0.6);
    } completion:^(BOOL finished) {
        self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(animationEndAndResetFocusView) userInfo:nil repeats:NO];
    }];
}

- (IBAction)pinchGesture:(UIPinchGestureRecognizer *)sender {
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
        {
            [self.cameraManager zoomToScale:sender.scale isEnded:NO];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            [self.cameraManager zoomToScale:sender.scale isEnded:YES];
        }
            break;
        default:
            break;
    }
}


- (void)animationEndAndResetFocusView {
    [UIView animateWithDuration:0.3 animations:^{
        self.focusImageView.alpha = 0;
    } completion:^(BOOL finished) {
        self.focusImageView.transform = CGAffineTransformIdentity;
    }];
}

- (void)updateFlashButtonUI {
    JDGImagePickerConfiguration *config = JDGImagePickerConfiguration.shared;
    NSArray *titles = @[@"AUTO", @"ON", @"OFF"];
    NSArray *colors = @[config.flashAutoColor, config.flashOnColor, config.flashOffColor];
    NSString *cTitle = self.flashButton.currentTitle;
    NSUInteger index = [titles indexOfObject:cTitle];
    if(index == NSNotFound) {
        index = 2;
    }
    index = (index+1)%titles.count;
    [self.flashButton setTitle:titles[index] forState:UIControlStateNormal];
    [self.flashButton setTitleColor:colors[index] forState:UIControlStateNormal];
    self.flashButton.tintColor = colors[index];
    [self.flashButton setImage:[[JDGAssetManager.shared getImageForName:@"flashIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];

}

- (IBAction)goSettingsPressed:(id)sender {
    NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if([UIApplication.sharedApplication canOpenURL:settingsURL]) {
        [UIApplication.sharedApplication openURL:settingsURL options:@{} completionHandler:nil];
    }
}

- (IBAction)flashButtonPressed:(UIButton *)sender {
    [self updateFlashButtonUI];
}

- (IBAction)switchCameraButtonPressed:(id)sender {
    [self.cameraManager switchCamera];
}

- (void)takePhoto {
    if (self.previewLayer == nil) {return;}
    self.cameraActionBoardView.alpha = 1;
    self.cameraActionBoardView.userInteractionEnabled = YES;
    [UIView animateWithDuration:0.1 delay:0.1 options:UIViewAnimationOptionCurveEaseIn  animations:^{
        self.cameraActionBoardView.alpha = 0;
    } completion:^(BOOL finished) {
        self.cameraActionBoardView.userInteractionEnabled = NO;
    }];
    [self.cameraManager takePicture];
}

#pragma mark - JDGCameraManangerDelegate
- (void)cameraManangerDeviceUnavailable:(JDGCameraMananger *)manager {
    self.cameraNotAvailableView.hidden = NO;
}

- (void)cameraMananger:(JDGCameraMananger *)manager didCatchError:(NSError *)error {
    NSLog(@"%@",error.localizedDescription);
}

- (void)cameraMananger:(JDGCameraMananger *)manager didChangeInput:(AVCaptureDeviceInput *)input {
    if(JDGImagePickerConfiguration.shared.enableFlashMode && input.device.position == AVCaptureDevicePositionBack) {
        self.flashButton.hidden = !input.device.hasFlash;
    } else {
        self.flashButton.hidden = YES;
    }
}

- (void)cameraMananger:(JDGCameraMananger *)manager didStartCaptureSession:(AVCaptureSession *)session {
    JDGImagePickerConfiguration *config = JDGImagePickerConfiguration.shared;
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    previewLayer.backgroundColor = config.mainColor.CGColor;
    previewLayer.autoreverses = YES;
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer insertSublayer:previewLayer atIndex:0];
    previewLayer.frame = self.view.layer.bounds;
    self.view.clipsToBounds = YES;
    self.previewLayer = previewLayer;
}

- (void)cameraMananger:(JDGCameraMananger *)manager didSaveCapturePhoto:(AVCapturePhoto *)avPhoto {
    // 得到照片
    JDGImagePickerPhoto *photo = [JDGImagePickerPhoto photoWithCapturePhoto:avPhoto];
    [JDGImagePicker.shared.photoStack push:photo];
}

- (void)rotateUIForOrientation:(UIDeviceOrientation)orientation {
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
    
    NSArray *transformAnimateArray = @[self.switchCameraButton,self.cameraNotAvailableView];
    CGAffineTransform flashButtonTransform = CGAffineTransformIdentity;
    if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
        flashButtonTransform = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation(-20, 15));
    } else {
        flashButtonTransform = transform;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        for(UIView *view in transformAnimateArray) {
            view.transform = transform;
        }
        self.flashButton.transform = flashButtonTransform;
    }];
}

@end
