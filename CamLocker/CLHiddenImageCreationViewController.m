//
//  CLHiddenImageCreationViewController.m
//  CamLocker
//
//  Created by FlyinGeek on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLUtilities.h"
#import "CLMarkerManager.h"
#import "CLHiddenImageCreationViewController.h"
#import "SWSnapshotStackView.h"
#import "JDStatusBarNotification.h"
#import "ETActivityIndicatorView.h"
#import "UIColor+MLPFlatColors.h"
#import "SIAlertView.h"
#import "PhotoStackView.h"
#import "ANBlurredImageView.h"
#import "URBMediaFocusViewController.h"
#import "UIView+Genie.h"

@interface CLHiddenImageCreationViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, PhotoStackViewDataSource, PhotoStackViewDelegate, URBMediaFocusViewControllerDelegate> {
    BOOL isEncrypting;
}

@property (nonatomic) NSMutableArray *hiddenImages;
@property (nonatomic) NSMutableArray *photos;
@property (nonatomic) URBMediaFocusViewController *mediaFocusController;

@property (weak, nonatomic) IBOutlet UIView *masterView;
@property (weak, nonatomic) IBOutlet ANBlurredImageView *imageView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet PhotoStackView *photoStack;
@property (weak, nonatomic) IBOutlet UIButton *addImageButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addMoreButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *trashButton;

@end

@implementation CLHiddenImageCreationViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.mediaFocusController = [[URBMediaFocusViewController alloc] init];
	self.mediaFocusController.delegate = self;
    
    [CLUtilities addBackgroundImageToView:self.masterView withImageName:@"bg_4.jpg"];
    
    isEncrypting = NO;
    
    _hiddenImages = [[NSMutableArray alloc]init];
    _photos = [[NSMutableArray alloc]init];
    
    _photoStack.center = CGPointMake(self.view.center.x, 170);
    _photoStack.dataSource = self;
    _photoStack.delegate = self;
    self.photoStack.hidden = YES;
    self.pageControl.hidden = YES;
    self.trashButton.enabled = NO;
    
    [_imageView setHidden:YES];
    [_imageView setFramesCount:5];
    [_imageView setBlurAmount:1];
    
    self.addImageButton.layer.cornerRadius = 15;
    if (!DEVICE_IS_4INCH_IPHONE) {
        self.addImageButton.frame = CGRectMake(50, 160, 220, 237);
    }
    [self.addImageButton.layer addSublayer:[CLUtilities addDashedBorderToView:self.addImageButton
                                                                    withColor:[UIColor flatWhiteColor].CGColor]];

}

- (IBAction)trashButtonPressed:(id)sender {
    
    self.photoStack.userInteractionEnabled = NO;

    if (self.photos.count == 1) {
        [UIView animateWithDuration:1.0f animations:^{
            self.pageControl.alpha = 0.0f;
        } completion:^(BOOL finished){
            self.pageControl.hidden = YES;
        }];
    }
    [[self.photoStack topPhoto] genieInTransitionWithDuration:0.7
                                              destinationRect:CGRectMake(130, self.view.frame.size.height - 40, 1, 1)
                                              destinationEdge:BCRectEdgeTop
                                                   completion:^{
                                                      
                                                       [self.photos removeObjectAtIndex:self.pageControl.currentPage];
                                                       [self.hiddenImages removeObjectAtIndex:self.pageControl.currentPage];

                                                       [self.photoStack reloadData];
                                                       
                                                       if (self.pageControl.currentPage == self.pageControl.numberOfPages - 1) {
                                                           self.pageControl.numberOfPages--;
                                                           self.pageControl.currentPage = self.pageControl.numberOfPages - 1;
                                                       } else {
                                                           self.pageControl.numberOfPages--;
                                                       }
                                                       
                                                       if (self.hiddenImages.count == 0) {
                                                           
                                                           self.photoStack.hidden = YES;
                                                           self.trashButton.enabled = NO;
                                                           self.pageControl.alpha = 0.3f;
                                                           self.addImageButton.alpha = 0.0f;
                                                           self.addImageButton.hidden = NO;
                                                           
                                                           [UIView animateWithDuration:1.0f animations:^{
                                                               self.addImageButton.alpha = 0.3f;
                                                           } completion:nil];
                                                       }
                                                       self.photoStack.userInteractionEnabled = YES;
                                                   }];

}

- (IBAction)addImageButtonPressed:(id)sender {
    
    if (isEncrypting) return;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)addMoreButtonPressed:(id)sender {
    
    if (isEncrypting) return;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:picker animated:YES completion:nil];
}


