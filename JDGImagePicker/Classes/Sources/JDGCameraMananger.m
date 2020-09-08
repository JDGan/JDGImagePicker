//
//  JDGCameraMananger.m
//  JDGImagePicker
//
//  Created by JDGan on 2020/8/28.
//

#import "JDGCameraMananger.h"
#import "JDGImagePicker.h"

typedef void(^JDGLockInputDeviceBlock)(AVCaptureDevice *device);
typedef BOOL(^JDGCheckIsInputDeviceSupportBlock)(AVCaptureDevice *device);

@interface JDGCameraMananger () <AVCapturePhotoCaptureDelegate>

@property (nonatomic, assign) BOOL defaultStartWithBackCamera;
@property (nonatomic, assign) BOOL isInitialized;

@property (nonatomic, retain) dispatch_queue_t queue;

@property (nonatomic, retain) AVCaptureSession *captureSession;

@property (nonatomic, retain) AVCaptureDeviceInput *frontCamera;
@property (nonatomic, retain) AVCaptureDeviceInput *backCamera;

@property (nonatomic, retain) AVCapturePhotoOutput *photoOutput;
@property (nonatomic, assign) AVCaptureFlashMode photoOutputFlashMode;

@property (assign, nonatomic) CGFloat currentZoomFactor;
@property (assign, nonatomic) CGFloat previousZoomFactor;

@end

@implementation JDGCameraMananger

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isInitialized = NO;
        self.queue = dispatch_queue_create("JDGImagePicker.CameraSession", nil);
        self.captureSession = [[AVCaptureSession alloc] init];
        
        self.currentZoomFactor = 1;
        self.previousZoomFactor = 1;
    }
    return self;
}

- (void)setup:(BOOL)isDefaultBackCamera {
    self.defaultStartWithBackCamera = isDefaultBackCamera;
    [self checkPermission];
}

- (void)setupDevices {
    NSMutableArray*deviceTypes = [NSMutableArray array];
    if(@available(iOS 13.0, *)) {
        [deviceTypes addObject:AVCaptureDeviceTypeBuiltInTripleCamera];
        [deviceTypes addObject:AVCaptureDeviceTypeBuiltInDualWideCamera];
        [deviceTypes addObject:AVCaptureDeviceTypeBuiltInUltraWideCamera];
    }
    if(@available(iOS 11.1, *)) {
        [deviceTypes addObject:AVCaptureDeviceTypeBuiltInTrueDepthCamera];
    }
    if(@available(iOS 10.2, *)) {
        [deviceTypes addObject:AVCaptureDeviceTypeBuiltInDualCamera];
    }
    if(@available(iOS 10.0, *)) {
        [deviceTypes addObject:AVCaptureDeviceTypeBuiltInTelephotoCamera];
        [deviceTypes addObject:AVCaptureDeviceTypeBuiltInWideAngleCamera];
//        [deviceTypes addObject:AVCaptureDeviceTypeBuiltInMicrophone];
    }
    
    AVCaptureDeviceDiscoverySession *s = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:deviceTypes mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionUnspecified];
    for(AVCaptureDevice *device in s.devices) {
        if (device.position == AVCaptureDevicePositionFront) {
            self.frontCamera = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        } else if (device.position == AVCaptureDevicePositionBack) {
            if(self.backCamera == nil) {
                self.backCamera = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
            }
        }
    }
    self.photoOutput = [AVCapturePhotoOutput new];
    [self changeFlashMode:AVCaptureFlashModeOn];
}

- (void)addInput:(AVCaptureDeviceInput *)input {
    NSArray * prefferedPresets = @[AVCaptureSessionPresetHigh,AVCaptureSessionPresetMedium,AVCaptureSessionPresetLow];
    for(AVCaptureSessionPreset preset in prefferedPresets) {
        if ([input.device supportsAVCaptureSessionPreset:preset]
            && [self.captureSession canSetSessionPreset:preset]) {
            self.captureSession.sessionPreset = preset;
            break;
        }
    }
    if([self.captureSession canAddInput:input]) {
        [self.captureSession addInput:input];
    }
    if([self.delegate respondsToSelector:@selector(cameraMananger:didChangeInput:)]) {
        dispatch_main_async_jdg_safe(^{
            [self.delegate cameraMananger:self didChangeInput:input];
        });
    }
}

- (void)checkPermission {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusAuthorized:
        {
            [self start];
        }
            break;
        case AVAuthorizationStatusNotDetermined:
        {
            [self requestPermission];
        }
            break;
        default:
        {
            if ([self.delegate respondsToSelector:@selector(cameraManangerDeviceUnavailable:)]) {
                dispatch_main_async_jdg_safe(^{
                    [self.delegate cameraManangerDeviceUnavailable:self];
                });
            }
        }
            break;
    }
}

- (void)requestPermission {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (granted) {
            [self start];
        } else {
            if ([self.delegate respondsToSelector:@selector(cameraManangerDeviceUnavailable:)]) {
                dispatch_main_async_jdg_safe(^{
                    [self.delegate cameraManangerDeviceUnavailable:self];
                });
            }
        }
    }];
}

