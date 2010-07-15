    //
//  MVLCMovieListViewController.m
//  MobileVLC
//
//  Created by Romain Goyet on 12/07/10.
//  Copyright 2010 Applidium. All rights reserved.
//

#import "MVLCMovieListViewController.h"
#import "MVLCMovieViewController.h"
#import "MVLCMovieGridViewCell.h"
#import <CoreData/CoreData.h>
#import "MLMediaLibrary.h"
#import "UIImageView+WebCache.h"

@implementation MVLCMovieListViewController
@synthesize gridView=_gridView;
- (void)viewDidLoad {
    [super viewDidLoad];
	self.gridView.indicatorStyle = UIScrollViewIndicatorStyleWhite;

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *moc = [[MLMediaLibrary sharedMediaLibrary] managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"File" inManagedObjectContext:moc];
    [request setEntity:entity];

    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:descriptor]];

    [request setPredicate:[NSPredicate predicateWithFormat:@"type == %@", @"movie"]];

    NSArray *movies = [moc executeFetchRequest:request error:nil];
	[request release];

    _allMedia = [movies retain];
	[self.gridView reloadData];
}

- (void)dealloc {
	[_allMedia release];
	[_gridView release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES; // We support all 4 possible orientations
}

#pragma mark -
#pragma mark AQGridViewDataSource
- (NSUInteger)numberOfItemsInGridView:(AQGridView *)gridView {
	return [_allMedia count];
}

- (AQGridViewCell *)gridView:(AQGridView *)gridView cellForItemAtIndex:(NSUInteger)index {
	static NSString * MVLCMovieListGridCellIdentifier = @"MVLCMovieListGridCellIdentifier";
	MVLCMovieGridViewCell * cell = (MVLCMovieGridViewCell *)[gridView dequeueReusableCellWithIdentifier:MVLCMovieListGridCellIdentifier];
	if (cell == nil) {
		cell = [MVLCMovieGridViewCell cellWithReuseIdentifier:MVLCMovieListGridCellIdentifier];
	}
	cell.titleLabel.text = [[_allMedia objectAtIndex:index] valueForKey:@"title"];

    // Here we use the new provided setImageWithURL: method to load the web
    NSURL *url = [NSURL URLWithString:[[_allMedia objectAtIndex:index] valueForKey:@"artworkURL"]];

    [cell.posterImageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"MVLCMovieGridViewCellPosterPlaceholder"]];

	return cell;
}

// all cells are placed in a logical 'grid cell', all of which are the same size. The default size is 96x128 (portrait).
// The width/height values returned by this function will be rounded UP to the nearest denominator of the screen width.
- (CGSize)portraitGridCellSizeForGridView:(AQGridView *)gridView {
	return [MVLCMovieGridViewCell cellSize];
}

#pragma mark -
#pragma mark AQGridViewDelegate
- (void)gridView:(AQGridView *)gridView didSelectItemAtIndex:(NSUInteger)index {
	MVLCMovieViewController * movieViewController = [[MVLCMovieViewController alloc] init];
    NSString *urlString = [[_allMedia objectAtIndex:index] valueForKey:@"url"];
	movieViewController.media = [VLCMedia mediaWithURL:[NSURL URLWithString:urlString]];
	[self.navigationController pushViewController:movieViewController animated:YES];
	[movieViewController release];
}

@end