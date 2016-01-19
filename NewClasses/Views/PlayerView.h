
//! \file   PlayerView.h
//! \brief  BaseView based class that plays the messages.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>
#import "BaseView.h"
#import "Blocks.h"
#import "Message.h"
//__________________________________________________________________________________________________

//! \brief  BaseView based class that plays the messages.
@interface PlayerView : BaseView
{
@public
}
//____________________

@property UIImage*  image;
@property NSString* text;
//____________________

- (void)prepareForFirstChunkWithMessage:(Message*)message;
//____________________

- (void)displayFirstChunk:(BlockBoolAction)completion;
//____________________

- (void)displayNextChunk:(BlockBoolAction)completion;
//____________________

- (void)stopPlayer;
//____________________


- (void)showAnimatedFromPoint:(CGPoint)point andInitialRadius:(CGFloat)radius completion:(BlockAction)completion;
//____________________

- (void)hideAnimatedToPoint:(CGPoint)point andInitialRadius:(CGFloat)radius completion:(BlockAction)completion;
//____________________

@end
//__________________________________________________________________________________________________
