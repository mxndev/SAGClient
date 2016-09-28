//
//  SecondViewController.m
//  SAGClient
//
//  Created by Mikołaj-iMac on 20.05.2016.
//  Copyright © 2016 Mikołaj-iMac. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

@synthesize synchronize, start, stop, reset;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = .2;
    self.pedometer = [[CMPedometer alloc] init];
    
    krkMax = 0.0f;
    krkMin = 0.0f;
    
    acXMax = 0.0f;
    acXMin = 0.0f;
    acYMax = 0.0f;
    acYMin = 0.0f;
    acZMax = 0.0f;
    acZMin = 0.0f;
    
    gyrXMax = 0.0f;
    gyrXMin = 0.0f;
    gyrYMax = 0.0f;
    gyrYMin = 0.0f;
    gyrZMax = 0.0f;
    gyrZMin = 0.0f;
    
    
    listOfStates = [[NSMutableArray alloc] init];
    [start setEnabled:NO];
    [stop setEnabled:NO];
    [reset setEnabled:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)syncData:(id)sender
{
    [listOfStates removeAllObjects];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:@"http://sag-mpajaczkowski.rhcloud.com/SAG-0.0.1-SNAPSHOT/dajzakresy"]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                if (data.length > 0 && error == nil)
                {
                    NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data
                                                                             options:0
                                                                               error:NULL];
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        
                        for (NSDictionary *groupDic in dataDict) {
                            CLearningObject *learingObject = [[CLearningObject alloc] init];
                            if([[groupDic objectForKey:@"stan"] isEqualToString:@"Stanie"])
                            {
                                learingObject.activity = 0;
                            } else if([[groupDic objectForKey:@"stan"] isEqualToString:@"Lezenie"]) {
                                learingObject.activity = 1;
                            } else if([[groupDic objectForKey:@"stan"] isEqualToString:@"Chodzenie"]) {
                                learingObject.activity = 2;
                            } else if([[groupDic objectForKey:@"stan"] isEqualToString:@"Bieganie"]) {
                                learingObject.activity = 3;
                            }
                            
                            //akcelometr
                            learingObject.accXMax = [[[groupDic objectForKey:@"wartosc"] objectForKey:@"akcelometrXMax"] floatValue];
                            learingObject.accYMax = [[[groupDic objectForKey:@"wartosc"] objectForKey:@"akcelometrYMax"] floatValue];
                            learingObject.accZMax = [[[groupDic objectForKey:@"wartosc"] objectForKey:@"akcelometrZMax"] floatValue];
                            learingObject.accXMin = [[[groupDic objectForKey:@"wartosc"] objectForKey:@"akcelometrXMin"] floatValue];
                            learingObject.accYMin = [[[groupDic objectForKey:@"wartosc"] objectForKey:@"akcelometrYMin"] floatValue];
                            learingObject.accZMin = [[[groupDic objectForKey:@"wartosc"] objectForKey:@"akcelometrZMin"] floatValue];
                            
                            //żyroskop
                            learingObject.gyrXMax = [[[groupDic objectForKey:@"wartosc"] objectForKey:@"zyroskopXMax"] floatValue];
                            learingObject.gyrYMax = [[[groupDic objectForKey:@"wartosc"] objectForKey:@"zyroskopYMax"] floatValue];
                            learingObject.gyrZMax = [[[groupDic objectForKey:@"wartosc"] objectForKey:@"zyroskopZMax"] floatValue];
                            learingObject.gyrXMin = [[[groupDic objectForKey:@"wartosc"] objectForKey:@"zyroskopXMin"] floatValue];
                            learingObject.gyrYMin = [[[groupDic objectForKey:@"wartosc"] objectForKey:@"zyroskopYMin"] floatValue];
                            learingObject.gyrZMin = [[[groupDic objectForKey:@"wartosc"] objectForKey:@"zyroskopZMin"] floatValue];
                            
                            //krokomierz
                            learingObject.krokomierzMin = [[[groupDic objectForKey:@"wartosc"] objectForKey:@"krokMin"] floatValue];
                            learingObject.krokomierzMax = [[[groupDic objectForKey:@"wartosc"] objectForKey:@"krokMax"] floatValue];
                            
                            [listOfStates addObject:learingObject];
                        }
                    }];
                }
                
            }] resume];
    [start setEnabled:YES];
}

