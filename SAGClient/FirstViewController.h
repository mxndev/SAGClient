//
//  FirstViewController.h
//  SAGClient
//
//  Created by Mikołaj-iMac on 20.05.2016.
//  Copyright © 2016 Mikołaj-iMac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface FirstViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
{
    NSArray* opcje;
    NSString * selectOpcja;
    NSTimer *timer;
    int timeCounter;
    float krkMax, krkMin, acXMax, acXMin, acYMax, acYMin, acZMax, acZMin, gyrXMax, gyrXMin, gyrYMax, gyrYMin, gyrZMax, gyrZMin;
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

@property (strong, nonatomic) IBOutlet UILabel *counterLabel;
@property (strong, nonatomic) IBOutlet UILabel *counterInfo;

@property (weak, nonatomic) IBOutlet UIPickerView *picker;

@property (strong, nonatomic) IBOutlet UIButton *start;
@property (strong, nonatomic) IBOutlet UIButton *stop;
@property (strong, nonatomic) IBOutlet UIButton *reset;

@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) CMPedometer *pedometer;

-(IBAction)startCollect:(id)sender;
-(IBAction)stopCollect:(id)sender;
-(IBAction)resetCollect:(id)sender;

-(void)outputAccelertionData:(CMAcceleration)acceleration;
-(void)outputRotationData:(CMRotationRate)gyroscope;
-(void)updatePace:(CMPedometerData *)pedometerData;
@end