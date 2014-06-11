//
//  GTViewController.m
//  ArrestPlotter
//
//  Created by Tim McHale on 6/9/14.
//  Copyright (c) 2014 Gramercy Consultants. All rights reserved.
//

#import "GTViewController.h"
#import "ASIHTTPRequest.h"
#define METERS_PER_MILE 1609.344
@interface GTViewController ()

@end

@implementation GTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    // 1
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 39.281516;
    zoomLocation.longitude= -76.580806;
    
    // 2
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    
    // 3
    [_mapView setRegion:viewRegion animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refreshTapped:(id)sender {
    // 1
    MKCoordinateRegion mapRegion = [_mapView region];
    CLLocationCoordinate2D centerLocation = mapRegion.center;
    
    // 2
    NSString *jsonFile = [[NSBundle mainBundle] pathForResource:@"command" ofType:@"json"];
    NSString *formatString = [NSString stringWithContentsOfFile:jsonFile encoding:NSUTF8StringEncoding error:nil];

   NSString *json = [NSString stringWithFormat:formatString,
                      centerLocation.latitude, centerLocation.longitude, 0.5*METERS_PER_MILE];
   // NSLog(@"json = %@", json);

    // 3
    NSURL *url = [NSURL URLWithString:@"http://data.baltimorecity.gov/api/views/INLINE/rows.json?method=index"];
    
    // 4
    ASIHTTPRequest *_request = [ASIHTTPRequest requestWithURL:url];
    NSLog(@"_request = %@", [ASIHTTPRequest requestWithURL:url]);
    __weak ASIHTTPRequest *request = _request;

    request.requestMethod = @"POST";
    NSLog(@"_request = %@", request.requestMethod);

    [request addRequestHeader:@"Content-Type" value:@"application/json"];

    [request appendPostData:[json dataUsingEncoding:NSUTF8StringEncoding]];
    
    // 5
    [request setDelegate:self];
    [request setCompletionBlock:^{
        NSString *responseString = [request responseString];
        NSLog(@"Response: %@", responseString);
    }];
   
    // RIGHT HERE WE HAVE A FAILED REQUEST. WHY?
    // What is NSError and error.localizedDescription?
    // The answer is the key to the next step
    
    [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"Error: %@", error.localizedDescription);
        
    }];
    
    // 6
    [request startAsynchronous];
    
    
    
}
@end
