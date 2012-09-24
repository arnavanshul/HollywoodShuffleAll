//
//  ActorObject.h
//  Hollywood Shuffle
//
//  Created by Daniel Gruici on 9/5/12.
//  Copyright (c) 2012 Daniel Gruici. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActorObject : NSObject
{
    NSMutableString *actorName;
    UIImageView *actorImageView;
}

@property(nonatomic, retain) NSMutableString *actorName;
@property(nonatomic, retain) UIImageView *actorImageView;

@end
