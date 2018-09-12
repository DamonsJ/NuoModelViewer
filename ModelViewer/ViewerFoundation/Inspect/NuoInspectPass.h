//
//  NuoInspectPass.h
//  ModelViewer
//
//  Created by middleware on 9/11/18.
//  Copyright © 2018 middleware. All rights reserved.
//

#import "NuoRenderPipelinePass.h"


@class NuoTextureMesh;


@interface NuoInspectPass : NuoRenderPipelinePass


@property (nonatomic, weak) id<MTLTexture> inspectedTexture;


- (instancetype)initWithCommandQueue:(id<MTLCommandQueue>)commandQueue
                     withPixelFormat:(MTLPixelFormat)pixelFormat
                         withProcess:(NSString*)inspectMean;


@end


