//
//  NuoRayTracingAccelerateStructure.m
//  ModelViewer
//
//  Created by middleware on 6/16/18.
//  Copyright © 2018 middleware. All rights reserved.
//

#import "NuoRayAccelerateStructure.h"
#import <MetalPerformanceShaders/MetalPerformanceShaders.h>

#import "NuoRayBuffer.h"
#import "NuoPrimaryRayEmitter.h"
#import "NuoMeshSceneRoot.h"
#import "NuoCommandBuffer.h"

#include "NuoRayTracingUniform.h"


const uint kRayIntersectionStride = sizeof(MPSIntersectionDistancePrimitiveIndexCoordinates);


@interface NuoCommandBuffer()

- (id<MTLCommandBuffer>)commandBuffer;

@end



@implementation NuoRayAccelerateStructure
{
    id<MTLCommandQueue> _commandQueue;
    
    MPSRayIntersector* _intersector;
    MPSTriangleAccelerationStructure* _accelerateStructure;
    
    NuoPrimaryRayEmitter* _primaryRayEmitter;
}


- (instancetype)initWithCommandQueue:(id<MTLCommandQueue>)commandQueue
{
    self = [super init];
    
    if (self)
    {
        _intersector = [[MPSRayIntersector alloc] initWithDevice:commandQueue.device];
        _intersector.rayDataType = MPSRayDataTypeOriginMaskDirectionMaxDistance;
        _intersector.rayStride = kRayBufferStride;
        _intersector.rayMaskOptions = MPSRayMaskOptionPrimitive;
        
        _accelerateStructure = [[MPSTriangleAccelerationStructure alloc] initWithDevice:commandQueue.device];
        _accelerateStructure.usage = MPSAccelerationStructureUsageRefit;
        
        _primaryRayEmitter = [[NuoPrimaryRayEmitter alloc] initWithCommandQueue:commandQueue];
        _primaryRayBuffer = [[NuoRayBuffer alloc] initWithCommandQueue:commandQueue];
        
        _commandQueue = commandQueue;
    }
    
    return self;
}


- (void)setFieldOfView:(CGFloat)fieldOfView
{
    [_primaryRayEmitter setFieldOfView:fieldOfView];
}


- (CGFloat)fieldOfView
{
    return [_primaryRayEmitter fieldOfView];
}



- (void)setDrawableSize:(CGSize)drawableSize
{
    [_primaryRayBuffer setDimension:drawableSize];
}



- (CGSize)drawableSize
{
    return [_primaryRayBuffer dimension];
}



- (void)setRoot:(NuoMeshSceneRoot*)root
{
    if (!root.meshes || !root.meshes.count)
    {
        _accelerateStructure.vertexBuffer = nil;
        _accelerateStructure.indexType = MPSDataTypeUInt32;
        _accelerateStructure.indexBuffer = 0;
        _accelerateStructure.triangleCount = 0;
        _accelerateStructure.maskBuffer = nil;
        
        return;
    }
    
    // all coordinates are in the world system, with primary rays following the same rule as
    // they are transformed through the inverse of the view matrix
    
    NuoGlobalBuffers buffer;
    
    [root appendWorldBuffers:NuoMatrixFloat44Identity toBuffers:&buffer];
    uint32_t triangleCount = (uint32_t)buffer._indices.size() / 3;
    uint32_t indexBufferSize = (uint32_t)(buffer._indices.size() * sizeof(uint32));
    
    id<MTLBuffer> indexBuffer = [_commandQueue.device newBufferWithBytes:&buffer._indices[0]
                                                                  length:indexBufferSize
                                                                 options:MTLResourceStorageModeShared];
    
    _indexBuffer = [_commandQueue.device newBufferWithLength:indexBufferSize
                                                     options:MTLResourceStorageModePrivate];
    
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    id<MTLBlitCommandEncoder> encoder = [commandBuffer blitCommandEncoder];
    
    [encoder copyFromBuffer:indexBuffer sourceOffset:0
                   toBuffer:_indexBuffer destinationOffset:0 size:indexBufferSize];
    
    _materialBuffer = nil;
    _vertexBuffer = nil;
    _maskBuffer = nil;
    
    [self setWorldBuffers:buffer withEncoder:encoder];
    [self setMaskBuffer:root];
    
    [encoder endEncoding];
    [commandBuffer commit];
    [commandBuffer waitUntilCompleted];
    
    _accelerateStructure.vertexBuffer = _vertexBuffer;
    _accelerateStructure.indexType = MPSDataTypeUInt32;
    _accelerateStructure.indexBuffer = _indexBuffer;
    _accelerateStructure.triangleCount = triangleCount;
    _accelerateStructure.maskBuffer = _maskBuffer;
    
    [_accelerateStructure rebuild];
}


