
//! \file   CameraPreview.m
//! \brief  Implement a live camera preview view.
//__________________________________________________________________________________________________

#import <Foundation/NSDateFormatter.h>
#import <QuartzCore/CALayer.h>
#import "Colors.h"
#import "CameraPreview.h"
#import "StillImageCapture.h"
#import "Tools.h"
//__________________________________________________________________________________________________

//! Live camera preview view.
@interface CameraPreview()
{
  CGRect PreviewFrame; //!< The frame to apply to the preview layer when adding it to the view.
}
@end
//__________________________________________________________________________________________________

//! Live camera preview view.
@implementation CameraPreview
{
  BOOL AlreadyActive;
}
//__________________________________________________________________________________________________

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
    AlreadyActive         = NO;
    UseViewFrame          = NO;
    self.clipsToBounds    = YES;
//    self.backgroundColor  = Green;
    Capture               = [VideoCapture sharedCapture];
	}
	return self;
}
//__________________________________________________________________________________________________

- (id)initWithCoder:(NSCoder*)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self)
	{
    UseViewFrame          = NO;
    self.clipsToBounds    = YES;
//    self.backgroundColor  = Green;
    Capture               = [VideoCapture sharedCapture];
 	}
	return self;
}
//__________________________________________________________________________________________________

- (void)dealloc
{
}
//__________________________________________________________________________________________________

- (void)layout
{
  CGRect frame    = self.bounds;
  CGFloat width   = frame.size.width;
  CGFloat height  = frame.size.height;
  CGFloat liveWidth;
  CGFloat liveHeight;
  if (UseViewFrame)
  {
    CGFloat viewRatio = max(1, height) / max(1, width);
    CGFloat liveRatio;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
    {
      liveRatio = 3.0 / 4.0;
    }
    else
    {
      liveRatio = 4.0 / 3.0;
    }
    if (viewRatio < liveRatio)
    {
      liveHeight = height;
      liveWidth  = liveHeight * liveRatio;
      if (liveWidth < width)
      {
        liveWidth  = width;
        liveHeight = liveWidth / liveRatio;
      }
//      NSLog(@"ratio: %6.2f < liveRatio: %6.3f, width: %8.3f, height: %8.3f, liveWidth: %8.3f, liveHeight: %8.3f", viewRatio, liveRatio, width, height, liveWidth, liveHeight);
    }
    else
    {
      liveWidth  = width;
      liveHeight = liveWidth / liveRatio;
      if (liveHeight < height)
      {
        liveHeight = height;
        liveWidth  = liveHeight * liveRatio;
      }
//      NSLog(@"ratio: %6.2f > liveRatio: %6.3f, width: %8.3f, height: %8.3f, liveWidth: %8.3f, liveHeight: %8.3f", viewRatio, liveRatio, width, height, liveWidth, liveHeight);
    }
  }
  else
  {
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
    {
      liveWidth  = height * 4 / 3;
      liveHeight = height;
    }
    else
    {
      liveWidth  = width;
      liveHeight = width * 3 / 4;
    }
  }

  PreviewFrame = CGRectMake((width - liveWidth) / 2, (height - liveHeight) / 2, liveWidth, liveHeight);
  if (Capture.previewLayer.superlayer == self.layer)
  {
    // Disable implicit layer animations when updating layer frame.
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    Capture.previewLayer.frame = PreviewFrame;
    [CATransaction commit];
  }
}
//__________________________________________________________________________________________________

//! Recalculate the preview layer frame when device orientation changed.
- (void)updateCaptureOrientation
{
  AVCaptureConnection* previewLayerConnection = Capture.previewLayer.connection;
  if ([previewLayerConnection isVideoOrientationSupported])
  {
    [previewLayerConnection setVideoOrientation:(AVCaptureVideoOrientation)[[UIApplication sharedApplication] statusBarOrientation]];
  }
  [self layout];
}
//__________________________________________________________________________________________________

- (void)startWithCompletion:(BlockAction)completion
{
//  NSLog(@"1 startWithCompletion");
  if (Capture == nil)
  {
    Capture = [VideoCapture sharedCapture];
  }
  Capture.previewLayer.frame = PreviewFrame;
//  NSLog(@"2 startWithCompletion");
  [self updateCaptureOrientation];
//  NSLog(@"3 startWithCompletion");
  [Capture startCapture:completion];
//  NSLog(@"4 startWithCompletion");
}
//__________________________________________________________________________________________________

//! Start video preview on this view with completion block.
- (void)startPreviewWithCompletion:(BlockAction)completion
{
  if ((Capture != nil) && !AlreadyActive)
  {
    AlreadyActive = YES;
    [self.layer addSublayer:Capture.previewLayer];
//    NSLog(@"StartPreviewWithCompletion");
    [self startWithCompletion:completion];
  }
}
//__________________________________________________________________________________________________

//! Stop video preview on this view with completion block.
- (void)stopPreviewWithCompletion:(BlockAction)completion
{
  if (Capture != nil)
  {
    [Capture.previewLayer removeFromSuperlayer];
    [Capture stopCapture:completion];
    AlreadyActive = NO;
//    NSLog(@"StopPreviewWithCompletion");
  }
}
//__________________________________________________________________________________________________

//! Change video preview to this view with completion block.
- (void)replacePreviewWithCompletion:(BlockAction)completion
{
  if (Capture != nil)
  {
    [self.layer addSublayer:Capture.previewLayer];
//    NSLog(@"ReplacePreviewWithCompletion");
    if (!Capture.captureActive)
    {
      [self startWithCompletion:completion];
    }
    else
    {
      completion();
    }
  }
}
//__________________________________________________________________________________________________

//! Stop preview and release all resources with completion block.
- (void)cleanupPreviewWithCompletion:(BlockAction)completion
{
  if (Capture != nil)
  {
    [Capture.previewLayer removeFromSuperlayer];
    [Capture cleanupCaptureSession:completion];
    [[StillImageCapture sharedCapture] cleanUp];
    Capture = nil;
  }
}
//__________________________________________________________________________________________________

//! Restore preview and all resources with completion block.
- (void)restorePreviewWithCompletion:(BlockAction)completion
{
//  NSLog(@"restorePreviewWithCompletion");
  [VideoCapture restoreCaptureSession:^(id obj)
  {
    Capture = (VideoCapture*)obj;
    [self startPreviewWithCompletion:completion];
  }];
}
//__________________________________________________________________________________________________

@end
