//
//  QuickPlayViewController.m
//  Hollywood Shuffle
//
//  Created by Arnav Anshul on 8/27/12.
//  Copyright (c) 2012 Daniel Gruici. All rights reserved.
//

#import "QuickPlayViewController.h"
#import "ActorObject.h"
#include <QuartzCore/QuartzCore.h>

@interface QuickPlayViewController ()

@end

@implementation QuickPlayViewController

#define CARD_WIDTH_PHONE 64
#define CARD_HEIGHT_PHONE 90
#define HAND_SCALE_FACTOR 1.1
#define CARD_WIDTH_TAB 63
#define CARD_HEIGHT_TAB 95

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
    
    selectedRow = -1;
    
    doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGestures:)];
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    
    handLongPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleHandLongPressGesture:)];
    handLongPressGestureRecognizer.minimumPressDuration = 0.1;
    
    reelLongPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleReelLongPressGesture:)];
    reelLongPressGestureRecognizer.minimumPressDuration = 0.25;
    
    cardsInHand = [[NSMutableArray alloc] init];
    cardsOnReel = [[NSMutableArray alloc] init];
    cardsPlacedThisHand = [[NSMutableArray alloc] init];
    
    cardSelected = NULL;
    
    castButton = [UIButton buttonWithType:UIButtonTypeCustom];
    castButton.frame = CGRectMake(400, 223, 82, 42);
    castButton.tag = 1;
    castButton.backgroundColor = [UIColor clearColor];
    [castButton addTarget:self action:@selector(castButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *castBtnBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 82, 42)];
    castBtnBg.image = [UIImage imageNamed:@"cast.png"];
    
    [castButton addSubview:castBtnBg];
    
    drawButton = [UIButton buttonWithType:UIButtonTypeCustom];
    drawButton.frame = CGRectMake(400, 265, 82, 42);
    drawButton.backgroundColor = [UIColor clearColor];
    [drawButton addTarget:self action:@selector(drawButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *drawBtnBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 82, 42)];
    drawBtnBg.image = [UIImage imageNamed:@"draw.png"];
    
    [drawButton addSubview:drawBtnBg];
    
    UIImageView *deckStack = [[UIImageView alloc] initWithFrame:CGRectMake(139, 110, 64, 93)];
    deckStack.image = [UIImage imageNamed:@"deck_stack.png"];
    
    handCardListView = [[UIScrollView alloc] init];
    handCardListView.contentSize = CGSizeMake(750, CARD_HEIGHT_PHONE);
    handCardListView.backgroundColor = [UIColor clearColor];
    handCardListView.frame = CGRectMake(0, 215, 370, 100);
    [handCardListView addGestureRecognizer:handLongPressGestureRecognizer];
    handCardListView.canCancelContentTouches = NO;
    
    filmReelListView = [[UIScrollView alloc] init];
    filmReelListView.contentSize = CGSizeMake((CARD_WIDTH_PHONE + 6) * 4, CARD_HEIGHT_PHONE + 30);
    filmReelListView.backgroundColor = [UIColor clearColor];
    [filmReelListView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
    filmReelListView.frame = CGRectMake(200, 95, 280, 120);
    [filmReelListView addGestureRecognizer:doubleTapGestureRecognizer];
    [filmReelListView addGestureRecognizer:reelLongPressGestureRecognizer];
    
    settingsView = [[UIView alloc] initWithFrame:CGRectMake(420, 10, 260, 310)];
    settingsView.backgroundColor = [UIColor clearColor];
    [self layoutSettingsView];
    settingsShowing = false;
    
    castMovieView = [[UIView alloc] initWithFrame:CGRectMake(36, 5, 408, 120)];
    castMovieView.backgroundColor = [UIColor clearColor];
    [self layoutCastMovieView];
    castMovieView.hidden = true;
    //castMovieViewShowing = false;
    
    //actorNameBg = [[UIImageView alloc] initWithFrame:CGRectMake(-110, 140, 104, 46)];
    actorNameBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 140, 110, 40)];
    actorNameBg.image = [UIImage imageNamed:@"popout_name.png"];
    
    actorNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 104, 46)];
    actorNameLabel.backgroundColor = [UIColor clearColor];
    actorNameLabel.textColor = [UIColor whiteColor];
    actorNameLabel.textAlignment = UITextAlignmentCenter;
    actorNameLabel.font = [UIFont fontWithName:@"DINEngschrift-Alternate" size:13];
    actorNameLabel.numberOfLines = 0;
    [actorNameBg addSubview:actorNameLabel];
    [self.view addSubview: actorNameBg];
    
    //FOR UI TEST PURPOSES; STARTING HERE
    
    for (int i = 0; i < 10; i++)
    {
        ActorObject *obj = [[ActorObject alloc] init];
        obj.actorImageView.image = [UIImage imageNamed:@"cardinhand.png"];
        [obj.actorName setString:[NSString stringWithFormat:@"Keira Knightley %d", i]];
        [cardsInHand addObject:obj];
    }
    
    ActorObject *obj = [[ActorObject alloc] init];
    obj.actorImageView.image = [UIImage imageNamed:@"cardinhand.png"];
    [obj.actorName setString:@"Keira Knightley on reel"];
    [cardsOnReel addObject:obj];
    
    //FOR UI TEST PURPOSES; ENDING HERE
        
    actorTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, 80, 225) style:UITableViewStylePlain];
    actorTable.scrollEnabled = TRUE;
    actorTable.dataSource = self;
    actorTable.delegate = self;
    actorTable.backgroundColor = [UIColor clearColor];
    actorTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview: deckStack];
    [self.view addSubview: filmReelListView];
    [self.view addSubview: handCardListView];
    [self.view addSubview: settingsView];
    [self.view addSubview: castMovieView];
    [self.view addSubview: castButton];
    [self.view addSubview: drawButton];
    
    if([[[UIDevice currentDevice] name] isEqualToString:@"iPad Simulator"])
    {
        actorTable.frame = CGRectMake(0, 300, 150, 350);
        castButton.frame = CGRectMake(800, 450, 250, 50);
        drawButton.frame = CGRectMake(800, 520, 250, 50);
        handCardListView.frame = CGRectMake(180, 420, 580, 220);
        
        [self.view addSubview: actorTable];
    }
    
    [self layoutHand];
}

