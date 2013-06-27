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
@synthesize networkingDescriptionContent, networkingTitle, personPhoto, personName, photoPath, netTitle, namePerson, personId, numNetworking;


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
    
    UITextView *description =  [[UITextView alloc] initWithFrame:CGRectMake(15, 145, self.view.frame.size.width-30, 100)];
    [description setText:networkingDescriptionContent];
    description.layer.cornerRadius = 5.0f;
    description.clipsToBounds = YES;
    [description setEditable:NO];
    
    UITextView *aux =  [[UITextView alloc] initWithFrame:CGRectMake(15, 145, self.view.frame.size.width-30, 100)];
    [aux setText:networkingDescriptionContent];
    NSLog(@"%f", description.contentSize.height);
    NSLog(@"%f", aux.contentSize.height);

    if(description.contentSize.height <= 100){
        NSLog(@"hey");
        CGRect frame = description.frame;
        frame.size.height = description.contentSize.height;
        description.frame = frame;
        description.backgroundColor = [UIColor whiteColor];
        [description setFrame:CGRectMake(15, 145, self.view.frame.size.width-30,description.contentSize.height) ];
    }
    [self.view addSubview:description];
    
    [personName setTitle: namePerson forState: UIControlStateNormal];
    networkingTitle.layer.cornerRadius = 5.0f;
    networkingTitle.backgroundColor = [UIColor colorWithRed:(16/255.f) green:(78/255.f) blue:(139/255.f) alpha:1.0f ];
    networkingTitle.textColor = [UIColor whiteColor];
    networkingTitle.clipsToBounds = YES;
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
    [[self navigationController] popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"segue3"]){
        PersonProfileViewController * person = (PersonProfileViewController*)segue.destinationViewController;
        person.personID = personId;
    }
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotate{
    return NO;
}

@end
