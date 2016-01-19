
//! \file   VideoCapture.h
//! \brief  Capture of a video stream.
//__________________________________________________________________________________________________

#define USE_SETTINGS_
//__________________________________________________________________________________________________

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "Blocks.h"
//__________________________________________________________________________________________________

//! Capture of a video stream.
@interface VideoCapture : NSObject
{
}
//____________________

@property AVCaptureSession*           captureSession; //!< Video capture session.
@property AVCaptureVideoPreviewLayer* previewLayer;   //!< The preview layer for this video stream.
@property (readonly) BOOL             captureActive;  //!< Flag indication that the capture is active.
//____________________

+ (VideoCapture*) sharedCapture;  //!< Retrieve the VideoCapture singleton object.
//____________________

- (id)   init;                                            //!< Initialization method.
- (void) startCapture:(BlockAction)completion;            //!< Start video capture.
- (void) stopCapture:(BlockAction)completion;             //!< Stop video capture.
- (void) setupCaptureSession;                             //!< Create and configure a capture session and start it running.
- (void) cleanupCaptureSession:(BlockAction)completion;   //!< Stop the capture session and release all its resources.
+ (void) restoreCaptureSession:(BlockIdAction)completion; //!< restore the capture session and reallocate all its resources.
//____________________

@end
//__________________________________________________________________________________________________
