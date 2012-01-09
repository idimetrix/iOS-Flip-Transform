
/*
 
 File: GenericAnimationView.m
 Abstract: Generic Animation View is the base view to which all
 animation layers are added. It draws the animation layers based
 on supplied parameters and handles the layers as a stack of
 Animation Frames that can be rearranged in the overall application
 view hierarchy. Animation layers can be drawn with an image (from
 file or dynamically generated such as a screenshot) or using a
 background color.
 
 
 Copyright (c) 2011 Dillion Tan
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "GenericAnimationView.h"

@implementation GenericAnimationView

@synthesize imageStackArray;
@synthesize animationDelegate;
@synthesize textInset;
@synthesize textOffset;
@synthesize fontSize;
@synthesize font;
@synthesize fontAlignment;
@synthesize textTruncationMode;
@synthesize animationType;

- (id)initWithAnimationType:(AnimationType)aType
          animationDelegate:(AnimationDelegate *)aDelegate
                     frame:(CGRect)aFrame
{
    self = [super init];
    if (self) {
        // Initialization code
        
        animationType = aType;
        
        textOffset = CGPointZero;
        textInset = CGPointZero;
        
        self.imageStackArray = [NSMutableArray array];
        
        animationDelegate = aDelegate;
        
        templateWidth = aFrame.size.width;
        templateHeight = aFrame.size.height;
        self.frame = aFrame;
        
    }
    return self;
}

- (void)dealloc
{
    [imageStackArray removeAllObjects];
    [imageStackArray release];
    
    [super dealloc];
}

- (BOOL)printText:(NSString *)tickerString 
       usingImage:(UIImage *)aImage
  backgroundColor:(UIColor *)aBackgroundColor
        textColor:(UIColor *)aTextColor {
    
    // renderInContext requires a new layer
    CALayer *backingLayer = [CALayer layer];
    
    if (aImage) {
        [backingLayer setContents:(id)aImage.CGImage];
    }
    
    if (aBackgroundColor) {
        backingLayer.backgroundColor = aBackgroundColor.CGColor;
    }
    
    backingLayer.frame = CGRectMake(0, 0, templateWidth, templateHeight);
    
    // Composite text onto image layer by rendering a text layer in a new graphics context
    // For dynamic resizing need to compute the bounds based on font ascender and descender, and set the autoresizing mask
    CATextLayer *label = nil;
    
    if (tickerString) {
        label = [[CATextLayer alloc] init];
        label.string = tickerString;
        label.font = font;
        label.fontSize = fontSize;
        label.alignmentMode = fontAlignment;
        label.truncationMode = textTruncationMode;
        
        if (aTextColor) {
            label.foregroundColor = aTextColor.CGColor;
        }
        
        CGRect boundsAfterInset = CGRectInset(backingLayer.bounds, textInset.x, textInset.y);
        label.bounds = boundsAfterInset;
        label.position = CGPointMake(backingLayer.position.x + textOffset.x, backingLayer.position.y + textOffset.y);
        
        [backingLayer addSublayer:label];
    }
    
    UIGraphicsBeginImageContext(backingLayer.frame.size);
    
    [backingLayer renderInContext:UIGraphicsGetCurrentContext()];
    templateImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    if (label) {
        [label removeFromSuperlayer];
        [label release];
    }

    if (templateImage) {
        return YES;
    }
    
    return NO;
}

// Pop the last set of images and push back onto the stack, to prepare for the next animation sequence
- (void)rearrangeLayers:(DirectionType)aDirectionType :(int)step {
    // for subclass to implement
}

@end