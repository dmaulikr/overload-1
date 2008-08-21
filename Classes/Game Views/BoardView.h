//
//  BoardView.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-18.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoardTile.h"

#import "TypesAndConstants.h"

extern NSTimeInterval BoardAnimationOccurredAt;
@class MainViewController;
@interface BoardView : UIView {
    BoardTile *boardTiles[10][12]; // [x][y]
    Player currentPlayer;
    MainViewController *controller;
    NSTimer *winningConditionTimer;
    NSTimer *sparkleTimer;
    BOOL gameEnded;
    
    BOOL chaosGame;
    BOOL tinyGame;
    
    BOOL sparkling;
    
    CGSize tileSize;
    BoardSize sizeInTiles;
}
- (id)initWithFrame:(CGRect)frame controller:(MainViewController*)controller_;

-(BoardTile*)tile:(BoardPoint)point;

-(void)currentPlayerPerformCharge:(CGFloat)amount at:(BoardPoint)point;

@property Player currentPlayer;

-(void)updateScores;
-(void)scheduleWinningConditionCheck;
-(void)checkWinningCondition:(NSTimer*)sender;

-(void)shuffle;

-(BOOL)isBoardEmpty;
-(BOOL)hasGameEnded;
@property BOOL chaosGame;
@property BOOL tinyGame;
@property BOOL sparkling; // for turning of sparkling when the game is inactive

@property (readonly) CGSize tileSize;
@property (readonly) BoardSize sizeInTiles;

@property BoardStruct boardStruct;

@end
