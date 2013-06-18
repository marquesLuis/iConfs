//
//  NetworkingViewController.m
//  iConfs-iOS
//
//  Created by Marta Lidon on 01/06/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import "NetworkingViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "PersonProfileViewController.h"

@interface NetworkingViewController ()
@end

@implementation NetworkingViewController
@synthesize networkingDescriptionContent, networkingTitle, networkingDescription, personPhoto, personName, photoPath, netTitle, namePerson, personId, numNetworking;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage    *image = [UIImage imageNamed:@"defaultTableViewBackground.png"];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:image]];

    self.title = netTitle;
    networkingTitle.text = netTitle;
    self.navigationItem.backBarButtonItem.title = @"Back";

    [personName setTitle: namePerson forState: UIControlStateNormal];
    [self.networkingDescription setEditable:NO];
    self.networkingDescription.text = networkingDescriptionContent;
    
    UIImage * imageFromURL;
    if([photoPath isEqualToString:@""])
        imageFromURL = [UIImage imageNamed:@"defaultPerson.jpg"];
    else
        imageFromURL = [UIImage imageWithContentsOfFile:photoPath];
    self.personPhoto.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.personPhoto setImage:imageFromURL];

    [self navigationButtons];
}


-(void)navigationButtons{
    
    UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Home.png"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)];
    [self.navigationItem setLeftBarButtonItem:homeButton];
    
    [self.navigationItem setLeftItemsSupplementBackButton:YES];
}
- (IBAction)goBack:(UIBarButtonItem *)sender {
    [[self navigationController] popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"networing prepare for segue");
    PersonProfileViewController * person = (PersonProfileViewController*)segue.destinationViewController;
    NSLog(@"%@", personId);
    
    person.personID = personId;
    
    
}

@end
