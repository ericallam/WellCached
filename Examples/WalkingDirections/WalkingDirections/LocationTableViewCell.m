//
//  LocationTableViewCell.m
//  WalkingDirections
//
//  Created by Eric Allam on 24/02/2014.
//  Copyright (c) 2014 Eric Allam. All rights reserved.
//

#import "LocationTableViewCell.h"

@implementation LocationTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
