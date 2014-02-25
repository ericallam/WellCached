//
//  MasterViewController.m
//  WalkingDirections
//
//  Created by Eric Allam on 24/02/2014.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "MasterViewController.h"
#import "LocationTableViewCell.h"
#import <MapKit/MapKit.h>

#import <WellCached/ELAWellCached.h>

@interface MasterViewController ()
@property (strong, nonatomic) NSArray *locations;
@property (strong, nonatomic) ELAWellCached *cache;
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.cache = [ELAWellCached cacheWithDefaultExpiringDuration:15]; // 15 seconds
    
    NSDictionary *location1 = @{@"title": @"Queen Elizabeth's Walk", @"latitude": @(51.564975), @"longitude": @(-0.08799), @"id": @"1"};
    NSDictionary *location2 = @{@"title": @"Queen's Drive", @"latitude": @(51.56253), @"longitude": @(-0.096879), @"id": @"2"};
    NSDictionary *location3 = @{@"title": @"Green Lanes", @"latitude": @(51.564154), @"longitude": @(-0.0916899), @"id": @"3"};
    NSDictionary *location4 = @{@"title": @"Gloucester Drive", @"latitude": @(51.567729), @"longitude": @(-0.094195), @"id": @"4"};
    NSDictionary *location5 = @{@"title": @"Bouverie Road", @"latitude": @(51.562285), @"longitude": @(-0.077441), @"id": @"5"};
    
    self.locations = @[location1, location2, location3, location4, location5];
}

- (IBAction)refresh:(id)sender
{
    [self.tableView reloadData];
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.locations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LocationCell" forIndexPath:indexPath];

    NSDictionary *location = self.locations[indexPath.row];
    cell.textLabel.text = location[@"title"];
    
    NSString *key = [NSString stringWithFormat:@"location-%@-walking-time", location[@"id"]];

    [self.cache fetch:key generateOnMissAsync:^(ELAResultCallback callback) {
        // Time to generate a new walking time
        
        cell.detailTextLabel.text = @"Calculating walking time...";
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([location[@"latitude"] doubleValue], [location[@"longitude"] doubleValue]);
        
        MKDirectionsRequest *request = [MKDirectionsRequest new];
        request.transportType = MKDirectionsTransportTypeWalking;
        request.source = [MKMapItem mapItemForCurrentLocation];
        request.departureDate = [NSDate date];
        
        MKPlacemark *destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:@{}];
        request.destination = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];
        
        MKDirections *directionsRequest = [[MKDirections alloc] initWithRequest:request];
        
        // calculateDirectionsWithCompletionHandler: is even more expensive
        [directionsRequest calculateETAWithCompletionHandler:^(MKETAResponse *response, NSError *error) {
            // This block is called on the main thread
            if (error) {
                NSLog(@"Error retrieving walking time: %@", error);
                
                callback(nil); // No cached result
            }else{
                callback(@(response.expectedTravelTime)); // Set the cached result
            }
        }];
        
    } result:^(id result) {
        if (result) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Walking time: %@ seconds", result];
        }else{
            cell.detailTextLabel.text = @"Could not fetch walking time";
        }
    }];
    
    return cell;
}

@end
