//
//  Copyright 2012 Lolay, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "LolayPageControl.h"

#define kDotDiameter	4.0f
#define kDotSpace		12.0f

@implementation LolayPageControl

@synthesize numberOfPages;
@synthesize currentPage;
@synthesize hidesForSinglePage;
@synthesize defersCurrentPageDisplay;

@synthesize type;
@synthesize onColor;
@synthesize offColor;
@synthesize indicatorDiameter;
@synthesize indicatorSpace;

#pragma mark -
#pragma mark Initializers - dealloc

- (id)initWithType:(LolayPageControlType)theType {
	self = [self initWithFrame: CGRectZero];
	[self setType: theType];
	return self;
}

- (id)init {
	self = [self initWithFrame: CGRectZero];
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame: CGRectZero]))
	{
		self.backgroundColor = [UIColor clearColor];
	}
	return self;
}

#pragma mark -
#pragma mark drawRect

- (void)drawRect:(CGRect)rect {
	// get the current context
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	// save the context
	CGContextSaveGState(context);
    
	// allow antialiasing
	CGContextSetAllowsAntialiasing(context, TRUE);
    
	// get the caller's diameter if it has been set or use the default one 
	CGFloat diameter = (indicatorDiameter > 0) ? indicatorDiameter : kDotDiameter;
	CGFloat space = (indicatorSpace > 0) ? indicatorSpace : kDotSpace;
    
	// geometry
	CGRect currentBounds = self.bounds;
	CGFloat dotsWidth = self.numberOfPages * diameter + MAX(0, self.numberOfPages - 1) * space;
	CGFloat x = CGRectGetMidX(currentBounds) - dotsWidth / 2;
	CGFloat y = CGRectGetMidY(currentBounds) - diameter / 2;
    
	// get the caller's colors it they have been set or use the defaults
	CGColorRef onColorCG = onColor ? onColor.CGColor : [UIColor colorWithWhite: 1.0f alpha: 1.0f].CGColor;
	CGColorRef offColorCG = offColor ? offColor.CGColor : [UIColor colorWithWhite: 0.7f alpha: 0.5f].CGColor;
    
	// actually draw the dots
	for (int i = 0; i < numberOfPages; i++) {
		CGRect dotRect = CGRectMake(x, y, diameter, diameter);
        
		if (i == currentPage) 		{
			if (type == LolayPageControlTypeOnFullOffFull || type == LolayPageControlTypeOnFullOffEmpty) {
				CGContextSetFillColorWithColor(context, onColorCG);
				CGContextFillEllipseInRect(context, CGRectInset(dotRect, -0.5f, -0.5f));
			} else {
				CGContextSetStrokeColorWithColor(context, onColorCG);
				CGContextStrokeEllipseInRect(context, dotRect);
			}
		} else {
			if (type == LolayPageControlTypeOnEmptyOffEmpty || type == LolayPageControlTypeOnFullOffEmpty) {
				CGContextSetStrokeColorWithColor(context, offColorCG);
				CGContextStrokeEllipseInRect(context, dotRect);
			} else {
				CGContextSetFillColorWithColor(context, offColorCG);
				CGContextFillEllipseInRect(context, CGRectInset(dotRect, -0.5f, -0.5f));
			}
		}
        
		x += diameter + space;
	}
    
	// restore the context
	CGContextRestoreGState(context);
}


#pragma mark -
#pragma mark Accessors

- (void)setCurrentPage:(NSInteger)pageNumber {
	// no need to update in that case
	if (currentPage == pageNumber) {
		return;
    }
    
	// determine if the page number is in the available range
	currentPage = MIN(MAX(0, pageNumber), numberOfPages - 1);
    
	// in case we do not defer the page update, we redraw the view
	if (self.defersCurrentPageDisplay == NO) {
		[self setNeedsDisplay];
    }
}

- (void)setNumberOfPages:(NSInteger)numOfPages {
	// make sure the number of pages is positive
	numberOfPages = MAX(0, numOfPages);
    
	// we then need to update the current page
	currentPage = MIN(MAX(0, currentPage), numberOfPages - 1);
    
	// correct the bounds accordingly
	self.bounds = self.bounds;
    
	// we need to redraw
	[self setNeedsDisplay];
    [self invalidateIntrinsicContentSize];
    
	// depending on the user preferences, we hide the page control with a single element
	if (hidesForSinglePage && (numOfPages < 2)) {
		[self setHidden: YES];
    } else {
		[self setHidden: NO];
    }
}

- (void)setHidesForSinglePage:(BOOL)hide {
	hidesForSinglePage = hide;
    
	// depending on the user preferences, we hide the page control with a single element
	if (hidesForSinglePage && (numberOfPages < 2)) {
		[self setHidden: YES];
    }
}

- (void)setDefersCurrentPageDisplay:(BOOL)defers {
	defersCurrentPageDisplay = defers;
}

- (void)setType:(LolayPageControlType)aType {
	type = aType;    
	[self setNeedsDisplay];
}

- (void)setOnColor:(UIColor *)aColor {
	onColor = aColor;    
	[self setNeedsDisplay];
}

- (void)setOffColor:(UIColor *)aColor {	
	offColor = aColor;    
	[self setNeedsDisplay];
}

- (void)setIndicatorDiameter:(CGFloat)aDiameter {
	indicatorDiameter = aDiameter;    
	// correct the bounds accordingly
	self.bounds = self.bounds;    
	[self setNeedsDisplay];
    [self invalidateIntrinsicContentSize];
}

- (void)setIndicatorSpace:(CGFloat)aSpace {
	indicatorSpace = aSpace;    
	// correct the bounds accordingly
	self.bounds = self.bounds;    
	[self setNeedsDisplay];
    [self invalidateIntrinsicContentSize];
}

- (void)setFrame:(CGRect)aFrame {
	// we do not allow the caller to modify the size struct in the frame so we compute it
	aFrame.size = [self sizeForNumberOfPages: numberOfPages];
	super.frame = aFrame;
}

- (void)setBounds:(CGRect)aBounds {
	// we do not allow the caller to modify the size struct in the bounds so we compute it
	aBounds.size = [self sizeForNumberOfPages: numberOfPages];
	super.bounds = aBounds;
}

- (CGSize) intrinsicContentSize {
    return [self sizeForNumberOfPages:numberOfPages];
}

#pragma mark -
#pragma mark UIPageControl methods

- (void)updateCurrentPageDisplay {
	// ignores this method if the value of defersPageIndicatorUpdate is NO
	if (self.defersCurrentPageDisplay == NO) {
		return;
    }    
	// in case it is YES, we redraw the view (that will update the page control to the correct page)
	[self setNeedsDisplay];
}

- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount {
	CGFloat diameter = (indicatorDiameter > 0) ? indicatorDiameter : kDotDiameter;
	CGFloat space = (indicatorSpace > 0) ? indicatorSpace : kDotSpace;    
	return CGSizeMake(pageCount * diameter + (pageCount - 1) * space + 44.0f, MAX(44.0f, diameter + 4.0f));
}

#pragma mark -
#pragma mark Touches handlers

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	// get the touch location
	UITouch *theTouch = [touches anyObject];
	CGPoint touchLocation = [theTouch locationInView: self];
    
	// check whether the touch is in the right or left hand-side of the control
	if (touchLocation.x < (self.bounds.size.width / 2)) {
		self.currentPage = MAX(self.currentPage - 1, 0);
    } else {
		self.currentPage = MIN(self.currentPage + 1, numberOfPages - 1);
    }
    
	// send the value changed action to the target
	[self sendActionsForControlEvents: UIControlEventValueChanged];
}

@end
