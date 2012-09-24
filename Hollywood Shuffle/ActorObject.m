//
//  ActorObject.m
//  Hollywood Shuffle
//
//  Created by Daniel Gruici on 9/5/12.
//  Copyright (c) 2012 Daniel Gruici. All rights reserved.
//

#import "ActorObject.h"

@implementation ActorObject
@synthesize actorName, actorImageView;

-(id) init
{
    self = [super init];
    
    if (self)
    {
        actorName = [[NSMutableString alloc] init];
        actorImageView = [[UIImageView alloc] init];
    }
    
    return self;
}


@end
