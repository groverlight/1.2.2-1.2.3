
//! \file   VideoCapture.m
//! \brief  Recovery of a video stream.
//__________________________________________________________________________________________________

#import <QuartzCore/QuartzCore.h>

#import "GlobalParameters.h"
#import "Tools.h"
#import "VideoCapture.h"
//__________________________________________________________________________________________________

static VideoCapture* SharedVideoCapture = nil;
//__________________________________________________________________________________________________

//! Capture of a video stream.
@interface VideoCapture()
{
  BOOL              CaptureOn;        //!< Flag indication that the capture is active.
  BlockAction       StartCompletion;  //!< Completion block called after starting capture.
  BlockAction     	StopCompletion;   //!< Cmpletion block called after capture stopped.
  AVCaptureDevice*	CaptureDevice;
}
//__________________________________________________________________________________________________
@end

//! Capture of a video stream.
@implementation VideoCapture
@synthesize captureSession;
@synthesize previewLayer;
//__________________________________________________________________________________________________

+ (VideoCapture*) sharedCapture
{
  NSLog(@"1 sharedCapture: SharedVideoCapture: %p", SharedVideoCapture);
  if (SharedVideoCapture == nil)
  {
    SharedVideoCapture = [[VideoCapture alloc] init];
    [SharedVideoCapture setupCaptureSession];
    NSLog(@"2 sharedCapture: SharedVideoCapture: %p", SharedVideoCapture);
  }
  return SharedVideoCapture;
}
//__________________________________________________________________________________________________

- (id)init
{
  NSLog(@"VideoCapture init");
	self = [super init];
	if (self)
	{
    CaptureOn = false;
    StartCompletion = ^
    { // Default action: do nothing!
    };
    StopCompletion = ^
    { // Default action: do nothing!
    };
	}
	return self;
}
//__________________________________________________________________________________________________

- (void)dealloc
{
}
//__________________________________________________________________________________________________

- (BOOL)captureActive
{
  return CaptureOn;
}
//__________________________________________________________________________________________________

//! Create and configure a capture session and start it running.
- (void)setupCaptureSession
{
  NSLog(@"1 setupCaptureSession");
  // Create the session
  captureSession = [[AVCaptureSession alloc] init];
  captureSession.sessionPreset = AVCaptureSessionPresetMedium;

  // Find a suitable AVCaptureDevice.
  NSArray* video_devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
  CaptureDevice = nil;
  if (!GetGlobalParameters().cameraUseBackCamera)
  {
    for (AVCaptureDevice* device in video_devices)
    {
      if (device.position == AVCaptureDevicePositionFront)
      {
        CaptureDevice = device;
        break;
      }
    }
  }
  if (CaptureDevice == nil)
  {
    CaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  }
  if (CaptureDevice != nil)
  {
    NSError* error;
    if ([CaptureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
    {
      if ([CaptureDevice lockForConfiguration:&error])
      {
        CaptureDevice.activeVideoMaxFrameDuration = CMTimeMake(1, 10);
        [CaptureDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        if ([CaptureDevice isFocusPointOfInterestSupported])
        {
          [CaptureDevice setFocusPointOfInterest:CGPointMake(0.5f,0.5f)];
        }
        [CaptureDevice unlockForConfiguration];
      }
    }
    // Create device inputs with the devices and add them to the session.
    AVCaptureDeviceInput* video_input = [AVCaptureDeviceInput deviceInputWithDevice:CaptureDevice error:&error];
    [captureSession addInput:video_input];
  }

  previewLayer              = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
  previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
  [self setManualCameraControls];
  NSLog(@"2 setupCaptureSession");
}
//__________________________________________________________________________________________________

//! Stop the capture session and release all its resources.
- (void)cleanupCaptureSession:(BlockAction)completion
{
  NSLog(@"cleanupCaptureSession");
  [self stopCaptureInBackbround:^
  {
    previewLayer        = nil;
    CaptureDevice       = nil;
    captureSession      = nil;
    SharedVideoCapture  = nil;
    NSLog(@"stopCapture completion");
    completion();
  }];
}
//__________________________________________________________________________________________________

//! restore the capture session and reallocate all its resources.
+ (void) restoreCaptureSession:(BlockIdAction)completion
{
  NSLog(@"restoreCaptureSession");
  completion([VideoCapture sharedCapture]);
}
//__________________________________________________________________________________________________

- (void)setManualCameraControls
{
  AVCaptureDeviceFormat* format = CaptureDevice.activeFormat;
  NSLog(@"minISO: %f, maxISO: %f, maxWhiteBalanceGain: %f, min/maxExposureTargetBias: %f, %f", format.minISO, format.maxISO, CaptureDevice.maxWhiteBalanceGain, CaptureDevice.minExposureTargetBias, CaptureDevice.maxExposureTargetBias);

  GlobalParameters* parameters = GetGlobalParameters();
  NSError* error;
  if (IsIOS_8())
  {
    if ([CaptureDevice lockForConfiguration:&error])
    {
      [CaptureDevice setExposureTargetBias:parameters.cameraExposureTargetBias completionHandler:nil];
      if (parameters.cameraManualExposureEnabled)
      {
        CMTime inTime = CMTimeMakeWithSeconds(parameters.cameraExposureDuration, 1000);
        [CaptureDevice setExposureModeCustomWithDuration:inTime ISO:parameters.cameraIso completionHandler:nil];
      }
      if (parameters.cameraManualWhiteBalanceEnabled)
      {
        AVCaptureWhiteBalanceGains whiteBalanceGains;
        whiteBalanceGains.redGain   = parameters.cameraWhiteBalanceRedGain;
        whiteBalanceGains.greenGain = parameters.cameraWhiteBalanceGreenGain;
        whiteBalanceGains.blueGain  = parameters.cameraWhiteBalanceBlueGain;
        [CaptureDevice setWhiteBalanceModeLockedWithDeviceWhiteBalanceGains:whiteBalanceGains completionHandler:nil];
      }
      CaptureDevice.automaticallyAdjustsVideoHDREnabled = parameters.cameraAutoVideoHdrEnabled;
      if (CaptureDevice.isLowLightBoostSupported)
      {
        CaptureDevice.automaticallyEnablesLowLightBoostWhenAvailable = parameters.cameraLowLightBoostEnabled;
      }
      [CaptureDevice unlockForConfiguration];
    }
  }
}
//__________________________________________________________________________________________________

- (void)backgroundStartCapture
{
  if (!captureSession.isRunning)
  {
    [captureSession startRunning];
  }
  StartCompletion();
  CaptureOn = true;
}
//__________________________________________________________________________________________________

- (void)backgroundStopCapture
{
  NSLog(@"backgroundStopCapture");
  if (captureSession.isRunning)
  {
    [captureSession stopRunning];
  }
  StopCompletion();
  CaptureOn = false;
}
//__________________________________________________________________________________________________

- (void)stopCaptureInBackbround:(BlockAction)completion
{
  NSLog(@"stopCaptureInBackbround");
  if (captureSession.isRunning)
  {
    [captureSession stopRunning];
  }
  completion();
  CaptureOn = false;
}
//__________________________________________________________________________________________________

- (void)startCapture:(BlockAction)completion
{
  StartCompletion = completion;
  [self performSelectorInBackground:@selector(backgroundStartCapture) withObject:nil];
}
//__________________________________________________________________________________________________

- (void)stopCapture:(BlockAction)completion
{
  NSLog(@"stopCapture");
  StopCompletion = completion;
  [self performSelectorInBackground:@selector(backgroundStopCapture) withObject:nil];
}
//__________________________________________________________________________________________________
@end
