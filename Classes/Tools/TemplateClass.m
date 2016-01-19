//__________________________________________________________________________________________________
//
// Copyright © 2014 Bernie                                              
//__________________________________________________________________________________________________
//
// PROJECT  FallingTexts
//__________________________________________________________________________________________________
//
//! \file   TemplateClass.m
//! \brief  Template class to use to build any other class.
//!
//! \author Bernie
//__________________________________________________________________________________________________

#import "TemplateClass.h"
//__________________________________________________________________________________________________

//! Template class to use to build any other class.
@interface TemplateClass()
{
}
//____________________

@end
//__________________________________________________________________________________________________

//! \brief  Template class to use to build any other class.
@implementation TemplateClass
{
  BlockAction HideCompletion;
}
//____________________

//! Initialize the object however it has been created.
-(void)Initialize
{
  self.backgroundColor = Transparent;
}
//__________________________________________________________________________________________________

//! Initialize the object when it has been allocated programmatically.
- (instancetype)init
{
	self = [super init];
	if (self)
	{
    [self Initialize];
	}
	return self;
}
//__________________________________________________________________________________________________

//! Initialize the object when it has been allocated from an unarchiver.
- (instancetype)initWithCoder:(NSCoder *)decoder
{
	self = [super initWithCoder:decoder];
	if (self)
	{
    [self Initialize];
	}
	return self;
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

@end
