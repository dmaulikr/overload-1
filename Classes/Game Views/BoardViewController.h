//
//  BoardViewController.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-12.
//  Copyright Third Cog Software 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScoreBarView.h"
#import "TypesAndConstants.h"
#import "Board.h"
#import "BoardView.h"
#import "OLSoundPlayer.h"

@class AI;

//#define AI_VS_AI

@interface BoardViewController : UIViewController <BoardDelegate, BoardViewDelegate, ScoreBarViewDelegate> {
    ScoreBarView *score1, *score2;
    UIImageView *winPlaque, *losePlaque;
    
    OLSoundPlayer *soundPlayer;
    
    BoardView *boardView;
    Board *board;
    
    NSTimer *heartbeat;
    
    AI *ai;
#ifdef AI_VS_AI
    AI*ai2;
#endif
}

-(id)init;

#pragma mark Board delegates
-(void)tile:(Tile*)tile changedOwner:(Player)owner;
-(void)tile:(Tile*)tile changedValue:(CGFloat)value;
-(void)tile:(Tile*)tile wasChargedTo:(CGFloat)value byPlayer:(Player)player;
-(void)tileExploded:(Tile*)tile;
-(void)board:(Board*)board changedScores:(Scores)scores;
-(void)board:(Board*)board endedWithWinner:(Player)winner;
-(void)board:(Board*)board changedCurrentPlayer:(Player)currentPlayer;

#pragma mark Board view delegates
-(void)boardTileViewWasTouched:(BoardPoint)pointThatWasTouched;

#pragma mark Score bar delegates
-(void)scoreBarTouched:(ScoreBarView*)scoreBarView;

#pragma mark AI
-(void)startAI;
-(void)stopAI;

#pragma mark Properties
@property (readonly, nonatomic) Board *board;
@property (readonly, nonatomic) OLSoundPlayer *soundPlayer;
@end
