//
//  AddMoshiViewController.m
//  MoshiDex
//
//  Created by Jeremy Herrero on 1/3/14.
//  Copyright (c) 2014 Grants International Inc. All rights reserved.
//

#import <Parse/Parse.h>
#import "AddMoshiViewController.h"

@interface AddMoshiViewController () {
    UIImagePickerController *myPicker;
    __weak IBOutlet UIImageView *imageView;
    UIImage *chosenImage;
    UIImage *iconImage;
    UIActivityIndicatorView *activityInd;
    __weak IBOutlet UITextField *nameText;
    __weak IBOutlet UITextField *numberText;
    __weak IBOutlet UITextField *seriesText;
    __weak IBOutlet UITextField *typeText;
    __weak IBOutlet UITextField *speciesText;
    __weak IBOutlet UITextField *rarityText;
    __weak IBOutlet UITextField *locationText;
    __weak IBOutlet UITextView *descriptionText;
    __weak IBOutlet UIBarButtonItem *submitButton;
    __weak IBOutlet UITextField *passwordText;
    __weak IBOutlet UIButton *adminButton;
    
    __weak IBOutlet UIButton *addDescriptionButton;
    __weak IBOutlet UITextField *testTextField;
}

- (IBAction)submitMoshi:(id)sender;
- (IBAction)selectPhoto:(id)sender;
- (IBAction)enterAdmin:(id)sender;
- (IBAction)addDescription:(id)sender;

@end

@implementation AddMoshiViewController

@synthesize adminButtonVar;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    activityInd = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityInd.center = self.view.center;
    [activityInd setColor:[UIColor yellowColor]];
    [activityInd setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:activityInd];
    [self.view bringSubviewToFront:activityInd];
    [activityInd setHidden:YES];
    
    if (adminButtonVar == YES) {
        [adminButton setTitle:@"Exit Admin" forState:UIControlStateNormal];
        [adminButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    }
    
    myPicker = [[UIImagePickerController alloc]init];
    myPicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    myPicker.allowsEditing = YES;
    myPicker.delegate = self;
    // now we present the picker
}

- (IBAction)submitMoshi:(id)sender {
   
    if ((([nameText.text isEqualToString:@""]) || (imageView.image == nil)) || ((([nameText.text isEqualToString:@""]) || (imageView.image == nil)) && (adminButtonVar == YES))) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You must add both a picture and Moshling name to Submit" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil,nil];
        [alert show];
    }else if (adminButtonVar == YES) {
        [self startAnimate];
        [self.enterAdminDelegate changeSubmitVar:YES];
        
        PFObject *mobject = [PFObject objectWithClassName:@"MoshiData"];
        
        mobject[@"MoshiApproved"] = @NO;
        mobject[@"MoshiName"] = nameText.text;
        mobject[@"MoshiNumber"] = @([numberText.text intValue]);
        mobject[@"MoshiSeries"] = @([seriesText.text intValue]);
        mobject[@"MoshiSpecies"] = speciesText.text;
        mobject[@"MoshiType"] = typeText.text;
        mobject[@"MoshiLocation"] = locationText.text;
        mobject[@"MoshiRare"] = rarityText.text;
        mobject[@"MoshiDescription"] = descriptionText.text;
        
        NSData *photo = UIImagePNGRepresentation(chosenImage);
        PFFile *imageFile = [PFFile fileWithName:@"MM.png" data:photo];
        [mobject setObject:imageFile forKey:@"MoshiPicture"];
        
        iconImage = chosenImage;
        CGSize itemSize = CGSizeMake(50, 40);
        UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
        CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
        [iconImage drawInRect:imageRect];
        iconImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSData *iconPhoto = UIImageJPEGRepresentation(iconImage, 0.5);
        PFFile *iconImageFile = [PFFile fileWithName:@"ICON.png" data:iconPhoto];
        [mobject setObject:iconImageFile forKey:@"MoshiIcon"];
        
        [mobject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self finishAnimate];
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                NSString *errorString = [[error userInfo] objectForKey:@"error"];
                NSLog(@"Error: %@", errorString);
                [self finishAnimate];
            }
        }];
    }else{
    
        PFObject *mobject = [PFObject objectWithClassName:@"MoshiData"];
        
        mobject[@"MoshiApproved"] = @NO;
        mobject[@"MoshiName"] = nameText.text;
        mobject[@"MoshiNumber"] = @([numberText.text intValue]);
        mobject[@"MoshiSeries"] = @([seriesText.text intValue]);
        mobject[@"MoshiSpecies"] = speciesText.text;
        mobject[@"MoshiType"] = typeText.text;
        mobject[@"MoshiLocation"] = locationText.text;
        mobject[@"MoshiRare"] = rarityText.text;
        mobject[@"MoshiDescription"] = descriptionText.text;
        
        NSData *photo = UIImagePNGRepresentation(chosenImage);
        PFFile *imageFile = [PFFile fileWithName:@"MM.png" data:photo];
        [mobject setObject:imageFile forKey:@"MoshiPicture"];
        
        iconImage = chosenImage;
        CGSize itemSize = CGSizeMake(50, 40);
        UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
        CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
        [iconImage drawInRect:imageRect];
        iconImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSData *iconPhoto = UIImageJPEGRepresentation(iconImage, 0.5);
        PFFile *iconImageFile = [PFFile fileWithName:@"ICON.png" data:iconPhoto];
        [mobject setObject:iconImageFile forKey:@"MoshiIcon"];
        
        [mobject saveInBackground];
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Submission Successful!" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil,nil];
        alert.tag = 1;
        [alert show];
        
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        if (alertView.tag == 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    }
}