- (IBAction)doneButtonPressed:(id)sender {
    
    if (isEncrypting) return;
    if (self.photos.count == 0) {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Oops" andMessage:@"Please add a photo."];
        [alertView addButtonWithTitle:@"OK"
                                 type:SIAlertViewButtonTypeDestructive
                              handler:nil];
        alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
        alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
        alertView.titleFont = [UIFont fontWithName:@"OpenSans" size:25.0];
        alertView.messageFont = [UIFont fontWithName:@"OpenSans" size:15.0];
        alertView.buttonFont = [UIFont fontWithName:@"OpenSans" size:17.0];
        
        [alertView show];
        return;
    }
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Almost there" andMessage:@"Are you ready to create this marker?"];
    [alertView addButtonWithTitle:@"No"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                          }];
    [alertView addButtonWithTitle:@"Yes"
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alertView) {
                              
                              self.navigationController.navigationBar.userInteractionEnabled = NO;
                              isEncrypting = YES;
                              self.imageView.hidden = NO;
                              self.imageView.image = [CLUtilities screenShotForView:self.masterView];
                              self.imageView.baseImage = self.imageView.image;
                              [self.imageView generateBlurFramesWithCompletionBlock:^{
                                  
                                  [self.imageView blurInAnimationWithDuration:0.3f];
                                  self.photoStack.userInteractionEnabled = NO;
                                  ETActivityIndicatorView *etActivity = [[ETActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 30, self.view.frame.size.height/2 -30, 60, 60)];
                                  etActivity.color = [UIColor flatWhiteColor];
                                  [etActivity startAnimating];
                                  [self.view addSubview:etActivity];
                                  [JDStatusBarNotification showWithStatus:@"Encrypting Data..." styleName:JDStatusBarStyleError];
                                  
                                  [[CLMarkerManager sharedManager] addImageMarkerWithMarkerImage:[CLMarkerManager sharedManager].tempMarkerImage
                                                                                    hiddenImages:self.hiddenImages
                                                                             withCompletionBlock:^{
                                                                                 self.photoStack.userInteractionEnabled = YES;
                                                                                 [JDStatusBarNotification showWithStatus:@"New marker created!" dismissAfter:1.0f styleName:JDStatusBarStyleSuccess];
                                                                                 [CLMarkerManager sharedManager].tempMarkerImage = nil;
                                                                                 [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                                                                                 [etActivity removeFromSuperview];
                                                                                 isEncrypting = NO;
                                                                                 self.navigationController.navigationBar.userInteractionEnabled = YES;
                                                                             }];
                              }];

                              
    }];
    alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
    alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
    alertView.titleFont = [UIFont fontWithName:@"OpenSans" size:25.0];
    alertView.messageFont = [UIFont fontWithName:@"OpenSans" size:15.0];
    alertView.buttonFont = [UIFont fontWithName:@"OpenSans" size:17.0];
    
    [alertView show];
}

/*
- (void)executeAnimation
{
    CGRect initRect = self.imageView.frame;
    self.imageView.frame = CGRectMake(initRect.origin.x - 25, initRect.origin.y - 25, initRect.size.width + 50, initRect.size.height + 50);
    [UIView animateWithDuration:1.2f animations:^{
        self.imageView.alpha = 1.0f;
        self.imageView.frame = initRect;
    } completion:^(BOOL finished){
    }];
}
 */

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    [self.hiddenImages insertObject:chosenImage atIndex:self.pageControl.currentPage];
    
    UIImage *croppedImage = [CLUtilities imageWithImage:chosenImage scaledToWidth:220 + arc4random() % 35];
    if (croppedImage.size.height > self.photoStack.frame.size.height) {
        croppedImage = [CLUtilities imageWithImage:croppedImage scaledToHeight:self.photoStack.frame.size.height - 10];
    }
    [self.photos insertObject:croppedImage atIndex:self.pageControl.currentPage];
    [self.photoStack reloadData];
     self.pageControl.numberOfPages = [self.photos count];
    // self.photoStack.alpha = 0.0f;
    self.photoStack.hidden = NO;
    self.pageControl.hidden = NO;
    self.addImageButton.hidden = YES;
    self.trashButton.enabled = YES;
    
    //[self executeAnimation];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark -
#pragma mark Deck DataSource Protocol Methods

-(NSUInteger)numberOfPhotosInPhotoStackView:(PhotoStackView *)photoStack {
    return [self.photos count];
}

-(UIImage *)photoStackView:(PhotoStackView *)photoStack photoForIndex:(NSUInteger)index {
    return [self.photos objectAtIndex:index];
}



#pragma mark -
#pragma mark Deck Delegate Protocol Methods

-(void)photoStackView:(PhotoStackView *)photoStackView willStartMovingPhotoAtIndex:(NSUInteger)index {
    // User started moving a photo
}

-(void)photoStackView:(PhotoStackView *)photoStackView willFlickAwayPhotoFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    // User flicked the photo away, revealing the next one in the stack
}

-(void)photoStackView:(PhotoStackView *)photoStackView didRevealPhotoAtIndex:(NSUInteger)index {
    self.pageControl.currentPage = index;
}

-(void)photoStackView:(PhotoStackView *)photoStackView didSelectPhotoAtIndex:(NSUInteger)index {
    NSLog(@"selected %d", index);
    [self.mediaFocusController showImage:self.hiddenImages[index] fromView:photoStackView];
}


@end
