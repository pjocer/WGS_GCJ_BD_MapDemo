//
//  MapMessageCell.m
//  MapDemo
//
//  Created by PerryJi on 16/4/6.
//  Copyright © 2016年 PerryJi. All rights reserved.
//

#import "MapMessageCell.h"

@implementation MapMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setMessage:(NSDictionary *)message {
    _message = message;
    _TitleLabel.text = message[@"text"];
    _address.text = [NSString stringWithFormat:@"Address:%@",message[@"address"]];
    _location.text = [NSString stringWithFormat:@"Location:%@",message[@"location"]];
}
@end