- (AVCaptureDeviceInput *)currentInput {
    return self.captureSession.inputs.firstObject;
}

- (void)start {
    [self setupDevices];
    if(self.backCamera == nil) {return;}
    if(self.photoOutput == nil) {return;}
    
    [self addInput:self.backCamera];
    if ([self.captureSession canAddOutput:self.photoOutput]) {
        [self.captureSession addOutput:self.photoOutput];
    }
    
    dispatch_async(self.queue, ^{
        [self.captureSession startRunning];
        if([self.delegate respondsToSelector:@selector(cameraMananger:didStartCaptureSession:)]) {
            dispatch_main_async_jdg_safe(^{
                [self.delegate cameraMananger:self didStartCaptureSession:self.captureSession];
            });
            self.isInitialized = YES;
        }
    });
}

- (void)stop {
    if ([self.captureSession isRunning]) {
        [self.captureSession stopRunning];
    }
}

- (void)resume {
    if (self.isInitialized && ![self.captureSession isRunning]) {
        [self.captureSession startRunning];
    }
}

- (void)pause {
    [self stop];
}

- (void)switchCamera {
    AVCaptureDeviceInput *target = ([self currentInput] == self.backCamera)? self.frontCamera : self.backCamera;
    if([self currentInput] == nil || target == nil) {
        return;
    }
    dispatch_async(self.queue, ^{
        [self.captureSession beginConfiguration];
        [self.captureSession removeInput:[self currentInput]];
        [self.captureSession addInput:target];
        [self.captureSession commitConfiguration];
        if([self.delegate respondsToSelector:@selector(cameraMananger:didChangeInput:)]) {
            dispatch_main_async_jdg_safe(^{
                [self.delegate cameraMananger:self didChangeInput:target];
            });
        }
    });
}

- (void)takePicture {
    AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettingsWithFormat:@{AVVideoCodecKey:AVVideoCodecTypeJPEG}];
    settings.flashMode = self.photoOutputFlashMode;
    [self.photoOutput capturePhotoWithSettings:settings delegate:self];
}


- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(NSError *)error {
    if (error) {
        if ([self.delegate respondsToSelector:@selector(cameraMananger:didCatchError:)]) {
            dispatch_main_async_jdg_safe(^{
                [self.delegate cameraMananger:self didCatchError:error];
            });
        }
        return;
    }
    [self savePhoto:photo];
}

- (void)savePhoto:(AVCapturePhoto *)photo {
    if([self.delegate respondsToSelector:@selector(cameraMananger:didSaveCapturePhoto:)]) {
        dispatch_main_async_jdg_safe(^{
            [self.delegate cameraMananger:self didSaveCapturePhoto:photo];
        });
    }
}

- (void)lockInputDevice:(JDGCheckIsInputDeviceSupportBlock)check excute:(JDGLockInputDeviceBlock)block {
    AVCaptureDevice *device = [self currentInput].device;
    if(!check(device)) {
        return;
    }
    dispatch_async(self.queue, ^{
        NSError *error = nil;
        [device lockForConfiguration:&error];
        if (error == nil) {
            block(device);
            [device unlockForConfiguration];
        }
    });
}

- (void)focusToPoint:(CGPoint)point {
    [self lockInputDevice:^BOOL(AVCaptureDevice *device) {
        return [device isFocusModeSupported:AVCaptureFocusModeLocked];
    } excute:^(AVCaptureDevice *device) {
        device.focusPointOfInterest = point;
    }];
}

- (void)zoomToFactor:(CGFloat)factor {
    [self lockInputDevice:^BOOL(AVCaptureDevice *device) {
        return device.position == AVCaptureDevicePositionBack;
    } excute:^(AVCaptureDevice *device) {
        device.videoZoomFactor = factor;
    }];
}

- (void)changeFlashMode:(AVCaptureFlashMode)mode {
    if([self.photoOutput.supportedFlashModes containsObject:@(mode)]) {
        self.photoOutputFlashMode = mode;
    }
}

- (void)zoomToScale:(CGFloat)scale isEnded:(BOOL)isEnded {
    AVCaptureDevice *device = [self currentInput].device;
    if(device == nil) {return;}
    CGFloat maxDeviceZoomFactor = device.activeFormat.videoMaxZoomFactor;
    CGFloat newZoomFactor = self.previousZoomFactor * scale;
    const CGFloat MAX_ZOOM_FACTOR = 3.0;
    const CGFloat MIN_ZOOM_FACTOR = 1.0;
    self.currentZoomFactor = MIN(MAX_ZOOM_FACTOR, MAX(MIN_ZOOM_FACTOR, MIN(newZoomFactor, maxDeviceZoomFactor)));
    
    [self zoomToFactor:self.currentZoomFactor];
    
    if(isEnded) {
        self.previousZoomFactor = self.currentZoomFactor;
    }
}

@end
