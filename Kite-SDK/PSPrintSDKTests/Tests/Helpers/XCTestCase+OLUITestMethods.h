//
//  XCTestCase+OLUITestMethods.h
//  KitePrintSDK
//
//  Created by Konstadinos Karayannis on 24/01/2017.
//  Copyright © 2017 Kite.ly. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OLKitePrintSDK.h"
#import "OLProductHomeViewController.h"
#import "OLNavigationController.h"
#import "OLKiteTestHelper.h"
#import "OLProductGroup.h"
#import "OLProductTypeSelectionViewController.h"
#import "NSObject+Utils.h"
#import "OLPackProductViewController.h"
#import "OLProductOverviewViewController.h"
#import "OLCaseViewController.h"
#import "OLKiteUtils.h"
#import "OLPrintOrder.h"
#import "OLPaymentViewController.h"
#import "OLCreditCardCaptureViewController.h"
#import "OLKiteABTesting.h"
#import "OLAddressEditViewController.h"
#import "OLTestTapGestureRecognizer.h"
#import "OLCustomViewControllerPhotoProvider.h"
#import "OLPrintOrder+History.h"
#import "OLFrameOrderReviewViewController.h"
#import "OLInfoPageViewController.h"
#import "OLUserSession.h"
#import "OLPhotoEdits.h"
#import "OLImagePickerViewController.h"
#import "OLPaymentMethodsViewController.h"
#import "OLImagePickerPhotosPageViewController.h"
#import "OLButtonCollectionViewCell.h"
#import "OLPhotoTextField.h"
#import "OLBaseRequest.h"
#import "OLImagePickerLoginPageViewController.h"
#import "OLMockPanGestureRecognizer.h"
#import "OL3DProductViewController.h"
#import "OLAddressSelectionViewController.h"
#import "OLKiteViewController+Private.h"
#import "OLAsset+Private.h"
#import "OLImageView.h"
#import "OLCollagePosterViewController.h"
#import "OLPhotobookPageContentViewController.h"
#import "OLQRCodeUploadViewController.h"
#import "OLShippingMethodsViewController.h"
#import "OLMockLongPressGestureRecognizer.h"

@interface XCTestCase (OLUITestMethods)
- (NSInteger)findIndexForProductName:(NSString *)name inOLProductTypeSelectionViewController:(OLProductTypeSelectionViewController *)vc;
- (OLProductHomeViewController *)loadKiteViewController;
- (void)chooseClass:(NSString *)class onOLProductHomeViewController:(OLProductHomeViewController *)productHome;
- (void)chooseProduct:(NSString *)name onOLProductTypeSelectionViewController:(OLProductTypeSelectionViewController *)productTypeVc;
- (void)performUIAction:(void(^)(void))action;
- (void)performUIActionWithDelay:(double)delay action:(void(^)(void))action;
- (void)setUpHelper;
- (void)tapNextOnViewController:(UIViewController *)vc;
- (void)tearDownHelper;
- (void)templateSyncWithSuccessHandler:(void(^)(void))handler;
@end

@interface OLArtboardView ()
- (void)handleTapGesture:(UITapGestureRecognizer *)sender;
- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)sender;
- (void)handlePanGesture:(UIPanGestureRecognizer *)sender;
@end

@interface UIViewController ()
- (IBAction)onButtonBasketClicked:(UIBarButtonItem *)sender;
@end

@interface OLFrameOrderReviewViewController ()
- (void)onTapGestureThumbnailTapped:(UITapGestureRecognizer*)gestureRecognizer;
@end

@interface OLImagePickerLoginPageViewController ()
- (IBAction)onButtonLoginTapped:(UIButton *)sender ;
@end

@interface OLKitePrintSDK ()
+ (BOOL)setUseStripeForCreditCards:(BOOL)use;
+ (void)setUseStaging:(BOOL)staging;
@end

@interface OLProductTypeSelectionViewController (Private)
-(NSMutableArray *) products;
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface OLButtonCollectionViewCell ()
- (void)onButtonTouchUpInside;
@end

@interface OLProductHomeViewController (Private)

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)productGroups;
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;
@end

@interface OLPackProductViewController ()
@property (strong, nonatomic) UIButton *ctaButton;
- (void) deletePhotoAtIndex:(NSUInteger)index;
@end

@interface OLPhotobookViewController ()
@property (weak, nonatomic) IBOutlet UIButton *ctaButton;
- (void)onPanGestureRecognized:(UIPanGestureRecognizer *)recognizer;
- (void)openBook:(UIGestureRecognizer *)sender;
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer;
- (void)closeBookFrontForGesture:(UIPanGestureRecognizer *)sender;
- (void)closeBookBackForGesture:(UIPanGestureRecognizer *)sender;
@end

@interface OLProductOverviewViewController ()
- (IBAction)onLabelDetailsTapped:(UITapGestureRecognizer *)sender;
@end

@interface OLImageEditViewController () <UICollectionViewDelegate, UITextFieldDelegate>
- (void)onButtonClicked:(UIButton *)sender;
@property (strong, nonatomic) NSMutableArray<OLPhotoTextField *> *textFields;
- (IBAction)onButtonDoneTapped:(UIBarButtonItem *)sender;
- (IBAction)onBarButtonCancelTapped:(UIBarButtonItem *)sender;
- (void)onTapGestureRecognized:(id)sender;
@end

@interface OLCaseViewController ()
- (IBAction)onButtonProductFlipClicked:(UIButton *)sender;
- (void)exitCropMode;
- (void)onButtonCropClicked:(UIButton *)sender;
@property (assign, nonatomic) BOOL downloadedMask;
@property (weak, nonatomic) IBOutlet UIButton *productFlipButton;
@end

@interface OLPaymentViewController () <UITableViewDataSource>
- (IBAction)onButtonAddPaymentMethodClicked:(id)sender;
- (IBAction)onButtonContinueShoppingClicked:(UIButton *)sender;
- (IBAction)onButtonEditClicked:(UIButton *)sender;
- (IBAction)onButtonPayClicked:(UIButton *)sender;
- (IBAction)onShippingDetailsGestureRecognized:(id)sender;
- (void)onBackgroundClicked;
- (void)payPalPaymentDidCancel:(id)paymentViewController;
- (void)paymentMethodsViewController:(OLPaymentMethodsViewController *)vc didPickPaymentMethod:(OLPaymentMethod)method;
- (void)submitOrderForPrintingWithProofOfPayment:(NSString *)proofOfPayment paymentMethod:(NSString *)paymentMethod completion:(id)handler;
- (IBAction)onShippingMethodGestureRecognized:(id)sender;
@property (strong, nonatomic) OLPrintOrder *printOrder;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *promoCodeTextField;
@end


@interface OLKiteABTesting ()
@property (strong, nonatomic, readwrite) NSString *qualityBannerType;
@property (strong, nonatomic, readwrite) NSString *launchWithPrintOrderVariant;
@property (strong, nonatomic, readwrite) NSString *checkoutScreenType;
@property (strong, nonatomic, readwrite) NSString *promoBannerText;
@end

@interface OLImagePickerViewController ()
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
@property (weak, nonatomic) IBOutlet UICollectionView *sourcesCollectionView;
@property (strong, nonatomic) UIPageViewController *pageController;
@end

@interface OLImagePickerPhotosPageViewController () <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
- (IBAction)userDidTapOnAlbumLabel:(UITapGestureRecognizer *)sender;
- (void)onButtonLogoutTapped;
@end
