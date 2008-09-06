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

@interface BoardViewController : UIViewController <BoardDelegate, BoardViewDelegate> {
    ScoreBarView *score1, *score2;
    BoardView *boardView;
    UIImageView *winPlaque, *losePlaque;
    
    Board *board;
}


#pragma mark Board delegates
-(void)tile:(Tile*)tile changedOwner:(Player)owner value:(CGFloat)value;
-(void)tileExploded:(Tile*)tile;
-(void)board:(Board*)board changedScores:(CGFloat[])scores;
-(void)board:(Board*)board endedWithWinner:(Player)winner;
-(void)board:(Board*)board changedCurrentPlayer:(Player)currentPlayer;

#pragma mark Board view delegates
-(void)boardTileViewWasTouched:(BoardTileView*)boardTileView;

#pragma mark Properties
@property (readonly) Board *board;
@end