/*
- (void) viewDidAppear:(BOOL)animated
{
    actorNameBg.frame = CGRectMake(0, 140, 110, 40);
    [actorNameBg setHidden: FALSE];
}
*/


- (void) layoutSettingsView
{
    settingsBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 260, 310)];
    settingsBg.image = [UIImage imageNamed:@"bg_border_andgear.png"];
    
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingsButton addTarget:self action:@selector(settingsClicked) forControlEvents:UIControlEventTouchUpInside];
    settingsButton.frame = CGRectMake(0, 0, 60, 60);
    
    UIButton *volumeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    volumeButton.frame = CGRectMake(142, 15, 40, 30);
    [volumeButton setBackgroundImage:[UIImage imageNamed:@"sound.png"] forState:UIControlStateNormal];
    [volumeButton addTarget:self action:@selector(volumeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *helpButton = [UIButton buttonWithType: UIButtonTypeCustom];
    helpButton.frame = CGRectMake(95, 75, 142, 40);
    [helpButton setBackgroundImage:[UIImage imageNamed:@"help.png"] forState:UIControlStateNormal];
    [helpButton addTarget:self action:@selector(helpButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *settings2Button = [UIButton buttonWithType: UIButtonTypeCustom];
    settings2Button.frame = CGRectMake(95, 117, 142, 40);
    [settings2Button setBackgroundImage:[UIImage imageNamed:@"settings2.png"] forState:UIControlStateNormal];
    [settings2Button addTarget:self action:@selector(settings2ButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *exitButton = [UIButton buttonWithType: UIButtonTypeCustom];
    exitButton.frame = CGRectMake(95, 159, 142, 40);
    [exitButton setBackgroundImage:[UIImage imageNamed:@"exit.png"] forState:UIControlStateNormal];
    [exitButton addTarget:self action:@selector(exitButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *quitButton = [UIButton buttonWithType: UIButtonTypeCustom];
    quitButton.frame = CGRectMake(95, 201, 142, 40);
    [quitButton setBackgroundImage:[UIImage imageNamed:@"quit-game.png"] forState:UIControlStateNormal];
    [quitButton addTarget:self action:@selector(quitButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *frndsOnline = [[UIImageView alloc] initWithFrame:CGRectMake(95, 245, 142, 40)];
    frndsOnline.image = [UIImage imageNamed:@"friends.png"];
    
    [settingsView addSubview: settingsBg];
    [settingsView addSubview: settingsButton];
    [settingsView addSubview: volumeButton];
    [settingsView addSubview: helpButton];
    [settingsView addSubview: settings2Button];
    [settingsView addSubview: exitButton];
    [settingsView addSubview: quitButton];
    [settingsView addSubview: frndsOnline];
}


- (void) layoutCastMovieView
{
    UIImageView *castMovieBg = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"cast_bg.png"]];
    castMovieBg.frame = CGRectMake(0, 0, castMovieView.frame.size.width, castMovieView.frame.size.height);
    
    UIButton *hideCastMovieBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    hideCastMovieBtn.frame = CGRectMake(370, 10, 25, 25);
    [hideCastMovieBtn addTarget:self action:@selector(hideCastMovieBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [hideCastMovieBtn setBackgroundImage:[UIImage imageNamed:@"x.png"] forState:UIControlStateNormal];
    
    UIButton *confirmCastMovieBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmCastMovieBtn.frame = CGRectMake(300, 63, 102, 37);
    confirmCastMovieBtn.tag = 2;
    [confirmCastMovieBtn addTarget:self action:@selector(castButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [confirmCastMovieBtn setBackgroundImage:[UIImage imageNamed:@"cast_movie.png"] forState:UIControlStateNormal];
    
    movieName = [[UITextField alloc] initWithFrame: CGRectMake(22, 70, 250, 30)];
    movieName.backgroundColor = [UIColor clearColor];
    
    [castMovieView addSubview: castMovieBg];
    [castMovieView addSubview: hideCastMovieBtn];
    [castMovieView addSubview: confirmCastMovieBtn];
    [castMovieView addSubview: movieName];
}

- (void) layoutHand
{
    //emptying the hand scrollview
    for (UIView *view in [handCardListView subviews])
    {
        [view removeFromSuperview];
    }
    
    //adding images to hand
    float tempWidth = (CARD_WIDTH_PHONE * HAND_SCALE_FACTOR);
    for (int i = 0; i < [cardsInHand count]; i++)
    {
        ActorObject *temp = [cardsInHand objectAtIndex: i];
        
        UIImageView *view = temp.actorImageView;
        view.frame = CGRectMake(i * tempWidth, 0, tempWidth, CARD_HEIGHT_PHONE * HAND_SCALE_FACTOR);
        [handCardListView addSubview: view];
    }

    handCardListView.contentSize = CGSizeMake(([cardsInHand count]) * tempWidth, CARD_HEIGHT_PHONE);
    
    //emptying the reel scrollview
    for (UIView *view in [filmReelListView subviews])
    {
        NSLog(@"%.2f, %.2f", view.center.x, view.center.y);
        
        [view removeFromSuperview];
    }
    
    //adding images to reel
    
    filmReelListView.contentSize = CGSizeMake(([cardsOnReel count] + 1) * 70, CARD_HEIGHT_PHONE);
    
    int x = 0;
    for (int i = 0; i < [cardsOnReel count]; i++)
    {
        ActorObject *temp = [cardsOnReel objectAtIndex: i];
        
        UIImageView *cardBg = [[UIImageView alloc] initWithFrame:CGRectMake(x, 0, 70, 120)];
        cardBg.backgroundColor = [UIColor clearColor];
        cardBg.image = [UIImage imageNamed:@"reel_1.png"];
        
        UIImageView *cardImage = [[UIImageView alloc] initWithFrame:CGRectMake(3, 15, CARD_WIDTH_PHONE, CARD_HEIGHT_PHONE)];
        cardImage.image = temp.actorImageView.image;
        
        [cardBg addSubview:cardImage];
        [filmReelListView addSubview: cardBg];
        
        x = x + 70;
    }
    
    
    /*
     ****************************************************************************************************************************************************
     
     THE BELOW CODE WAS USED TO PLACE THE LAST REEL IMAGE WITH THE PLUS SIGN IF AND WHEN THE USERS WERE ALLOWED TO PLACE MULTIPLE CARDS IN A SINGLE TURN
     
     ****************************************************************************************************************************************************
     
    UIImageView *crossReelImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross_reel_03.png"]];
    crossReelImage.frame = CGRectMake(x, 0, 70, 120);
    [filmReelListView addSubview: crossReelImage];
    
    if ((x - 0) >= filmReelListView.frame.size.width)
    {
        [filmReelListView setContentOffset:CGPointMake(x - (70 * 3), 0) animated:YES];
    }
     */
    
    
    /*
     ****************************************************************************************************************************************************
     
     THE BELOW CODE WAS USED TO PLACE THE LAST REEL IMAGE WITH THE PLUS SIGN IF AND WHEN THE USERS WERE ALLOWED TO PLACE SINGLE CARD EVERY TURN
     
     ****************************************************************************************************************************************************
     */
    if ([cardsOnReel count] == 1)
    {
        UIImageView *crossReelImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross_reel_03.png"]];
        crossReelImage.frame = CGRectMake(x, 0, 70, 120);
        [filmReelListView addSubview: crossReelImage];
        castButton.enabled = false;
    }else
    {
        castButton.enabled = true;
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------------
}

- (void) handleDoubleTapGestures: (UITapGestureRecognizer *) sender
{
    if ([cardsOnReel count] > 1)
    {
        CGPoint doubleTapLocation = [sender locationInView:filmReelListView];
        
        NSLog(@"double tap location %.2f, %.2f", doubleTapLocation.x, doubleTapLocation.y);
        
        selectedCardNum = doubleTapLocation.x/(CARD_WIDTH_PHONE + 6);
        NSLog(@"%d", selectedCardNum);
        
        //create an array for the cards placed on the reel in this hand. the below logic is executed if
        //cardaddedtoreel is an object from that array...
        
        if(selectedCardNum < [cardsOnReel count])
        {
            cardAddedToReel = [cardsOnReel objectAtIndex:selectedCardNum];
            
            if ([cardsPlacedThisHand containsObject:cardAddedToReel])
            {
                [cardsOnReel removeObjectAtIndex:selectedCardNum];
                [cardsPlacedThisHand removeObjectAtIndex:[cardsPlacedThisHand indexOfObject:cardAddedToReel]];
                [cardsInHand addObject:cardAddedToReel];
                [self layoutHand];
            }else
            {
                UIAlertView *ignoreDoubleTap = [[UIAlertView alloc] initWithTitle:@"Only cards placed this hand can be removed!!!" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [ignoreDoubleTap show];
            }
            
            selectedCardNum = -1;
        }
    }
}

- (void) handleHandLongPressGesture: (UILongPressGestureRecognizer *) sender
{
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"gesture state began");
            
            CGPoint longPressLocation = [sender locationInView:handCardListView];
            CGPoint locationOnScreen = [sender locationInView:self.view];
            selectedCardNum = longPressLocation.x/(CARD_WIDTH_PHONE * HAND_SCALE_FACTOR);
            NSLog(@"selected card is = %d", selectedCardNum);
            if (selectedCardNum < [cardsInHand count])
            {
                cardSelectedFromHand = [cardsInHand objectAtIndex:selectedCardNum];
                
                cardSelected = [[ActorObject alloc] init];
                [cardSelected.actorName setString: cardSelectedFromHand.actorName];
                cardSelected.actorImageView.image = cardSelectedFromHand.actorImageView.image;
                cardSelected.actorImageView.frame = cardSelectedFromHand.actorImageView.frame;
                
                cardSelected.actorImageView.transform = CGAffineTransformScale(cardSelected.actorImageView.transform, 1.5, 1.5);
                cardSelected.actorImageView.center = locationOnScreen;
                cardSelected.actorImageView.center = CGPointMake(cardSelected.actorImageView.center.x, cardSelected.actorImageView.center.y - 60);
                actorNameLabel.text = cardSelected.actorName;
                //[self animateShowName];
                [self.view addSubview:cardSelected.actorImageView];
            }
            
            break;
        case UIGestureRecognizerStateCancelled:
            
            break;
        case UIGestureRecognizerStateChanged:
            if(cardSelected)
            {
                cardSelected.actorImageView.alpha = 0.7;
                cardSelected.actorImageView.center = [sender locationInView:self.view];
            }
            
            break;
        case UIGestureRecognizerStateEnded:
            
            NSLog(@"");
            CGPoint temp = [sender locationInView:filmReelListView];
                        
            if (temp.y > 0 && temp.y < 80 && temp.x > 0)
            {
                cardSelected.actorImageView.alpha = 1;
                
                ActorObject *tempObj = [[ActorObject alloc] init];                      //The card to be added on to the reel
                tempObj.actorImageView.image = cardSelected.actorImageView.image;
                [tempObj.actorName setString:cardSelected.actorName];
                
                /*
                 ********************************************************************************************************************************************
                 
                 THE BELOW CODE WAS USED TO PLACE THE LAST REEL IMAGE WITH THE PLUS SIGN IF AND WHEN THE USERS WERE ALLOWED TO PLACE MORE THAN ONE CARD EVERY TURN
                 
                 ********************************************************************************************************************************************
                
                [cardsOnReel addObject:tempObj];
                [cardsPlacedThisHand addObject:tempObj];
                [cardsInHand removeObjectAtIndex:selectedCardNum];
                
                //---------------------------------------------------------------------------------------------------------------------------------------------
                 */
                
                /*
                 *********************************************************************************************************************************************
                 
                 THE BELOW CODE CONFORMS TO THE PLAYING DIRECTIONS WHERE ONLY ONE CARD CAN BE PLAYED EACH HAND. IT REPLACES THE CARD ON THE FILM REEL WITH THE CURRENT CARD SELECTION
                 
                 *********************************************************************************************************************************************
                */
                if([cardsOnReel count] > 1)
                {
                    ActorObject *tempObj2 = [cardsOnReel objectAtIndex:([cardsOnReel count] - 1)];
                    [cardsOnReel replaceObjectAtIndex:([cardsOnReel count] - 1) withObject:tempObj];
                    [cardsPlacedThisHand replaceObjectAtIndex:([cardsPlacedThisHand count] - 1) withObject:tempObj];//Not really needed in this implementation
                    [cardsInHand addObject: tempObj2];
                }else
                {
                    [cardsOnReel addObject: tempObj];
                    [cardsPlacedThisHand addObject: tempObj];//Not really needed in this implementation
                }
                
                [cardsInHand removeObjectAtIndex: selectedCardNum];
                
                //---------------------------------------------------------------------------------------------------------------------------------------------
                
                [self layoutHand];
            }
            
            //[self performSelector:@selector(animateHideName) withObject:nil afterDelay:0.5];
            
            [cardSelected.actorImageView removeFromSuperview];
            cardSelected = NULL;
            
            break;
        case UIGestureRecognizerStateFailed:
            NSLog(@"gesture state failed");
            break;
        case UIGestureRecognizerStatePossible:
            NSLog(@"gesture state possible");
            break;
            
        default:
            break;
    }
}

- (void) handleReelLongPressGesture: (UILongPressGestureRecognizer *) sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        CGPoint longPressLocation = [sender locationInView:filmReelListView];
        CGPoint locationOnScreen = [sender locationInView:self.view];
        selectedCardNum = longPressLocation.x/(CARD_WIDTH_PHONE + 6);
        NSLog(@"the selected card = %d", selectedCardNum);
        NSLog(@"card count on reel = %d", [cardsOnReel count]);
        if(selectedCardNum < [cardsOnReel count])
        {
            ActorObject *cardSelectedOnReel = [cardsOnReel objectAtIndex:selectedCardNum];
            
            cardSelected = [[ActorObject alloc] init];
            [cardSelected.actorName setString:cardSelectedOnReel.actorName];
            cardSelected.actorImageView.image = cardSelectedOnReel.actorImageView.image;
            cardSelected.actorImageView.frame = CGRectMake(0, 0, CARD_WIDTH_PHONE, CARD_HEIGHT_PHONE);
            cardSelected.actorImageView.transform = CGAffineTransformScale(cardSelected.actorImageView.transform, 1.5, 1.5);
            cardSelected.actorImageView.center = locationOnScreen;
            cardSelected.actorImageView.center = CGPointMake(cardSelected.actorImageView.center.x, cardSelected.actorImageView.center.y - 60);
            actorNameLabel.text = cardSelected.actorName;
            //[self animateShowName];
            [self.view addSubview:cardSelected.actorImageView];
        }
    }
    
    if (sender.state == UIGestureRecognizerStateFailed || sender.state == UIGestureRecognizerStateEnded)
    {
        [cardSelected.actorImageView removeFromSuperview];
        NSLog(@"reel long press now failed");
        
        //[self performSelector:@selector(animateHideName) withObject:nil afterDelay:0.25];
        
        cardSelected = NULL;
        selectedCardNum = -1;
    }
}

- (void) castButtonClicked: (UIButton *)sender
{
    switch (sender.tag) {
        case 2: //castMovieView's button clicked
            [cardsPlacedThisHand removeAllObjects];
            
            for (int i = 0; i < [cardsOnReel count] - 1; i++)
            {
                [cardsOnReel removeObjectAtIndex: i];
            }
            
            [self layoutHand];
            
            [self hideCastMovieBtnClicked];
            
            [movieName resignFirstResponder];
            
            actorNameLabel.text = @"";
            
            break;
            
        case 1: //self view's button clicked
            [movieName becomeFirstResponder];
            
            castMovieView.hidden = false;
            [self.view bringSubviewToFront:castMovieView];
            
            break;
            
        default:
            break;
    }
}

- (void) hideCastMovieBtnClicked
{
    castMovieView.hidden = true;
    [movieName resignFirstResponder];
    [movieName setText:@""];
}

- (void) drawButtonClicked
{
    //draw button click event definition
    
}

- (void) settingsClicked
{
    [UIView beginAnimations:@"startSettingsAnimation" context:NULL];
    [UIView setAnimationDuration:0.25];
    
    if(settingsShowing)
    {
        settingsView.center = CGPointMake(settingsView.center.x + 200, settingsView.center.y);
        settingsBg.image = [UIImage imageNamed:@"bg_border_andgear.png"];
        [UIView setAnimationDelegate: self];
        [UIView setAnimationDidStopSelector:@selector(settingsHidden)];
        settingsShowing = false;
    }else
    {
        settingsView.center = CGPointMake(settingsView.center.x - 200, settingsView.center.y);
        settingsBg.image = [UIImage imageNamed:@"whole_settings_show_all.png"];
        [self.view bringSubviewToFront: settingsView];
        settingsShowing = true;
    }
    
    [UIView commitAnimations];
}

- (void) settingsHidden
{
    [self.view bringSubviewToFront: castButton];
    [self.view bringSubviewToFront: drawButton];
}

- (void) volumeButtonClicked
{
    
}

- (void) helpButtonClicked
{
    
}

- (void) settings2ButtonClicked
{
    
}

- (void) exitButtonClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) quitButtonClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) animateShowName
{
    [actorNameBg.layer removeAllAnimations];
    [UIView beginAnimations:@"startNameAnimation" context:NULL];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration:0.25];
    actorNameBg.frame = CGRectMake(0, 140, 110, 40);
    [UIView commitAnimations];
}

- (void) animateHideName
{
    [actorNameBg.layer removeAllAnimations];
    [UIView beginAnimations:@"startNameAnimation" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.25];
    actorNameBg.frame = CGRectMake(-110, 140, 110, 40);
    [UIView commitAnimations];
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

#pragma mark Table View datasource and delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [cardsInHand count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] ;
    }
    
    ActorObject *temp = [cardsInHand objectAtIndex:indexPath.row];
    
    UILabel *actorNameLbl = [[UILabel alloc] initWithFrame:CGRectMake(3, 0, 75, 30)];
    actorNameLbl.text = temp.actorName;
    //UIFont *font = [UIFont fontWithName:@"DINEngschrift-Alternate" size:8.0];
    
    actorNameLbl.font = [UIFont fontWithName:@"DINEngschrift-Alternate" size:13];
    actorNameLbl.numberOfLines = 0;
    //actorNameLbl.textAlignment = UITextAlignmentCenter;
    actorNameLbl.backgroundColor = [UIColor clearColor];
    actorNameLbl.textColor = [UIColor whiteColor];
    
    if(selectedRow == indexPath.row)
    {
        actorNameLbl.font = [UIFont fontWithName:@"DINEngschrift-Alternate" size:12];
        actorNameLbl.textColor = [UIColor yellowColor];
        selectedRow = -1;
    }
    
    UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 33)];
    bg.image = [UIImage imageNamed:@"left_nav_button_02.png"];
    
    [cell.contentView addSubview:bg];
    [cell.contentView addSubview:actorNameLbl];
    cell.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"left_nav_button_02.png"]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 33;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //card selection
    selectedRow = indexPath.row;
    
    [actorTable reloadData];
}



@end
