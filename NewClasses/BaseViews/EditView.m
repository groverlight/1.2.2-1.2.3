
//! \file   EditView.m
//! \brief  BaseView based class that implements a text editor with custom features.
//__________________________________________________________________________________________________

#import "EditView.h"
#import "Colors.h"
#import "GlobalParameters.h"
#import "Tools.h"
//__________________________________________________________________________________________________

#define kPopEditViewFontSizeAnimation @"PopEditViewFontSizeAnimation"  //!< Font size animation id.
#define SEPARATOR_STRING              @"\n\t\n"
#define PARTIAL_SEPARATOR_STRING      @"\n\t"
#define EMPTY_TEXT_HEIGHT_PADDING     0
#define EDITOR_LATERAL_MARGIN         5
#define LATERAL_MARGIN                1
//__________________________________________________________________________________________________

//! BaseView based class that implements a text editor with custom features.
@interface EditView() <UITextViewDelegate>
@end
//__________________________________________________________________________________________________

//! BaseView based class that implements a text editor with custom features.
@implementation EditView
{
  UIScrollView*   ScrollView;
  UILabel*        CompleteChunksLabel;
  UITextView*     Editor;
  UIColor*        SavedDefaultCursorColor;
  NSMutableArray* CompleteChunksArray;

  CGFloat         LargeFontSize;
  CGFloat         SmallFontSize;
  UIFont*       	CurrentFont;
  UIColor*      	TextColor;
  UIColor*      	CompleteChunkTextColor;
  UIColor*      	CompleteChunkBackgroundColor;
  NSInteger     	NumUnvalidatedChars;
  NSInteger       TotalNumCharacters;
  BOOL          	UseSmallFont;
  BOOL            Active;
  BOOL            ChangingText;
}
//@synthesize disableTextEdition;
//____________________

//! Initialize the object however it has been created.
- (void)Initialize
{
  [super Initialize];
  CompleteChunksLabel = [UILabel      new];
  Editor              = [UITextView   new];
  ScrollView          = [UIScrollView new];
  [self       addSubview:ScrollView];
  [ScrollView addSubview:CompleteChunksLabel];
  [ScrollView addSubview:Editor];
  self.clipsToBounds                  = YES;
  GlobalParameters* parameters        = GetGlobalParameters();
  NumUnvalidatedChars                 = 0;
  Editor.delegate                     = self;
  Editor.backgroundColor              = parameters.typingBackgroundColor;
  CompleteChunksLabel.backgroundColor = parameters.typingValidatedBackgroundColor;
  CompleteChunksArray                 = [NSMutableArray arrayWithCapacity:5];
  CurrentFont                         = [parameters.typingFont fontWithSize:parameters.typingLargeFontSize];
  Editor.font                         = CurrentFont;
  Editor.bounces                      = NO;
  TextColor                           = parameters.typingTextColor;
  CompleteChunkTextColor              = parameters.typingValidatedTextColor;
  CompleteChunkBackgroundColor        = parameters.typingValidatedTextBackgroundColor;
  CompleteChunksLabel.numberOfLines   = 0;
  CompleteChunksLabel.lineBreakMode   = NSLineBreakByWordWrapping;


  //Editor.keyboardAppearance = UIKeyboardAppearanceDark;

  self.disableTextEdition = NO;
  UseSmallFont            = NO;
  ChangingText            = NO;

  DidBeginEditingAction = ^
  { // Default action: do nothing!
  };
  TextDidChangeAction = ^
  { // Default action: do nothing!
  };
  SelectionDidChangeAction = ^
  { // Default action: do nothing!
  };
  DidEndEditingAction = ^
  { // Default action: do nothing!
  };
  ShouldBeginEditingAction = ^BOOL()
  {
    return YES;
  };
  DidDeleteLastChunk = ^
  { // Default action: do nothing!
  };
  DidPressGoButton = ^
  { // Default action: do nothing!
  };
  [self clearText];
}
//__________________________________________________________________________________________________

- (void)dealloc
{
  [self cleanup];
}
//__________________________________________________________________________________________________

- (void)cleanup
{
}
//__________________________________________________________________________________________________

- (void)willMoveToWindow:(UIWindow *)newWindow
{
  SavedDefaultCursorColor = GetGlobalParameters().typingCursorColor;
  [[UITextView appearance] setTintColor:SavedDefaultCursorColor];
}
//__________________________________________________________________________________________________

- (void)didMoveToWindow
{
  [[UITextView appearance] setTintColor:SavedDefaultCursorColor];
}
//__________________________________________________________________________________________________

