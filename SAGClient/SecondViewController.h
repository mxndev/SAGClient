//
//  SecondViewController.h
//  SAGClient
//
//  Created by Mikołaj-iMac on 20.05.2016.
//  Copyright © 2016 Mikołaj-iMac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>


@interface SecondViewController : UIViewController
{
    float krkMax, krkMin, acXMax, acXMin, acYMax, acYMin, acZMax, acZMin, gyrXMax, gyrXMin, gyrYMax, gyrYMin, gyrZMax, gyrZMin;
    NSMutableArray* listOfStates;
    NSTimer *timer;
    int timeCounter, timeOfLastMeasure;;
}
@property (strong, nonatomic) IBOutlet UILabel *accXMax;
@property (strong, nonatomic) IBOutlet UILabel *accYMax;
@property (strong, nonatomic) IBOutlet UILabel *accZMax;
@property (strong, nonatomic) IBOutlet UILabel *accXMin;
@property (strong, nonatomic) IBOutlet UILabel *accYMin;
@property (strong, nonatomic) IBOutlet UILabel *accZMin;

@property (strong, nonatomic) IBOutlet UILabel *rotXMax;
@property (strong, nonatomic) IBOutlet UILabel *rotYMax;
@property (strong, nonatomic) IBOutlet UILabel *rotZMax;
@property (strong, nonatomic) IBOutlet UILabel *rotXMin;
@property (strong, nonatomic) IBOutlet UILabel *rotYMin;
@property (strong, nonatomic) IBOutlet UILabel *rotZMin;

@property (strong, nonatomic) IBOutlet UILabel *paceMax;
@property (strong, nonatomic) IBOutlet UILabel *paceMin;

@property (strong, nonatomic) IBOutlet UILabel *aktywnosc;
@property (strong, nonatomic) IBOutlet UILabel *counterLabel;
@property (strong, nonatomic) IBOutlet UILabel *counterInfo;

@property (strong, nonatomic) IBOutlet UIButton *synchronize;
@property (strong, nonatomic) IBOutlet UIButton *start;
@property (strong, nonatomic) IBOutlet UIButton *stop;
@property (strong, nonatomic) IBOutlet UIButton *reset;

@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) CMPedometer *pedometer;

-(IBAction)syncData:(id)sender;
-(IBAction)startCollect:(id)sender;
-(IBAction)stopCollect:(id)sender;
-(IBAction)resetCollect:(id)sender;

-(void)outputAccelertionData:(CMAcceleration)acceleration;
-(void)outputRotationData:(CMRotationRate)gyroscope;
-(void)updatePace:(CMPedometerData *)pedometerData;
@end

@interface CLearningObject : NSObject
{
    int activity; // 0 - stanie, 1 - leżenie, 2 - chodzenie 3 - bieganie
    float krokomierzMax, krokomierzMin;
    float accXMax, accXMin, accYMax, accYMin, accZMax, accZMin;
    float gyrXMax, gyrXMin, gyrYMax, gyrYMin, gyrZMax, gyrZMin;
    float value;
}
@property float krokomierzMax, krokomierzMin, accXMax, accXMin, accYMax, accYMin, accZMax, accZMin, gyrXMax, gyrXMin, gyrYMax, gyrYMin, gyrZMax, gyrZMin;
@property int activity;
-(void) countForResult:(float)krkMax :(float)krkMin :(float)aXMax :(float)aXMin :(float)aYMax :(float)aYMin :(float)aZMax :(float)aZMin :(float)gXMax :(float)gXMin :(float)gYMax :(float)gYMin :(float)gZMax :(float)gZMin;

-(float) coutValue:(float)krkMax :(float)krkMin :(float)valueResult :(float)krkOrMax :(float)krkOrMin;

@end