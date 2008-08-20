//
//  BoardTile.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-17.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import "BoardTile.h"
#import <QuartzCore/QuartzCore.h>
#import "BoardView.h"


@interface BoardTile()
-(void)updateColor;
-(void)_backgroundExplode;
@end

@implementation BoardTile

- (id)initWithFrame:(CGRect)frame {
	if (![super initWithFrame:frame])
        return nil;
    
    [self updateColor];
    
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
{
    [self.board currentPlayerPerformCharge:ChargeEnergy at:self.boardPosition];
}

-(void)updateColor;
{
    [UIView beginAnimations:@"Tile color" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    CGFloat brightness = 0.25+(1.0-self.value)*0.75;
    CGFloat saturation = 0.6;
    if(self.owner == PlayerNone) {
        saturation = 0.3;
    }
    if(self.value >= SparkleEnergy) {
        //self.transform = CGAffineTransformMakeScale(0.8, 0.8);
        [self sparkle2];
    } else {
        self.transform = CGAffineTransformIdentity;
        self.layer.opacity = 1.0;
    }

    self.backgroundColor = [UIColor colorWithHue:Hues[self.owner] saturation:saturation brightness:brightness alpha:1.0];
    [UIView commitAnimations];
}
-(void)sparkle;
{
    //[UIView beginAnimations:@"sparkle" context:nil];
    if(self.value >= SparkleEnergy)
        [self performSelector:@selector(sparkle) withObject:nil afterDelay:0.1];
        //[UIView setAnimationDidStopSelector:@selector(sparkle)];
    
    self.transform = CGAffineTransformMakeTranslation(frand(2.)-1., frand(2.)-1.);
    
}
-(void)sparkle2;
{
    [UIView beginAnimations:@"sparkle" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDelay:0.2];
    if(self.value >= SparkleEnergy)
        [UIView setAnimationDidStopSelector:@selector(sparkle2)];
    
    if(self.layer.opacity == 1.) {
        self.layer.opacity = .9;
    } else {
        self.layer.opacity = 1.;
    }
    
    [UIView commitAnimations];    
}


- (void)dealloc {
	[super dealloc];
}

@synthesize owner;
-(void)setOwner:(Player)owner_;
{
    owner = owner_;
    [self updateColor];
}
-(void)setOwner_:(NSNumber*)owner_;
{
    self.owner = [owner_ intValue];
    [board updateScores];
}
@synthesize value;
-(void)setValue:(CGFloat)newValue;
{
    value = newValue;
    [self updateColor];
    [board updateScores];
}
-(void)setValue_:(NSNumber*)newValue;
{
    self.value = [newValue floatValue];
}
@synthesize boardPosition;
@synthesize board;

-(void)charge:(CGFloat)amount;
{
    self.value += amount;
    if(self.value >= 0.9999)
        [self explode];
}
-(void)charge:(CGFloat)amount forPlayer:(Player)newOwner;
{
    self.owner = newOwner;
    [self charge:amount];
}
-(void)explode;
{
    [UIView beginAnimations:@"Explosion" context:nil];
    //[UIView setAnimationDuration:1.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    // Actions for self
    self.value = 0.0;
    
    // Actions for explosion
    BoardTile *animationTile = [[[BoardTile alloc] initWithFrame:self.frame] autorelease];
    animationTile.owner = self.owner;
    animationTile.value = self.value;
    [self.superview addSubview:animationTile];
    animationTile.transform = CGAffineTransformMakeScale(4, 4);
    animationTile.layer.opacity = 0.0;
    [UIView setAnimationDelegate:animationTile];
    [UIView setAnimationDidStopSelector:@selector(_resetExplosionAnimation::)];
    [UIView commitAnimations];
    
     //[self performSelector:@selector(_backgroundExplode) onThread:self.board.explosionThread withObject:nil waitUntilDone:NO];
    [self _backgroundExplode];
}
-(void)_backgroundExplode; {
    
    BoardTile *targets[] = {[self.board tile:BoardPointMake(self.boardPosition.x, self.boardPosition.y-1)],
                            [self.board tile:BoardPointMake(self.boardPosition.x+1, self.boardPosition.y)],
                            [self.board tile:BoardPointMake(self.boardPosition.x, self.boardPosition.y+1)],
                            [self.board tile:BoardPointMake(self.boardPosition.x-1, self.boardPosition.y)]};
    
    [NSTimer scheduledTimerWithTimeInterval:ExplosionDelay*1 target:targets[0] selector:@selector(_explosionCharge:) userInfo:self repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:ExplosionDelay*2 target:targets[1] selector:@selector(_explosionCharge:) userInfo:self repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:ExplosionDelay*3 target:targets[2] selector:@selector(_explosionCharge:) userInfo:self repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:ExplosionDelay*4 target:targets[3] selector:@selector(_explosionCharge:) userInfo:self repeats:NO];
}

-(void)_resetExplosionAnimation:(id)_:(id)__
{
    [self removeFromSuperview];
}
-(void)_explosionCharge:(NSTimer*)caller;
{
    if(board.isBoardEmpty) return; // new game has started, stop it ffs
    [self charge:ExplosionSpreadEnergy forPlayer:[(BoardTile*)[caller userInfo] owner]];
    BoardAnimationOccurredAt = [NSDate timeIntervalSinceReferenceDate];
}
@end