- (void)layout
{
  if (self.bounds.size.height > 0)
  {
    [self formatChunksAndAlignToBottom];
    ScrollView.frame          = self.bounds;
    CompleteChunksLabel.width = self.width - 2 * LATERAL_MARGIN;
    CompleteChunksLabel.left  = LATERAL_MARGIN;
    Editor.width              = self.width - 2 * (LATERAL_MARGIN - EDITOR_LATERAL_MARGIN);
    Editor.left               = LATERAL_MARGIN - EDITOR_LATERAL_MARGIN;
  }
}
//__________________________________________________________________________________________________

- (void)layoutSubviews
{
  if (NumAnimationInProgress == 0)
  {
    [super  layoutSubviews];
    [self   layout];
  }
}
//__________________________________________________________________________________________________

- (CGSize)sizeThatFits:(CGSize)size
{
  return size;
}
//__________________________________________________________________________________________________

- (void)setLargeFontSize:(CGFloat)largeFontSize
{
  LargeFontSize = largeFontSize;
  [self formatChunksAndAlignToBottom];
}
//__________________________________________________________________________________________________

- (CGFloat)largeFontSize
{
  return LargeFontSize;
}
//__________________________________________________________________________________________________

- (void)setSmallFontSize:(CGFloat)smallFontSize
{
  SmallFontSize = smallFontSize;
  [self formatChunksAndAlignToBottom];
}
//__________________________________________________________________________________________________

- (CGFloat)smallFontSize
{
  return SmallFontSize;
}
//__________________________________________________________________________________________________

- (void)setUseSmallFont:(BOOL)useSmallFont
{
  if (useSmallFont != UseSmallFont)
  {
    UseSmallFont = useSmallFont;
    CGFloat currentFontSize = useSmallFont? SmallFontSize: LargeFontSize;
    [self basicAnimateFontsToSize:currentFontSize during:0.5];
  }
}
//__________________________________________________________________________________________________

- (BOOL)useSmallFont
{
  return UseSmallFont;
}
//__________________________________________________________________________________________________

- (void)setChunkIsComplete
{
  [CompleteChunksArray addObject:Editor.text];
  Editor.text = @" ";
  [self formatChunksAndAlignToBottom];
  self.disableTextEdition  = NO;
  NumUnvalidatedChars = 0;
}
//__________________________________________________________________________________________________

- (NSInteger)numUnvalidatedChars
{
  return NumUnvalidatedChars;
}
//__________________________________________________________________________________________________

- (NSInteger)totalNumCharacters
{
  return TotalNumCharacters + NumUnvalidatedChars;
}
//__________________________________________________________________________________________________

- (NSArray*)textRecords
{
  return CompleteChunksArray;
}
//__________________________________________________________________________________________________

//! Set the return key to GO.
- (void)showGoKey:(BOOL)show
{
  UIReturnKeyType returnType = show? UIReturnKeyGo: UIReturnKeyDefault;
  if (returnType != Editor.returnKeyType)
  {
    Editor.returnKeyType = returnType;
    if (Editor.isFirstResponder)
    {
      [Editor resignFirstResponder];
      [Editor becomeFirstResponder];
    }
  }
}
//__________________________________________________________________________________________________

//! Clear the editing string.
- (void)clearText
{
  GlobalParameters* parameters = GetGlobalParameters();
  [CompleteChunksArray removeAllObjects];
  [self formatChunksAndAlignToBottom];
  CurrentFont = [parameters.typingFont fontWithSize:parameters.typingLargeFontSize];
  Editor.font = CurrentFont;
}
//__________________________________________________________________________________________________

- (void)formatChunksAndAlignToBottom
{
  if (Active)
  {
    TotalNumCharacters = 0;
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:@""];
    for (int i = 0; i < CompleteChunksArray.count; ++i)
    {
      NSString* messageString = [CompleteChunksArray objectAtIndex:i];
      if (GetGlobalParameters().typingForceCapitalizingFirstChar)
      {
        messageString = [messageString stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[messageString substringToIndex:1] uppercaseString]];
      }
      NSDictionary* attributesDict = @{NSKernAttributeName            : @0.0,
                                       NSBaselineOffsetAttributeName  : @0.1,
                                       NSFontAttributeName            : CurrentFont,
                                       NSForegroundColorAttributeName : CompleteChunkTextColor,
                                       NSBackgroundColorAttributeName : (CompleteChunkBackgroundColor),
                                       NSStrokeWidthAttributeName     : @-0.001};
      [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:messageString attributes:attributesDict]];
      UIFont* separatorFont = [UIFont systemFontOfSize:MAX(GetGlobalParameters().typingTextBlockGap, 0.01)];
      NSDictionary* attributesDictNl  = @{NSKernAttributeName            : @0.0,
                                          NSBaselineOffsetAttributeName  : @0.1,
                                          NSFontAttributeName            : separatorFont,
                                          NSForegroundColorAttributeName : Transparent,
                                          NSBackgroundColorAttributeName : Transparent,
                                          NSStrokeWidthAttributeName     : @-0.001};
      [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:SEPARATOR_STRING attributes:attributesDictNl]];
      TotalNumCharacters += messageString.length;
    }
    CompleteChunksLabel.attributedText = attrString;
    CGSize size = CGSizeMake(self.size.width, 10000000000);
    CompleteChunksLabel.height  = [CompleteChunksLabel sizeThatFits:size].height;
    [self alignToBottom];
  }
}
//__________________________________________________________________________________________________

