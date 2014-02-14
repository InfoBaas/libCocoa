//
//  OBSCollectionPage.m
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 19/11/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "OBSCollectionPage+.h"

@implementation OBSCollectionPage

+ (OBSCollectionPage *)collectionPageFromDataJSON:(NSDictionary *)data andMetadataJSON:(NSDictionary *)metadata
{
    NSArray *elements = data[@"ids"];
    if (!elements || [elements isEqual:[NSNull null]]) {
        return nil;
    }
    
    NSMutableArray *mutableElements = [NSMutableArray arrayWithCapacity:[elements count]];
    for (NSDictionary *el in elements) {
        OBSCollectionPageElement *obsEl = [OBSCollectionPageElement collectionPageElementFromJSON:el];
        if (obsEl) {
            [mutableElements addObject:obsEl];
        } else {
            [mutableElements addObject:[NSNull null]];
        }
    }
    
    NSNumber *pageNumber = data[@"pageNumber"];
    if (!pageNumber || [pageNumber isEqual:[NSNull null]]) {
        return nil;
    }
    NSNumber *pageSize = data[@"pageSize"];
    if (!pageSize || [pageSize isEqual:[NSNull null]]) {
        return nil;
    }
    NSNumber *numberOfElements = data[@"totalElems"];
    if (!numberOfElements || [numberOfElements isEqual:[NSNull null]]) {
        return nil;
    }
    NSNumber *numberOfPages = data[@"totalnumberpages"];
    if (!numberOfPages || [numberOfPages isEqual:[NSNull null]]) {
        return nil;
    }

    OBSCollectionPage *collectionPage = [[self alloc] init];

    collectionPage.elements = [NSArray arrayWithArray:mutableElements];
    collectionPage.pageNumber = [pageNumber integerValue];
    collectionPage.pageSize = [pageSize integerValue];
    collectionPage.pageCount = [numberOfPages integerValue];

    collectionPage.elementCount = [[collectionPage elements] count];
    collectionPage.firstElement = (collectionPage.pageNumber - 1) * collectionPage.pageCount + 1;

    return collectionPage;
}

@end

@implementation OBSCollectionPageElement

+ (OBSCollectionPageElement *)collectionPageElementFromJSON:(NSDictionary *)json
{
    NSString *identifier = json[@"_id"];
    if (!identifier) {
        return nil;
    }
    NSString *data = json[@"data"];
    if (!data) {
        return nil;
    }
    NSString *metadata = json[@"metadata"];
//    if (!metadata) {
//        return nil;
//    }
    
    OBSCollectionPageElement *element = [[self alloc] init];
    
    element.identifier = identifier;
    element.data = data;
    element.metadata = metadata;
    
    return element;
}

@end