-(IBAction)startCollect:(id)sender
{
    timeCounter = 1;
    self.counterLabel.text = [NSString stringWithFormat:@"Dane są zbierane przez %i sekund.",timeCounter];
    self.counterInfo.text = @"Minimalny okres zbierania danych to 120 sekund.";
    timer = [NSTimer scheduledTimerWithTimeInterval: 1
                                             target: self
                                           selector: @selector(clockTimer:)
                                           userInfo: nil
                                            repeats: YES];
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {[self outputAccelertionData:accelerometerData.acceleration];}];
    
    [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMGyroData *gyroData, NSError *error) { [self outputRotationData:gyroData.rotationRate];
    }];
    
    [self.pedometer startPedometerUpdatesFromDate:[NSDate date] withHandler:^(CMPedometerData * _Nullable pedometerData, NSError * _Nullable error) {[self updatePace:pedometerData];}];
    
    [start setEnabled:NO];
    [synchronize setEnabled:NO];
    [reset setEnabled:YES];
}

-(void) clockTimer:(NSTimer*)timer{
    //do your action
    ++timeCounter;
    self.counterLabel.text = [NSString stringWithFormat:@"Dane są zbierane przez %i sekund.",timeCounter];
    self.counterInfo.text = @"Minimalny okres zbierania danych to 120 sekund.";
    if(timeCounter >=120)
    {
        [stop setEnabled:YES];
    }
}

-(IBAction)stopCollect:(id)sender
{
    for (CLearningObject *learning in listOfStates)
    {
        [learning countForResult:krkMax :krkMin :acXMax :acXMin :acYMax :acYMin :acZMax :acZMin :gyrXMax :gyrXMin :gyrYMax :gyrYMin :gyrZMax :gyrZMin];
    }
    
    NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"value" ascending:NO];
    NSArray *sortedArray = [listOfStates sortedArrayUsingDescriptors:[NSMutableArray arrayWithObject:sd]];
    if([sortedArray[0] activity] == 0)
    {
        self.aktywnosc.text = @"Stanie";
    } else if([sortedArray[0] activity] == 1) {
        self.aktywnosc.text = @"Lezenie";
    } else if([sortedArray[0] activity] == 2) {
        self.aktywnosc.text = @"Chodzenie";
    } else if([sortedArray[0] activity] == 3) {
        self.aktywnosc.text = @"Bieganie";
    }
    
    [timer invalidate];
    [self.motionManager stopAccelerometerUpdates];
    [self.motionManager stopGyroUpdates];
    [self.pedometer stopPedometerUpdates];
    
    krkMax = 0.0f;
    krkMin = 0.0f;
    self.paceMin.text = [NSString stringWithFormat:@" %.2f",krkMin];
    self.paceMax.text = [NSString stringWithFormat:@" %.2f",krkMax];
    
    acXMax = 0.0f;
    acXMin = 0.0f;
    acYMax = 0.0f;
    acYMin = 0.0f;
    acZMax = 0.0f;
    acZMin = 0.0f;
    self.accXMin.text = [NSString stringWithFormat:@" %.2f",acXMin];
    self.accXMax.text = [NSString stringWithFormat:@" %.2f",acXMax];
    self.accYMin.text = [NSString stringWithFormat:@" %.2f",acYMin];
    self.accYMax.text = [NSString stringWithFormat:@" %.2f",acYMax];
    self.accZMin.text = [NSString stringWithFormat:@" %.2f",acZMin];
    self.accZMax.text = [NSString stringWithFormat:@" %.2f",acZMax];

    
    gyrXMax = 0.0f;
    gyrXMin = 0.0f;
    gyrYMax = 0.0f;
    gyrYMin = 0.0f;
    gyrZMax = 0.0f;
    gyrZMin = 0.0f;
    self.rotXMin.text = [NSString stringWithFormat:@" %.2f",gyrXMin];
    self.rotXMax.text = [NSString stringWithFormat:@" %.2f",gyrXMax];
    self.rotYMin.text = [NSString stringWithFormat:@" %.2f",gyrYMin];
    self.rotYMax.text = [NSString stringWithFormat:@" %.2f",gyrYMax];
    self.rotZMin.text = [NSString stringWithFormat:@" %.2f",gyrZMin];
    self.rotZMax.text = [NSString stringWithFormat:@" %.2f",gyrZMax];
    
    self.counterLabel.text = @"";
    self.counterInfo.text = @"";
    timeOfLastMeasure = 0;
    [stop setEnabled:NO];
    [reset setEnabled:NO];
    [start setEnabled:YES];
    [synchronize setEnabled:YES];
}

