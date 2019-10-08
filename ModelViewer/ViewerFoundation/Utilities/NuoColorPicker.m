//
//  NuoColorPicker.m
//  ModelViewer
//
//  Created by Dong on 10/8/19.
//  Copyright © 2019 middleware. All rights reserved.
//

#import "NuoColorPicker.h"


@implementation NuoColorPicker

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        [self setWantsLayer:YES];
        
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 5.0;
        self.layer.borderColor = [NSColor colorWithDeviceWhite:0.8 alpha:0.8].CGColor;
        self.layer.borderWidth = 1.0;
    }
    
    return self;
}


- (void)mouseDown:(NSEvent *)event
{
    // prevent the mouse-down event from being passed through
    // to the view under
}


- (void)mouseUp:(NSEvent *)event
{
    NSColorPanel* panel = [NSColorPanel sharedColorPanel];
    
    panel.color = _color;
    
    [panel setContinuous:YES];
    [panel setTarget:self];
    [panel setAction:@selector(colorChanged:)];
    
    [panel display];
    [panel orderFrontRegardless];
}


- (void)colorChanged:(id)sender
{
    NSColorPanel* panel = sender;
    
    self.layer.backgroundColor = panel.color.CGColor;
    _color = panel.color;
    
    if (_colorChanged)
        _colorChanged();
}


- (void)setColor:(NSColor*)color
{
    _color = color;
    self.layer.backgroundColor = color.CGColor;
}


@end
