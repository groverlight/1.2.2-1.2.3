
//! \file   StillImageCapture.h
//! \brief  Still image capture.
//__________________________________________________________________________________________________

#define USE_SETTINGS_
//__________________________________________________________________________________________________

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
//__________________________________________________________________________________________________

//! Still image capture handler.
@interface StillImageCapture : NSObject
{
}

@property AVCaptureStillImageOutput*  stillImageOutput;               //!< AVCapture output object for the still image handler.

+ (StillImageCapture*) sharedCapture;                                 //!< Retrieve the StillImageCapture singleton object.
//____________________

- (void)cleanUp;                                              //!< Release the StillImageCapture singleton object.
//____________________

- (instancetype)  initWithSession:(AVCaptureSession*)captureSession;  //!< Initialization method.
- (void)          takeSnapshot:(BlockIdAction)completion;             //!< Take a still image and return it in the completion block.
//____________________

@end
//__________________________________________________________________________________________________

