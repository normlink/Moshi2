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
    
}

- (IBAction)submitMoshi:(id)sender;
- (IBAction)selectPhoto:(id)sender;
- (IBAction)enterAdmin:(id)sender;

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
   
    if (([nameText.text isEqualToString:@""]) || (imageView.image == nil))   {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You must add both a picture and Moshling name to Submit" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil,nil];
        [alert show];
    }
    if (adminButtonVar == YES) {
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    chosenImage = info[UIImagePickerControllerEditedImage];
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

@end