- (IBAction)selectPhoto:(id)sender {
    [self presentViewController:myPicker animated:YES completion:nil];
}

- (IBAction)enterAdmin:(id)sender {
    if ([adminButton.titleLabel.text isEqualToString:@"Exit Admin"]) {
        [self.enterAdminDelegate changeAdminVar:NO];
        [adminButton setTitle:@"Admin only" forState:UIControlStateNormal];
        [adminButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        if ([passwordText.text isEqualToString:@""]) {
            return;
        }
        if ([passwordText.text isEqualToString:@"moshithekid"]) {
            [self.enterAdminDelegate changeAdminVar:YES];
            [adminButton setTitle:@"Exit Admin" forState:UIControlStateNormal];
            [adminButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Administrator Use Only" message:@"Please enter correct password" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil,nil];
            alert.tag = 2;
            [alert show];
        }
    }
}

- (IBAction)addDescription:(id)sender {
    if ([addDescriptionButton.titleLabel.text isEqualToString:@"Add Description"]) {
        [descriptionText setHidden:NO];
        [self.view bringSubviewToFront:descriptionText];
        [addDescriptionButton setTitle:@"Finished Add" forState:UIControlStateNormal];
    } else {
        [descriptionText setHidden:YES];
        [addDescriptionButton setTitle:@"Add Description" forState:UIControlStateNormal];
        [descriptionText resignFirstResponder];
    }
    
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    chosenImage = info[UIImagePickerControllerOriginalImage];
    imageView.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)startAnimate {
    [self.view setUserInteractionEnabled:NO];
    [activityInd setHidden:NO];
    [activityInd startAnimating];
}

- (void)finishAnimate {
    [activityInd setHidden:YES];
    [activityInd stopAnimating];
    [self.view setUserInteractionEnabled:YES];
    
}
//-(void) textViewDidBeginEditing:(UITextView *)textView {
//    
//    CGRect textFieldRect = [self.view.window convertRect:textView.bounds fromView:textView];
//    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
//    
//    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
//    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
//    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
//    CGFloat heightFraction = numerator / denominator;
//    
//    if(heightFraction < 0.0){
//        
//        heightFraction = 0.0;
//        
//    }else if(heightFraction > 1.0){
//        
//        heightFraction = 1.0;
//    }
//    
//    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
//    
//    if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown){
//        
//        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
//        
//    }else{
//        
//        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
//    }
//    
//    CGRect viewFrame = self.view.frame;
//    viewFrame.origin.y -= animatedDistance;
//    
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationBeginsFromCurrentState:YES];
//    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
//    
//    [self.view setFrame:viewFrame];
//    
//    [UIView commitAnimations];
//}
//
//- (void)textViewDidEndEditing:(UITextView *)textView{
//    
//    CGRect viewFrame = self.view.frame;
//    viewFrame.origin.y += animatedDistance;
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationBeginsFromCurrentState:YES];
//    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
//    
//    [self.view setFrame:viewFrame];
//    [UIView commitAnimations];
//}
//
//-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//{
//    if([text isEqualToString:@"\n"])
//    {
//        [textView resignFirstResponder];
//        return NO;
//    }
//    return YES;
//}
//

//- (void)keyboardWillShow:(NSNotification *)notif
//{
//    if (([testTextField isFirstResponder]) && (self.view.frame.origin.y >= 0))
//    {
//        [self setViewMovedUp:YES];
//    }
//    else if (!([testTextField isFirstResponder]) && (self.view.frame.origin.y < 0))
//    {
//        [self setViewMovedUp:NO];
//    }
//}
//
//- (void)viewWillAppear:(BOOL)animated
//{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
//                                                 name:UIKeyboardWillShowNotification object:self.view.window];
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
//}


@end
