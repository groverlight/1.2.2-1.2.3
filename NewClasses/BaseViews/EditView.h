
//! \file   EditView.h
//! \brief  BaseView based class that implements a text editor with custom features.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>
#import "PopBaseView.h"
#import "Blocks.h"
//__________________________________________________________________________________________________

//! BaseView based class that implements a text editor with custom features.
@interface EditView : PopBaseView
{
@public
  BlockAction     DidBeginEditingAction;
  BlockAction     TextDidChangeAction;
  BlockAction     SelectionDidChangeAction;
  BlockAction     DidEndEditingAction;
  BoolBlockAction ShouldBeginEditingAction;
  BlockAction     DidDeleteLastChunk;
  BlockAction     DidPressGoButton;
}
//____________________

@property             CGFloat   largeFontSize;
@property             CGFloat   smallFontSize;
@property             BOOL      disableTextEdition;   //!< If yes, only let deleting characters.
@property             BOOL      ignoreReturnKey;      //!< If yes, ignore return key presses.
@property             BOOL      useSmallFont;
@property (readonly)  NSInteger numUnvalidatedChars;  //!< Number of characters in the last chunk, the one that is currently editing.
@property (readonly)  NSInteger totalNumCharacters;   //!< Sum of the characters in all the chunks.
@property (readonly)  NSArray*  textRecords;          //!< Array of the edited texts;
//____________________

//! Set the return key to GO.
- (void)showGoKey:(BOOL)show;
//____________________

//! Clear the editing string.
- (void)clearText;
//____________________

//! When YES, adding a char will trigger the creation of a new chunk.
- (void)setChunkIsComplete;
//____________________

@end
//__________________________________________________________________________________________________