- (void)alignToBottom
{
  NSAttributedString* attrString  = [[NSAttributedString alloc] initWithString:Editor.text attributes:@{NSFontAttributeName: CurrentFont, NSForegroundColorAttributeName : TextColor}];
  if ([attrString.string isEqualToString:@""])
  {
    attrString = [[NSAttributedString alloc] initWithString:@"W" attributes:@{NSFontAttributeName: CurrentFont}];
  }
  else
  {
    Editor.attributedText = attrString;
  }
  if ([attrString.string isEqualToString:SEPARATOR_STRING])
  {
  }
  CGFloat editorMaxHeight     = 424; // Some arbitrary big value.
  CGSize size                 = CGSizeMake(Editor.width - 2 * Editor.textContainer.lineFragmentPadding, editorMaxHeight);
//  NSLog(@"EditorWidth: %f, %f", Editor.width, Editor.textContainer.size.width);
  Editor.height               = editorMaxHeight;
  CGFloat calculatedSize      = CalculateAttributedTextSize(attrString, size).height;
//  NSLog(@"calculatedSize: %f, %f", calculatedSize, ceil(calculatedSize));
  CGFloat editorHeight        = calculatedSize + 8;
  CGFloat contentHeight       = MAX(ScrollView.height, CompleteChunksLabel.height - 14 + editorHeight);
  CGFloat contentOffsetY      = contentHeight - ScrollView.height;
  Editor.top                  = contentHeight - editorHeight;
  CompleteChunksLabel.bottom  = Editor.top + 14;
  ScrollView.contentSize      = CGSizeMake(ScrollView.width, contentHeight);
  ScrollView.contentOffset    = CGPointMake(0, contentOffsetY);
//  NSLog(@"height: %6.2f, Editor.height: %6.2f, chunks height: %6.2f, Editor.top: %6.2f, Editor.bottom: %6.2f, contentHeight: %6.2f, contentOffsetY: %6.2f", ScrollView.height, Editor.height, CompleteChunksLabel.height, Editor.top, Editor.bottom, contentHeight, contentOffsetY);
}
//__________________________________________________________________________________________________

- (BOOL)textView:(UITextView*)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text
{
  if (!ChangingText)
  {
    //    NSLog(@"shouldChangeTextInRange returnKeyType: %d", (int)Editor.returnKeyType);
    BOOL returnKeyPressed = (range.length == 0) && ([text isEqualToString:@"\n"]);
    BOOL goKeyShown       = (Editor.returnKeyType == UIReturnKeyGo);
    if (returnKeyPressed && goKeyShown)
    {
      DidPressGoButton();
      return NO;
    }
    else if (returnKeyPressed && self.ignoreReturnKey)
    {
      return NO;
    }
    else
    {
      BOOL deleting = ((range.length <= 1) && (text.length == 0));
      if (deleting && NumUnvalidatedChars == 0)
      {
        NSString* string = [CompleteChunksArray lastObject];
        if (string != nil)
        {
          [CompleteChunksArray removeLastObject];
          Editor.attributedText = [[NSAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName: CurrentFont, NSForegroundColorAttributeName : TextColor}];
          [self formatChunksAndAlignToBottom];
          DidDeleteLastChunk();
          NumUnvalidatedChars = Editor.text.length;
          TextDidChangeAction();
        }
        return NO;
      }
      NSInteger numCharactersLeft = GetGlobalParameters().typingMaxCharacterCount - NumUnvalidatedChars;
      if (!deleting && (numCharactersLeft < text.length))
      {
        return NO;
      }
      else
      {
        return !self.disableTextEdition || deleting;
      }
    }
  }
  return NO;
}
//__________________________________________________________________________________________________

