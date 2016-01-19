
//! \file   StillImageCapture.h
//! \brief  Still image capture.
//__________________________________________________________________________________________________

//#import <QuartzCore/QuartzCore.h>

#import "Blocks.h"
#import "StillImageCapture.h"
#import "VideoCapture.h"
#import "Mixpanel.h"
#import <AudioToolbox/AudioToolbox.h>
//__________________________________________________________________________________________________

static StillImageCapture* SharedStillImageCapture = nil;
//__________________________________________________________________________________________________

//! Still image capture handler.
@implementation StillImageCapture
{
  AVCaptureSession* Session;
}
@synthesize stillImageOutput;
//__________________________________________________________________________________________________

+ (StillImageCapture*) sharedCapture
{
  if (SharedStillImageCapture == nil)
  {
    SharedStillImageCapture = [[StillImageCapture alloc] initWithSession:[VideoCapture sharedCapture].captureSession];
  };
  return SharedStillImageCapture;
}
//__________________________________________________________________________________________________

- (void)cleanUp
{
  [Session removeOutput:stillImageOutput];
  stillImageOutput        = nil;
  SharedStillImageCapture = nil;
}
//__________________________________________________________________________________________________

- (instancetype) initWithSession:(AVCaptureSession*)captureSession
{
  self = [super init];
  if (self != nil)
  {
    Session = captureSession;
    [self initOutput];
//    [self performSelectorInBackground:@selector(initOutput) withObject:nil];
  }
  return self;
}
//__________________________________________________________________________________________________

- (void)initOutput
{
  NSLog(@"initOutput");
  stillImageOutput              = [[AVCaptureStillImageOutput alloc] init];
  NSDictionary* outputSettings  = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
  [stillImageOutput setOutputSettings:outputSettings];
  [Session          addOutput:stillImageOutput];
}
//__________________________________________________________________________________________________

- (void)takeSnapshot:(BlockIdAction)completion
{

    NSLog(@"selfie");

    //NSLog(@"takeSnapshot 0");

    Mixpanel *mixpanel = [Mixpanel sharedInstance];

    [mixpanel track:@"selfies"];

    [mixpanel identify:mixpanel.distinctId];

    [mixpanel.people increment:@"selfies" by:[NSNumber numberWithInt:1]];



  AVCaptureConnection* videoConnection = nil;
  for (AVCaptureConnection* connection in stillImageOutput.connections)
  {
    for (AVCaptureInputPort* port in [connection inputPorts])
    {
      if ([[port mediaType] isEqual:AVMediaTypeVideo])
      {
        videoConnection = connection;
        break;
      }
    }
    if (videoConnection)
    {
      break;
    }
  }
  NSLog(@"takeSnapshot videoConnection: %p", videoConnection);
  if (videoConnection != nil)
  {
    if (videoConnection.isVideoMirroringSupported)
    {
      videoConnection.videoMirrored = YES;
    }
    NSLog(@"takeSnapshot before captureStillImageAsynchronouslyFromConnection");
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                  completionHandler: ^(CMSampleBufferRef imageDataSampleBuffer, NSError *error)
    {
      NSLog(@"takeSnapshot completionHandler: error: %@", error);
      if (imageDataSampleBuffer != NULL)
      {
        NSData*  imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage* image     = [[UIImage alloc] initWithData:imageData];
        NSLog(@"takeSnapshot imageDataSampleBuffer: %p, imageData: %p, image: %p, size: %6.2f, %6.2f, num data bytes: %d", imageDataSampleBuffer, imageData, image, image.size.width, image.size.height, (int)imageData.length);
        completion(image);
      }
      else if (error)
      {
        NSLog(@"TakeSnapshot error: %@", error);
        completion(nil);
      }
    }];
  }
  else
  {
    NSLog(@"TakeSnapshot error: videoConnection == nil");
    completion(nil);
  }
//  NSLog(@"takeSnapshot 5");
}

//__________________________________________________________________________________________________

@end
//__________________________________________________________________________________________________
