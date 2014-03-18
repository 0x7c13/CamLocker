//
//  CLTrackingXMLGenerator.m
//  CamLocker
//
//  Created by FlyinGeek on 3/17/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLTrackingXMLGenerator.h"

@implementation CLTrackingXMLGenerator

+ (NSString *)generateTrackingXMLStringUsingMarkerImageFileNames:(NSArray *)markerImageFileNames
                                                        cosNames:(NSArray *)cosNames
{
    // protection
    if (markerImageFileNames == nil || cosNames == nil) {
        return nil;
    }
    if (markerImageFileNames.count != cosNames.count) {
        return nil;
    }
    for (id object in markerImageFileNames) {
        if (![object isKindOfClass:[NSString class]]) {
            return nil;
        }
    }
    for (id object in cosNames) {
        if (![object isKindOfClass:[NSString class]]) {
            return nil;
        }
    }
    
    NSString *xmlString;
    
    // setup header
    xmlString = @"<?xml version=\"1.0\"?>"
                 "<TrackingData>"
                    "<Sensors>"
                        "<Sensor Type=\"FeatureBasedSensorSource\" Subtype=\"Fast\">"
                            "<SensorID>CamLockerTracking</SensorID>"
                            "<Parameters>"
                                "<FeatureDescriptorAlignment>regular</FeatureDescriptorAlignment>"
                                "<MaxObjectsToDetectPerFrame>5</MaxObjectsToDetectPerFrame>"
                                "<MaxObjectsToTrackInParallel>1</MaxObjectsToTrackInParallel>"
                                "<SimilarityThreshold>0.7</SimilarityThreshold>"
                            "</Parameters>";
    
    // setup cos string
    for (NSInteger i = 1; i <= markerImageFileNames.count; i++) {
        
        NSString *sensorCosString = [NSString stringWithFormat:@"<SensorCOS>"
                                                                     "<SensorCosID>Patch%d</SensorCosID>"
                                                                     "<Parameters>"
                                                                     "<ReferenceImage>%@</ReferenceImage>"
                                                                     "<SimilarityThreshold>0.7</SimilarityThreshold>"
                                                                     "</Parameters>"
                                                                "</SensorCOS>", i, (NSString *)markerImageFileNames[i - 1]];
        xmlString = [xmlString stringByAppendingString:sensorCosString];
    }
    
    xmlString = [xmlString stringByAppendingString:@"    </Sensor>"
                                                    "</Sensors>"
                                                    "   <Connections>" ];
    
    // setup cos info
    for (NSInteger i = 1; i <= cosNames.count; i++) {
        
        NSString *cosString = [NSString stringWithFormat:@"<COS>"
                                                             "<Name>%@</Name>"
                                                             "<Fuser Type=\"SmoothingFuser\">"
                                                                 "<Parameters>"
                                                                     "<KeepPoseForNumberOfFrames>2</KeepPoseForNumberOfFrames>"
                                                                     "<GravityAssistance></GravityAssistance>"
                                                                     "<AlphaTranslation>1.0</AlphaTranslation>"
                                                                     "<GammaTranslation>1.0</GammaTranslation>"
                                                                     "<AlphaRotation>0.8</AlphaRotation>"
                                                                     "<GammaRotation>0.8</GammaRotation>"
                                                                     "<ContinueLostTrackingWithOrientationSensor>false</ContinueLostTrackingWithOrientationSensor>"
                                                                 "</Parameters>"
                                                             "</Fuser>"
                                                             
                                                             "<SensorSource>"
                                                                 "<SensorID>CamLockerTracking</SensorID>"
                                                                 "<SensorCosID>Patch%d</SensorCosID>"
                                                                 
                                                                 "<HandEyeCalibration>"
                                                                 
                                                                     "<TranslationOffset>"
                                                                         "<X>0</X>"
                                                                         "<Y>0</Y>"
                                                                         "<Z>0</Z>"
                                                                     "</TranslationOffset>"
                                                                     
                                                                     "<RotationOffset>"
                                                                         "<X>0</X>"
                                                                         "<Y>0</Y>"
                                                                         "<Z>0</Z>"
                                                                         "<W>1</W>"
                                                                     "</RotationOffset>"
                                                                 "</HandEyeCalibration>"
                                                                 
                                                                 "<COSOffset>"
                                                                     "<TranslationOffset>"
                                                                         "<X>0</X>"
                                                                         "<Y>0</Y>"
                                                                         "<Z>0</Z>"
                                                                     "</TranslationOffset>"
                                                                     "<RotationOffset>"
                                                                         "<X>0</X>"
                                                                         "<Y>0</Y>"
                                                                         "<Z>0</Z>"
                                                                         "<W>1</W>"
                                                                     "</RotationOffset>"
                                                                 "</COSOffset>"
                                                             "</SensorSource>"
                                                        "</COS>" , (NSString *)cosNames[i - 1], i];
        
        xmlString = [xmlString stringByAppendingString:cosString];
    }
 
    // end of xml string
    xmlString = [xmlString stringByAppendingString:@"	</Connections>"
                                                    "</TrackingData>"];
    return xmlString;
}

@end
