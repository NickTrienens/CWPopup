//
//  UIViewController+CWPopup.m
//  CWPopupDemo
//
//  Created by Cezary Wojcik on 8/21/13.
//  Copyright (c) 2013 Cezary Wojcik. All rights reserved.
//

#import "UIViewController+CWPopup.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

#define ANIMATION_TIME 0.5
#define FADE_ALPHA 0.4
NSString const *CWPopupParentKey = @"CWPopupParentkey";
NSString const *CWPopupKey = @"CWPopupkey";
NSString const *CWFadeViewKey = @"CWFadeViewKey";

@implementation UIViewController (CWPopup)

@dynamic popupViewController;

#pragma mark - present/dismiss

- (void)presentPopupViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    // setup
	[self presentPopupViewController:viewControllerToPresent withSize:CGSizeZero animated:flag completion:completion];
	
}

- (void)presentPopupViewController:(UIViewController *)viewControllerToPresent withSize:(CGSize)inSize animated:(BOOL)flag completion:(void (^)(void))completion {
	[self presentPopupViewController:viewControllerToPresent withSize:inSize tapOutsideToDismiss:YES animated:flag completion:completion];
}

- (void)presentPopupViewController:(UIViewController *)viewControllerToPresent withSize:(CGSize)inSize tapOutsideToDismiss:(BOOL)inTap animated:(BOOL)flag completion:(void (^)(void))completion {
	[self presentPopupViewController:viewControllerToPresent withSize:inSize tapOutsideToDismiss:inTap animated:flag shadow:YES completion:completion];
}


- (void)presentPopupViewController:(UIViewController *)viewControllerToPresent withSize:(CGSize)inSize tapOutsideToDismiss:(BOOL)inTap animated:(BOOL)flag shadow:(BOOL)inShadow completion:(void (^)(void))completion {
	[self presentPopupViewController:viewControllerToPresent withSize:inSize tapOutsideToDismiss:inTap animated:flag shadow:inShadow attachement:CWPopupAttachmentPositionCenter completion:completion];
}

- (void)presentPopupViewController:(UIViewController *)viewControllerToPresent withSize:(CGSize)inSize tapOutsideToDismiss:(BOOL)inTap animated:(BOOL)flag shadow:(BOOL)inShadow attachement:(CWPopupAttachmentPosition)inAttatchment completion:(void (^)(void))completion {
	
	if(self.popupViewController != nil){
		return;
	}
	NSAssert(self.popupViewController == nil, @"Trying to present a second popup");

    self.popupViewController = viewControllerToPresent;
	viewControllerToPresent.popupParentViewController = self;
    CGRect frame = viewControllerToPresent.view.frame;
	if(!CGSizeEqualToSize(inSize , CGSizeZero)){
		frame.size = inSize;
		viewControllerToPresent.view.frame = frame;
	}
	CGFloat tmpNabrBarHeight = (self.navigationController.navigationBarHidden )?0:self.navigationController.navigationBar.bounds.size.height;
	
    CGFloat x = (self.view.bounds.size.width - viewControllerToPresent.view.frame.size.width)/2;
    CGFloat y =(self.view.bounds.size.height - tmpNabrBarHeight - viewControllerToPresent.view.frame.size.height)/2;
	
	if([UIDevice systemVersion] < 8.0 && [UIDevice isIPhone]){
		
		y += 54;
	}
	
	
    CGRect finalFrame = CGRectMake(x, y, frame.size.width, frame.size.height);
	finalFrame = [self adjustFrame:finalFrame forAttachmentType:inAttatchment];
    // shadow setup
	
	if(inShadow){
		viewControllerToPresent.view.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
		viewControllerToPresent.view.layer.shadowColor = [UIColor blackColor].CGColor;
		viewControllerToPresent.view.layer.shadowRadius = 3.0f;
		viewControllerToPresent.view.layer.shadowOpacity = 0.8f;
	}
//    viewControllerToPresent.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:viewControllerToPresent.view.layer.bounds].CGPath;
	

	
    // rounded corners
    viewControllerToPresent.view.layer.cornerRadius = 5.0f;
    // black uiview
    UIButton *fadeView = [UIButton buttonWithType:UIButtonTypeCustom];
    fadeView.frame = self.view.bounds;
	[fadeView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth ];
    fadeView.backgroundColor = [UIColor blackColor];
    fadeView.alpha = 0.0f;
    [self.view addSubview:fadeView];
	if(inTap)
		[fadeView addTarget:self action:@selector(closePopup) forControlEvents:UIControlEventTouchUpInside];

    objc_setAssociatedObject(self, &CWFadeViewKey, fadeView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

	[self viewWillDisappear:flag];
	[self.popupViewController viewWillAppear:flag];

    if (flag) { // animate
        CGRect initialFrame = CGRectMake(finalFrame.origin.x, [UIScreen mainScreen].bounds.size.height + viewControllerToPresent.view.frame.size.height/2, finalFrame.size.width, finalFrame.size.height);
        viewControllerToPresent.view.frame = initialFrame;
        [self.view addSubview:viewControllerToPresent.view];
        [UIView animateWithDuration:ANIMATION_TIME delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            viewControllerToPresent.view.frame = finalFrame;
            fadeView.alpha = FADE_ALPHA;
        } completion:^(BOOL finished) {
            [completion invoke];
			[self.popupViewController viewDidAppear:YES];
			[self viewDidDisappear:flag];
        }];
    } else { // don't animate
        viewControllerToPresent.view.frame = finalFrame;
        [self.view addSubview:viewControllerToPresent.view];
        [completion invoke];
		[self.popupViewController viewDidAppear:NO];
		[self viewDidDisappear:flag];

    }
}

