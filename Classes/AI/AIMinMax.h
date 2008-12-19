//
//  AIMinMax.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-09-08.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AI.h"
#import "Board.h"
#import "TypesAndConstants.h"

@class AIMinMax;
@interface AIMMTreeNode : NSObject
{
    BoardPoint representsMoveAt;
    AIMinMax *ai;
    Board *board;
    AIMMTreeNode *children[10][12];
    BOOL hasChildren;
    CGFloat mval;
}
-(id)initWithState:(Board*)state inAI:(AIMinMax*)ai;

-(AIMMTreeNode*)node:(BoardPoint)point;
-(AIMMTreeNode*)bestChoice;

-(NSArray*)makeChildren;
-(CGFloat)minMaxAtDepth:(NSUInteger)depth;

@property (retain) Board *board;
@property (readonly) CGFloat valueEstimate;
@property (readonly) BoardPoint representsMoveAt;

@end



@interface AIMinMax : AI {
    AIMMTreeNode *root;
}

-(id)initPlaying:(Player)player_ onBoard:(Board*)board_ delegate:(id<BoardViewDelegate>)delegate_;

-(void)player:(Player)player choseTile:(BoardPoint)boardPoint;
-(BoardPoint)chooseTile;

@property (retain) AIMMTreeNode *root;
@end