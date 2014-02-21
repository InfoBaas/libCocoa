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
        pageNumber = nil;
    }
    NSNumber *pageSize = data[@"pageSize"];
    if (!pageSize || [pageSize isEqual:[NSNull null]]) {
        pageSize = nil;
    }
    NSNumber *numberOfElements = data[@"totalElems"];
    if (!numberOfElements || [numberOfElements isEqual:[NSNull null]]) {
        numberOfElements = nil;
    }
    NSNumber *numberOfPages = data[@"totalnumberpages"];
    if (!numberOfPages || [numberOfPages isEqual:[NSNull null]]) {
        numberOfPages = nil;
    }

    OBSCollectionPage *collectionPage = [[self alloc] init];

    collectionPage.elements = [NSArray arrayWithArray:mutableElements];
    collectionPage.pageNumber = pageNumber ? [pageNumber integerValue] : NSNotFound;
    collectionPage.pageSize = pageSize ? [pageSize integerValue] : NSNotFound;
    collectionPage.pageCount = numberOfPages ? [numberOfPages integerValue] : NSNotFound;

    collectionPage.elementCount = [[collectionPage elements] count];
    if (pageNumber && numberOfPages) {
        collectionPage.firstElement = (collectionPage.pageNumber - 1) * collectionPage.pageCount + 1;
    } else {
        collectionPage.firstElement = NSNotFound;
    }

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
