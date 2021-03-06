/*
 *  TypesAndConstants.m
 *  MobileOverload
 *
 *  Created by Joachim Bengtsson on 2008-08-18.
 *  Copyright 2008 Third Cog Software. All rights reserved.
 *
 */

const CGFloat ScoreBarHeight = 44;

CGFloat BoardWidth()
{
	return UIScreen.mainScreen.applicationFrame.size.width;
};
CGFloat BoardHeight()
{
    CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
    return screenFrame.size.height - ScoreBarHeight*2;
}
NSUInteger WidthInTiles()
{
    return 10;
}
NSUInteger HeightInTiles()
{
    if([UIScreen mainScreen].bounds.size.height >= 568)
        return 14;
    return 12;
}

const NSTimeInterval ExplosionDelay = 0.30;
const CGFloat ChargeEnergy = 0.25;
const NSTimeInterval ExplosionSpreadEnergy = 0.25;
const NSTimeInterval ExplosionDuration = 0.40;
const CGFloat SparkleEnergy = 0.75;
const CGFloat SparkleOpacityLow = 0.7;

float frand(float max) {
    return (rand()/((float)INT_MAX))*max;
}

const CGFloat Hues[3]        = {.6, .0, .35 };

const CGFloat Saturations[4] = {0.0, .5 , .8,  1.};