-(IBAction)resetCollect:(id)sender
{
    [timer invalidate];
    [self.motionManager stopAccelerometerUpdates];
    [self.motionManager stopGyroUpdates];
    [self.pedometer stopPedometerUpdates];
    
    krkMax = 0.0f;
    krkMin = 0.0f;
    self.paceMin.text = [NSString stringWithFormat:@" %.2f",krkMin];
    self.paceMax.text = [NSString stringWithFormat:@" %.2f",krkMax];
    
    acXMax = 0.0f;
    acXMin = 0.0f;
    acYMax = 0.0f;
    acYMin = 0.0f;
    acZMax = 0.0f;
    acZMin = 0.0f;
    self.accXMin.text = [NSString stringWithFormat:@" %.2f",acXMin];
    self.accXMax.text = [NSString stringWithFormat:@" %.2f",acXMax];
    self.accYMin.text = [NSString stringWithFormat:@" %.2f",acYMin];
    self.accYMax.text = [NSString stringWithFormat:@" %.2f",acYMax];
    self.accZMin.text = [NSString stringWithFormat:@" %.2f",acZMin];
    self.accZMax.text = [NSString stringWithFormat:@" %.2f",acZMax];
    
    
    gyrXMax = 0.0f;
    gyrXMin = 0.0f;
    gyrYMax = 0.0f;
    gyrYMin = 0.0f;
    gyrZMax = 0.0f;
    gyrZMin = 0.0f;
    self.rotXMin.text = [NSString stringWithFormat:@" %.2f",gyrXMin];
    self.rotXMax.text = [NSString stringWithFormat:@" %.2f",gyrXMax];
    self.rotYMin.text = [NSString stringWithFormat:@" %.2f",gyrYMin];
    self.rotYMax.text = [NSString stringWithFormat:@" %.2f",gyrYMax];
    self.rotZMin.text = [NSString stringWithFormat:@" %.2f",gyrZMin];
    self.rotZMax.text = [NSString stringWithFormat:@" %.2f",gyrZMax];
    
    self.counterLabel.text = @"";
    self.counterInfo.text = @"";
    timeOfLastMeasure = 0;
    [stop setEnabled:NO];
    [reset setEnabled:NO];
    [start setEnabled:YES];
    [synchronize setEnabled:YES];
}

-(void)outputAccelertionData:(CMAcceleration)acceleration
{
    // wartość x
    if((acXMin == 0.0f) && (acXMax == 0.0f))
    {
        acXMin = acceleration.x;
        self.accXMin.text = [NSString stringWithFormat:@" %.2f",acceleration.x];
        acXMax = acceleration.x;
        self.accXMax.text = [NSString stringWithFormat:@" %.2f",acceleration.x];
    } else if(acceleration.x < acXMin) {
        acXMin = acceleration.x;
        self.accXMin.text = [NSString stringWithFormat:@" %.2f",acceleration.x];
    } else if(acceleration.x > acXMax) {
        acXMax = acceleration.x;
        self.accXMax.text = [NSString stringWithFormat:@" %.2f",acceleration.x];
    }
    
    // wartość y
    if((acYMin == 0.0f) && (acYMax == 0.0f))
    {
        acYMin = acceleration.y;
        self.accYMin.text = [NSString stringWithFormat:@" %.2f",acceleration.y];
        acYMax = acceleration.y;
        self.accYMax.text = [NSString stringWithFormat:@" %.2f",acceleration.y];
    } else if(acceleration.y < acYMin) {
        acYMin = acceleration.y;
        self.accYMin.text = [NSString stringWithFormat:@" %.2f",acceleration.y];
    } else if(acceleration.y > acYMax) {
        acYMax = acceleration.y;
        self.accYMax.text = [NSString stringWithFormat:@" %.2f",acceleration.y];
    }
    
    // wartość z
    if((acZMin == 0.0f) && (acZMax == 0.0f))
    {
        acZMin = acceleration.z;
        self.accZMin.text = [NSString stringWithFormat:@" %.2f",acceleration.z];
        acZMax = acceleration.z;
        self.accZMax.text = [NSString stringWithFormat:@" %.2f",acceleration.z];
    } else if(acceleration.z < acZMin) {
        acZMin = acceleration.z;
        self.accZMin.text = [NSString stringWithFormat:@" %.2f",acceleration.z];
    } else if(acceleration.z > acZMax) {
        acZMax = acceleration.z;
        self.accZMax.text = [NSString stringWithFormat:@" %.2f",acceleration.z];
    }
}

