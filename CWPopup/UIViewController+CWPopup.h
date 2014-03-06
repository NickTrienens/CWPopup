//
//  UIViewController+CWPopup.h
//  CWPopupDemo
//
//  Created by Cezary Wojcik on 8/21/13.
//  Copyright (c) 2013 Cezary Wojcik. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	CWPopupAttachmentPositionCenter = 0,
	CWPopupAttachmentPositionFullHeightRightAligned = 1,
	CWPopupAttachmentPositionFullHeightLeftAligned = 2
	
} CWPopupAttachmentPosition;

@interface UIViewController (CWPopup)


@property (nonatomic, readwrite) UIViewController *popupViewController;
@property (nonatomic, readwrite) UIViewController *popupParentViewController;

- (void)presentPopupViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion;
- (void)presentPopupViewController:(UIViewController *)viewControllerToPresent withSize:(CGSize)inSize animated:(BOOL)flag completion:(void (^)(void))completion;
- (void)presentPopupViewController:(UIViewController *)viewControllerToPresent withSize:(CGSize)inSize tapOutsideToDismiss:(BOOL)inTap animated:(BOOL)flag completion:(void (^)(void))completion;
- (void)presentPopupViewController:(UIViewController *)viewControllerToPresent withSize:(CGSize)inSize tapOutsideToDismiss:(BOOL)inTap animated:(BOOL)flag shadow:(BOOL)inShadow completion:(void (^)(void))completion;
- (void)presentPopupViewController:(UIViewController *)viewControllerToPresent withSize:(CGSize)inSize tapOutsideToDismiss:(BOOL)inTap animated:(BOOL)flag shadow:(BOOL)inShadow attachement:(CWPopupAttachmentPosition)inAttatchment completion:(void (^)(void))completion;

- (void)dismissPopupViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion;

-(UIButton*)fadeView;

-(void)setPopupViewSize:(CGSize)inSize;


@end