-(CGRect)adjustFrame:(CGRect)inFrame forAttachmentType:(CWPopupAttachmentPosition)inAttatchment{
	
	switch (inAttatchment) {
		case CWPopupAttachmentPositionCenter:
		{
			//assume the frame is already centered with correct size
			
			[self.popupViewController.view setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin];
			return inFrame;
			break;
		}
			
		case CWPopupAttachmentPositionFullHeightRightAligned:
		{
			
			CGFloat x = self.view.bounds.size.width - self.popupViewController.view.frame.size.width;
			CGFloat y = 0;
			CGRect finalFrame = CGRectMake(x, y, inFrame.size.width, self.view.bounds.size.height);
			
			[self.popupViewController.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin];

			return finalFrame;
			break;
		}
		case CWPopupAttachmentPositionFullHeightLeftAligned:
		{
			
			CGFloat x = 0;
			CGFloat y = 0;
			CGRect finalFrame = CGRectMake(x, y, inFrame.size.width, self.view.bounds.size.height);
			
			[self.popupViewController.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleRightMargin];
			
			return finalFrame;
			break;
		}
		default:
			break;
	}
	
}


-(void)setPopupViewSize:(CGSize)inSize{
	if(self.popupViewController == nil){
		[self.popupParentViewController setPopupViewSize:inSize];
		return;
	}
	CGRect frame = self.popupViewController.view.frame;
	if(!CGSizeEqualToSize(inSize , CGSizeZero)){
		frame.size = inSize;
		self.popupViewController.view.frame = frame;
	}
	CGFloat x = (self.view.bounds.size.width - self.popupViewController.view.frame.size.width)/2;
    CGFloat y =(self.view.bounds.size.height - self.popupViewController.view.frame.size.height)/2;
	
	if([UIDevice systemVersion] < 8.0 && [UIDevice isIPhone]){
		
		y += 54;
	}
	
    CGRect finalFrame = CGRectMake(x, y, frame.size.width, frame.size.height);
	self.popupViewController.view.frame = finalFrame;
	
	
}

- (void)dismissPopupViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
	if(self.popupViewController == nil){
		[self.popupParentViewController dismissPopupViewControllerAnimated:flag completion:completion];
		return;
	}
	
    UIView *fadeView = objc_getAssociatedObject(self, &CWFadeViewKey);
	
    if (flag) { // animate
        CGRect initialFrame = self.popupViewController.view.frame;
		[self.popupViewController viewWillDisappear:YES];

		[self viewWillAppear:YES];
		UIView * tmpOldView = self.popupViewController.view;
	

		[UIView animateWithDuration:ANIMATION_TIME delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.popupViewController.view.frame = CGRectMake(initialFrame.origin.x, [UIScreen mainScreen].bounds.size.height + initialFrame.size.height/2, initialFrame.size.width, initialFrame.size.height);
            fadeView.alpha = 0.0f;
			
			self.popupViewController.popupParentViewController = nil;
			self.popupViewController = nil;
			
        } completion:^(BOOL finished) {
            [tmpOldView removeFromSuperview];
            [fadeView removeFromSuperview];
			[self viewDidAppear:YES];

						
            [completion invoke];
        }];
    } else { // don't animate
		[self.popupViewController viewWillDisappear:NO];
		UIView * tmpOldView = self.popupViewController.view;
		self.popupViewController.popupParentViewController = nil;
        self.popupViewController = nil;

		[self viewWillAppear:NO];
        [tmpOldView removeFromSuperview];
        [fadeView removeFromSuperview];
		[self viewDidAppear:NO];
        fadeView = nil;

        [completion invoke];
    }
}

-(UIButton*)fadeView{
    UIButton *fadeView = objc_getAssociatedObject(self, &CWFadeViewKey);
	return fadeView;
}

-(void)closePopup{
	[self dismissPopupViewControllerAnimated:YES completion:nil];
}

#pragma mark - popupViewController getter/setter

- (void)setPopupViewController:(UIViewController *)popupViewController {
    objc_setAssociatedObject(self, &CWPopupKey, popupViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIViewController *)popupViewController {
    return objc_getAssociatedObject(self, &CWPopupKey);
}

#pragma mark - popupParentViewController getter/setter

- (void)setPopupParentViewController:(UIViewController *)popupParentViewController {
    objc_setAssociatedObject(self, &CWPopupParentKey, popupParentViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIViewController *)popupParentViewController {
    return objc_getAssociatedObject(self, &CWPopupParentKey);
}

@end