-(void)outputRotationData:(CMRotationRate)gyroscope
{
    // wartość x
    if((gyrXMin == 0.0f) && (gyrXMax == 0.0f))
    {
        gyrXMin = gyroscope.x;
        self.rotXMin.text = [NSString stringWithFormat:@" %.2f",gyroscope.x];
        gyrXMax = gyroscope.x;
        self.rotXMax.text = [NSString stringWithFormat:@" %.2f",gyroscope.x];
    } else if(gyroscope.x < gyrXMin) {
        gyrXMin = gyroscope.x;
        self.rotXMin.text = [NSString stringWithFormat:@" %.2f",gyroscope.x];
    } else if(gyroscope.x > gyrXMax) {
        gyrXMax = gyroscope.x;
        self.rotXMax.text = [NSString stringWithFormat:@" %.2f",gyroscope.x];
    }
    
    // wartość y
    if((gyrYMin == 0.0f) && (gyrYMax == 0.0f))
    {
        gyrYMin = gyroscope.y;
        self.rotYMin.text = [NSString stringWithFormat:@" %.2f",gyroscope.y];
        gyrYMax = gyroscope.y;
        self.rotYMax.text = [NSString stringWithFormat:@" %.2f",gyroscope.y];
    } else if(gyroscope.y < gyrYMin) {
        gyrYMin = gyroscope.y;
        self.rotYMin.text = [NSString stringWithFormat:@" %.2f",gyroscope.y];
    } else if(gyroscope.y > gyrYMax) {
        gyrYMax = gyroscope.y;
        self.rotYMax.text = [NSString stringWithFormat:@" %.2f",gyroscope.y];
    }
    
    // wartość z
    if((gyrZMin == 0.0f) && (acZMax == 0.0f))
    {
        gyrZMin = gyroscope.z;
        self.rotZMin.text = [NSString stringWithFormat:@" %.2f",gyroscope.z];
        gyrZMax = gyroscope.z;
        self.rotZMax.text = [NSString stringWithFormat:@" %.2f",gyroscope.z];
    } else if(gyroscope.z < gyrZMin) {
        gyrZMin = gyroscope.z;
        self.rotZMin.text = [NSString stringWithFormat:@" %.2f",gyroscope.z];
    } else if(gyroscope.z > gyrZMax) {
        gyrZMax = gyroscope.z;
        self.rotZMax.text = [NSString stringWithFormat:@" %.2f",gyroscope.z];
    }
}

-(void)updatePace:(CMPedometerData *)pedometerData
{
    if ([CMPedometer isPaceAvailable]) {
        float pace = ([pedometerData.numberOfSteps floatValue])/timeCounter;
        if((krkMin == 0.0f) && (krkMax == 0.0f))
        {
            krkMin = pace;
            self.paceMin.text = [NSString stringWithFormat:@" %.2f",pace];
            krkMax = pace;
            self.paceMax.text = [NSString stringWithFormat:@" %.2f",pace];
        } else if(pace < krkMin) {
            krkMin = pace;
            self.paceMin.text = [NSString stringWithFormat:@" %.2f",pace];
        } else if(pace > krkMax) {
            krkMax = pace;
            self.paceMax.text = [NSString stringWithFormat:@" %.2f",pace];
        }
    } else {
        self.paceMin.text = @"brak";
        self.paceMax.text = @"brak";
    }
}

@end

@implementation CLearningObject

@synthesize krokomierzMax, krokomierzMin, accXMax, accXMin, accYMax, accYMin, accZMax, accZMin, gyrXMax, gyrXMin, gyrYMax, gyrYMin, gyrZMax, gyrZMin, activity;

-(void) countForResult:(float)krkMax :(float)krkMin :(float)aXMax :(float)aXMin :(float)aYMax :(float)aYMin :(float)aZMax :(float)aZMin :(float)gXMax :(float)gXMin :(float)gYMax :(float)gYMin :(float)gZMax :(float)gZMin
{
    value = 0.0f;
    //wylicz krokomierz
    value += [self coutValue : krkMax : krkMin : 100.0f : krokomierzMax : krokomierzMin];
    
    //wylicz akcelometr
    value += [self coutValue : aXMax : aXMin : 30.0f : accXMax : accXMin];
    value += [self coutValue : aYMax : aYMin : 30.0f : accYMax : accYMin];
    value += [self coutValue : aZMax : aZMin : 30.0f : accZMax : accZMin];
    
    //wylicz żyroskop
    value += [self coutValue : gXMax : gXMin : 10.0f : gyrXMax : gyrXMin];
    value += [self coutValue : gYMax : gYMin : 10.0f : gyrYMax : gyrYMin];
    value += [self coutValue : gZMax : gZMin : 10.0f : gyrZMax : gyrZMin];
}

-(float) coutValue:(float)krkMax :(float)krkMin :(float)valueResult :(float)krkOrMax :(float)krkOrMin;
{
    if((krkMax <= krkOrMax) && (krkMin >= krkOrMin))
    {
        return valueResult;
    } else if((krkMax <= krkOrMax) && (krkMin <= krkOrMin) && (krkMax > krkOrMin)) {
        return (((krkMax - krkOrMin)*valueResult)/(krkMax - krkMin));
    }  else if((krkMax >= krkOrMax) && (krkMin >= krkOrMin) && (krkMin < krkOrMax)) {
        return (((krkOrMax - krkMin)*valueResult)/(krkMax - krkMin));
    } else if((krkMax >= krkOrMax) && (krkMin <= krkOrMin)) {
        return (((krkOrMax - krkOrMin)*valueResult)/(krkMax - krkMin));
    } else {
        return 0;
    }
}

@end