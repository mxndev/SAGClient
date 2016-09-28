//
//  FirstViewController.m
//  SAGClient
//
//  Created by Mikołaj-iMac on 20.05.2016.
//  Copyright © 2016 Mikołaj-iMac. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

@synthesize picker,start, stop, reset;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = .2;
    self.pedometer = [[CMPedometer alloc] init];
    
    opcje = [[NSArray alloc] initWithObjects:@"Stanie", @"Lezenie", @"Bieganie", @"Chodzenie", nil];
    selectOpcja = @"Stanie";
    [picker selectRow:0 inComponent:0 animated:NO];
    
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
    [stop setEnabled:NO];
    [reset setEnabled:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectOpcja = [opcje objectAtIndex:row];
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    return [opcje count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    return [opcje objectAtIndex:row];
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
    [picker setUserInteractionEnabled:NO];
    [picker setAlpha:.6];
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
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];

    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSURL *url = [NSURL URLWithString:@"http://sag-mpajaczkowski.rhcloud.com/SAG-0.0.1-SNAPSHOT/nauczanie"];
    
    NSString *jsonRequest = [NSString stringWithFormat:@"{\"krokMin\":\"%f\",\"krokMax\":\"%f\",\"zyrXMin\":\"%f\",\"zyrXMax\":\"%f\",\"zyrYMin\":\"%f\",\"zyrYMax\":\"%f\",\"zyrZMin\":\"%f\",\"zyrZMax\":\"%f\",\"akcXMin\":\"%f\",\"akcXMax\":\"%f\",\"akcYMin\":\"%f\",\"akcYMax\":\"%f\",\"akcZMin\":\"%f\",\"akcZMax\":\"%f\",\"stan\":\"%@\"}",krkMin,krkMax,gyrXMin,gyrXMax,gyrYMin,gyrYMax,gyrZMin,gyrZMax,acXMin,acXMax,acYMin,acYMax,acZMin,acZMax,selectOpcja];

    NSData *requestData = [NSData dataWithBytes:[jsonRequest UTF8String] length:[jsonRequest length]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: requestData];
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
    }];
    [postDataTask resume];

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
    [stop setEnabled:NO];
    [reset setEnabled:NO];
    [start setEnabled:YES];
    [picker setUserInteractionEnabled:YES];
    [picker setAlpha:1.0];
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
    [stop setEnabled:NO];
    [reset setEnabled:NO];
    [start setEnabled:YES];
    [picker setUserInteractionEnabled:YES];
    [picker setAlpha:1.0];
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
