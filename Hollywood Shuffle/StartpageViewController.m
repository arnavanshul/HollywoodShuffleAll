//
//  StartpageViewController.m
//  Hollywood Shuffle
//
//  Created by Daniel Gruici on 8/27/12.
//  Copyright (c) 2012 Daniel Gruici. All rights reserved.
//

#import "StartpageViewController.h"

@interface StartpageViewController ()

@end

@implementation StartpageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIButton *backTemp = [UIButton buttonWithType:UIButtonTypeCustom];
    backTemp.frame = CGRectMake(0, 0, 300, 320);
    backTemp.backgroundColor = [UIColor clearColor];
    
    UIButton *quickPlayButton = [UIButton buttonWithType: UIButtonTypeCustom];
    quickPlayButton.frame = CGRectMake(5, 144, 175, 35);
    [quickPlayButton setBackgroundColor: [UIColor blueColor]];
    //[quickPlayButton setBackgroundImage:[UIImage imageNamed:@"quickplay.png"] forState:UIControlStateNormal];
    [quickPlayButton addTarget:self action:@selector(quickPlayClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [backTemp addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backTemp];
    [self.view addSubview:quickPlayButton];
}

- (void) goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) quickPlayClicked
{
    NSLog(@"quickplayclicked");
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
