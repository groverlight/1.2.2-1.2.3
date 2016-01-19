
//! \file   CameraPreview.h
//! \brief  Implement a live camera preview view.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>
#import "Blocks.h"
#import "BaseView.h"
#import "VideoCapture.h"
//__________________________________________________________________________________________________

//! Live camera preview view.
@interface CameraPreview : BaseView
{
@public
  VideoCapture* Capture;      //!< Cached copy of the capture object.
  BOOL          UseViewFrame; //!< When YES, improved preview layer frame calculation (may become standard in the future).
}
//____________________

- (void)startPreviewWithCompletion:(BlockAction)completion;   //!< Start video preview on this view with completion block.
- (void)stopPreviewWithCompletion:(BlockAction)completion;    //!< Stop video preview on this view with completion block.
- (void)replacePreviewWithCompletion:(BlockAction)completion; //!< Change video preview to this view with completion block.
- (void)cleanupPreviewWithCompletion:(BlockAction)completion; //!< Stop preview and release all resources with completion block.
- (void)restorePreviewWithCompletion:(BlockAction)completion; //!< Restore preview and all resources with completion block.
//____________________

//! Recalculate the preview layer frame when device orientation changed.
- (void)updateCaptureOrientation;
//____________________

@end
//__________________________________________________________________________________________________