- (void)setRoot:(NuoMeshSceneRoot *)root withCommandBuffer:(NuoCommandBuffer*)commandBuffer
{
    assert(_maskBuffer != nil);
    assert(_vertexBuffer != nil);
    assert(_materialBuffer != nil);
    
    bool unchanged = [root isCachedTransformValid:NuoMatrixFloat44Identity];
    if (unchanged)
        return;
    
    NuoGlobalBuffers buffer;
    [root appendWorldBuffers:NuoMatrixFloat44Identity toBuffers:&buffer];
    
    id<MTLBlitCommandEncoder> encoder = [commandBuffer.commandBuffer blitCommandEncoder];
    [self setWorldBuffers:buffer withEncoder:encoder];
    [encoder endEncoding];
    
    [self setMaskBuffer:root];
    [_accelerateStructure encodeRefitToCommandBuffer:commandBuffer.commandBuffer];
}



- (void)setWorldBuffers:(const NuoGlobalBuffers&)buffers withEncoder:(id<MTLBlitCommandEncoder>)encoder
{
    uint32_t vertexBufferSize = (uint32_t)(buffers._vertices.size() * sizeof(NuoVectorFloat3::_typeTrait::_vectorType));
    uint32_t materialBufferSize = (uint32_t)(buffers._vertices.size() * sizeof(NuoRayTracingMaterial));
    
    if (!_materialBuffer)
    {
        _materialBuffer = [_commandQueue.device newBufferWithLength:materialBufferSize
                                                            options:MTLResourceStorageModePrivate];
    }
    
    id<MTLBuffer> materialBuffer = [_commandQueue.device newBufferWithBytes:&buffers._materials[0]
                                                                     length:materialBufferSize
                                                                    options:MTLResourceStorageModeShared];
    [encoder copyFromBuffer:materialBuffer sourceOffset:0
                   toBuffer:_materialBuffer destinationOffset:0 size:materialBufferSize];
    
    if (!_vertexBuffer)
    {
        _vertexBuffer = [_commandQueue.device newBufferWithLength:vertexBufferSize
                                                          options:MTLResourceStorageModePrivate];
    }
    
    id<MTLBuffer> vertexBuffer = [_commandQueue.device newBufferWithBytes:&buffers._vertices[0]
                                                                   length:vertexBufferSize
                                                                  options:MTLResourceStorageModeShared];
    
    [encoder copyFromBuffer:vertexBuffer sourceOffset:0
                   toBuffer:_vertexBuffer destinationOffset:0 size:vertexBufferSize];
    
    _diffuseTextures = [NSMutableArray new];
    for (void* textureOne : buffers._textureMap)
    {
        [((NSMutableArray*)_diffuseTextures) addObject:(__bridge id<MTLTexture>)textureOne];
    }
}

    
- (void)setMaskBuffer:(NuoMeshSceneRoot*)root
{
    std::vector<NuoRayMask> mask = [root maskBuffer];
    uint32_t maskBufferSize = (uint32_t)(mask.size() * sizeof(uint32_t));
    
    if (!_maskBuffer)
    {
        _maskBuffer = [_commandQueue.device newBufferWithLength:maskBufferSize
                                                      options:MTLResourceStorageModeManaged];
    }
    
    memcpy(_maskBuffer.contents, &mask[0], maskBufferSize);
    [_maskBuffer didModifyRange:NSMakeRange(0, maskBufferSize)];
}


- (void)setView:(const NuoMatrixFloat44&)viewTrans
{
    [_primaryRayEmitter setViewTrans:viewTrans.Inverse()];
}


- (void)updatePrimaryRayMask:(uint32)mask withCommandBuffer:(NuoCommandBuffer*)commandBuffer
{
    [_primaryRayBuffer updateMask:mask
                      withUniform:[self uniformBuffer:commandBuffer]
                withCommandBuffer:commandBuffer];
}


- (void)primaryRayEmit:(NuoCommandBuffer*)commandBuffer
{
    [_primaryRayEmitter emitToBuffer:_primaryRayBuffer withCommandBuffer:commandBuffer];
}


- (void)primaryRayIntersect:(NuoCommandBuffer*)commandBuffer
           withIntersection:(id<MTLBuffer>)intersection
{
    if (_accelerateStructure.status == MPSAccelerationStructureStatusBuilt)
    {
        [self rayIntersect:commandBuffer
                  withRays:_primaryRayBuffer withIntersection:intersection];
    }
}


- (void)rayIntersect:(NuoCommandBuffer*)commandBuffer
            withRays:(NuoRayBuffer*)rayBuffer withIntersection:(id<MTLBuffer>)intersection
{
    if (_accelerateStructure.status == MPSAccelerationStructureStatusBuilt)
    {
        [_intersector setIntersectionDataType:MPSIntersectionDataTypeDistancePrimitiveIndexCoordinates];
        [_intersector encodeIntersectionToCommandBuffer:commandBuffer.commandBuffer
                                       intersectionType:MPSIntersectionTypeNearest
                                              rayBuffer:rayBuffer.buffer
                                        rayBufferOffset:0
                                     intersectionBuffer:intersection
                               intersectionBufferOffset:0
                                               rayCount:rayBuffer.rayCount
                                  accelerationStructure:_accelerateStructure];
    }
}


- (id<MTLBuffer>)uniformBuffer:(id<NuoRenderInFlight>)inFlight
{
    return [_primaryRayEmitter uniformBuffer:inFlight];
}




@end