- (void)textViewDidChange:(UITextView*)textView
{
  NumUnvalidatedChars = Editor.text.length;
  [self alignToBottom];
  ChangingText = YES;
  TextDidChangeAction();
  ChangingText = NO;
}
//__________________________________________________________________________________________________

- (void)textViewDidBeginEditing:(UITextView*)textView
{
  DidBeginEditingAction();
}
//__________________________________________________________________________________________________

- (void)textViewDidChangeSelection:(UITextView*)textView
{
  SelectionDidChangeAction();
}
//__________________________________________________________________________________________________

- (void)textViewDidEndEditing:(UITextView*)textView
{
  DidEndEditingAction();
}
//__________________________________________________________________________________________________

- (BOOL)textViewShouldBeginEditing:(UITextView*)textView
{
  return ShouldBeginEditingAction();
}
//__________________________________________________________________________________________________

- (void)basicAnimateFontsToSize:(CGFloat)fontSize during:(CGFloat)seconds
{
  UseFontAnimation            = YES;
  POPPropertyAnimation* anim  = [self CreateAnimationWithStyle:E_PopAnimationStyle_Basic];
  anim.property               = [self prepareFontAnimationProperty];
  anim.toValue                = [NSNumber numberWithDouble:fontSize];
  anim.name                   = kPopEditViewFontSizeAnimation;
  anim.delegate               = self;
  ((POPBasicAnimation*)anim).duration = seconds;
  [Editor pop_addAnimation:anim forKey:kPopEditViewFontSizeAnimation];
}
//__________________________________________________________________________________________________

- (void)springAnimateFontsToSize:(CGFloat)fontSize springAnimateWithBounciness:(CGFloat)bounciness andVelocity:(CGFloat)velocity
{
  UseFontAnimation            = YES;
  POPPropertyAnimation* anim  = [self CreateAnimationWithStyle:E_PopAnimationStyle_Spring];
  anim.property               = [self prepareFontAnimationProperty];
  anim.toValue                = [NSNumber numberWithDouble:fontSize];
  anim.name                   = kPopEditViewFontSizeAnimation;
  anim.delegate               = self;
  ((POPSpringAnimation*)anim).springBounciness  = bounciness;
  ((POPSpringAnimation*)anim).velocity          = [NSNumber numberWithFloat:velocity];
  [Editor pop_addAnimation:anim forKey:kPopEditViewFontSizeAnimation];
}
//__________________________________________________________________________________________________

- (void)decayAnimateFontsToSize:(CGFloat)fontSize decayAnimateWithDeceleration:(CGFloat)deceleration andVelocity:(CGFloat)velocity
{
  UseFontAnimation            = YES;
  POPPropertyAnimation* anim  = [self CreateAnimationWithStyle:E_PopAnimationStyle_Decay];
  anim.property               = [self prepareFontAnimationProperty];
  anim.toValue                = [NSNumber numberWithDouble:fontSize];
  anim.name                   = kPopEditViewFontSizeAnimation;
  anim.delegate               = self;
  ((POPDecayAnimation*)anim).deceleration = deceleration;
  ((POPDecayAnimation*)anim).velocity     = [NSNumber numberWithFloat:velocity];
  [Editor pop_addAnimation:anim forKey:kPopEditViewFontSizeAnimation];
}
//__________________________________________________________________________________________________

- (POPAnimatableProperty*)prepareFontAnimationProperty
{
  POPAnimatableProperty* fontProp = [POPAnimatableProperty propertyWithName:@"editViewFontAnimProp" initializer:^(POPMutableAnimatableProperty* prop)
  {
    // Read value
    prop.readBlock = ^(UITextView* editor, CGFloat values[])
    {
      values[0] = CurrentFont.pointSize;
    };
    // Write value
    prop.writeBlock = ^(UITextView* editor, const CGFloat values[])
    {
      CGFloat newFontSize = ceil(values[0]);
      if (fabs(newFontSize - CurrentFont.pointSize) > 1.0)
      {
        CurrentFont = [CurrentFont fontWithSize:ceil(newFontSize)];
        [self formatChunksAndAlignToBottom];
      }
    };
    // dynamics threshold
    prop.threshold = 0.01;
  }];

  return fontProp;
}
//__________________________________________________________________________________________________

- (BOOL)becomeFirstResponder
{
  return [Editor becomeFirstResponder];
}
//__________________________________________________________________________________________________

- (BOOL)resignFirstResponder
{
  return [Editor resignFirstResponder];
}
//__________________________________________________________________________________________________

- (void)activate
{
  Active = YES;
  [self becomeFirstResponder];
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
  {
    [self alignToBottom];
  });
}
//__________________________________________________________________________________________________

@end
