//
//  Copyright (c) 2015 Algolia
//  http://www.algolia.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

/// Contains all the functions related to one index
///
/// You can use Client.getIndex(indexName) to retrieve this object
@objc public class Index : NSObject {
    @objc public let indexName: String
    @objc public let client: Client
    let urlEncodedIndexName: String
    
    var searchCache: ExpiringCache?
    
    @objc public init(client: Client, indexName: String) {
        self.client = client
        self.indexName = indexName
        urlEncodedIndexName = indexName.urlEncode()
    }
    
    /// Add an object in this index
    ///
    /// - parameter object: The object to add inside the index.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func addObject(object: [String: AnyObject], completionHandler: CompletionHandler? = nil) -> NSOperation {
        let path = "1/indexes/\(urlEncodedIndexName)"
        return client.performHTTPQuery(path, method: .POST, body: object, hostnames: client.writeHosts, completionHandler: completionHandler)
    }
    
    /// Add an object in this index
    ///
    /// - parameter object: The object to add inside the index.
    /// - parameter withID: An objectID you want to attribute to this object (if the attribute already exist, the old object will be overwrite)
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func addObject(object: [String: AnyObject], withID objectID: String, completionHandler: CompletionHandler? = nil) -> NSOperation {
        let path = "1/indexes/\(urlEncodedIndexName)/\(objectID.urlEncode())"
        return client.performHTTPQuery(path, method: .PUT, body: object, hostnames: client.writeHosts, completionHandler: completionHandler)
    }
    
    /// Add several objects in this index
    ///
    /// - parameter objects: An array of objects to add (Array of Dictionnary object).
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func addObjects(objects: [AnyObject], completionHandler: CompletionHandler? = nil) -> NSOperation {
        let path = "1/indexes/\(urlEncodedIndexName)/batch"
        
        var requests = [AnyObject]()
        requests.reserveCapacity(objects.count)
        for object in objects {
            requests.append(["action": "addObject", "body": object])
        }
        let request = ["requests": requests]
        
        return client.performHTTPQuery(path, method: .POST, body: request, hostnames: client.writeHosts, completionHandler: completionHandler)
    }
    
    /// Delete an object from the index
    ///
    /// - parameter objectID: The unique identifier of object to delete
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func deleteObject(objectID: String, completionHandler: CompletionHandler? = nil) -> NSOperation {
        let path = "1/indexes/\(urlEncodedIndexName)/\(objectID.urlEncode())"
        return client.performHTTPQuery(path, method: .DELETE, body: nil, hostnames: client.writeHosts, completionHandler: completionHandler)
    }
    
    /// Delete several objects
    ///
    /// - parameter objectIDs: An array of objectID to delete.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func deleteObjects(objectIDs: [String], completionHandler: CompletionHandler? = nil) -> NSOperation {
        let path = "1/indexes/\(urlEncodedIndexName)/batch"
        
        var requests = [AnyObject]()
        requests.reserveCapacity(objectIDs.count)
        for id in objectIDs {
            requests.append(["action": "deleteObject", "objectID": id])
        }
        let request = ["requests": requests]
        
        return client.performHTTPQuery(path, method: .POST, body: request, hostnames: client.writeHosts, completionHandler: completionHandler)
    }
    
    /// Get an object from this index
    ///
    /// - parameter objectID: The unique identifier of the object to retrieve
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func getObject(objectID: String, completionHandler: CompletionHandler) -> NSOperation {
        let path = "1/indexes/\(urlEncodedIndexName)/\(objectID.urlEncode())"
        return client.performHTTPQuery(path, method: .GET, body: nil, hostnames: client.readHosts, completionHandler: completionHandler)
    }
    
    /// Get an object from this index
    ///
    /// - parameter objectID: The unique identifier of the object to retrieve
    /// - parameter attributesToRetrieve: The list of attributes to retrieve
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func getObject(objectID: String, attributesToRetrieve attributes: [String], completionHandler: CompletionHandler) -> NSOperation {
        let query = Query()
        query.attributesToRetrieve = attributes
        let path = "1/indexes/\(urlEncodedIndexName)/\(objectID.urlEncode())?\(query.build())"
        return client.performHTTPQuery(path, method: .GET, body: nil, hostnames: client.readHosts, completionHandler: completionHandler)
    }
    
    /// Get several objects from this index
    ///
    /// - parameter objectIDs: The array of unique identifier of objects to retrieve
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func getObjects(objectIDs: [String], completionHandler: CompletionHandler) -> NSOperation {
        let path = "1/indexes/*/objects"
        
        var requests = [AnyObject]()
        requests.reserveCapacity(objectIDs.count)
        for id in objectIDs {
            requests.append(["indexName": indexName, "objectID": id])
        }
        let request = ["requests": requests]
        
        return client.performHTTPQuery(path, method: .POST, body: request, hostnames: client.readHosts, completionHandler: completionHandler)
    }
    
    /// Update partially an object (only update attributes passed in argument)
    ///
    /// - parameter partialObject: New values/operations for the object.
    /// - parameter objectID: Identifier of object to be updated.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func partialUpdateObject(partialObject: [String: AnyObject], objectID: String, completionHandler: CompletionHandler? = nil) -> NSOperation {
        let path = "1/indexes/\(urlEncodedIndexName)/\(objectID.urlEncode())/partial"
        return client.performHTTPQuery(path, method: .POST, body: partialObject, hostnames: client.writeHosts, completionHandler: completionHandler)
    }
    
    /// Update partially the content of several objects
    ///
    /// - parameter objects: An array of Dictionary to update (each Dictionary must contains an objectID attribute)
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func partialUpdateObjects(objects: [AnyObject], completionHandler: CompletionHandler? = nil) -> NSOperation {
        let path = "1/indexes/\(urlEncodedIndexName)/batch"
        
        var requests = [AnyObject]()
        requests.reserveCapacity(objects.count)
        for object in objects {
            if let object = object as? [String: AnyObject] {
                requests.append([
                    "action": "partialUpdateObject",
                    "objectID": object["objectID"] as! String,
                    "body": object
                    ])
            }
        }
        let request = ["requests": requests]
        
        return client.performHTTPQuery(path, method: .POST, body: request, hostnames: client.writeHosts, completionHandler: completionHandler)
    }
    
    /// Override the content of object
    ///
    /// - parameter object: The object to override, the object must contains an objectID attribute
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func saveObject(object: [String: AnyObject], completionHandler: CompletionHandler? = nil) -> NSOperation {
        let objectID = object["objectID"] as! String
        let path = "1/indexes/\(urlEncodedIndexName)/\(objectID.urlEncode())"
        return client.performHTTPQuery(path, method: .PUT, body: object, hostnames: client.writeHosts, completionHandler: completionHandler)
    }
    
    /// Override the content of several objects
    ///
    /// - parameter objects: An array of Dictionary to save (each Dictionary must contains an objectID attribute)
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func saveObjects(objects: [AnyObject], completionHandler: CompletionHandler? = nil) -> NSOperation {
        let path = "1/indexes/\(urlEncodedIndexName)/batch"
        
        var requests = [AnyObject]()
        requests.reserveCapacity(objects.count)
        for object in objects {
            if let object = object as? [String: AnyObject] {
                requests.append([
                    "action": "updateObject",
                    "objectID": object["objectID"] as! String,
                    "body": object
                    ])
            }
        }
        let request = ["requests": requests]
        
        return client.performHTTPQuery(path, method: .POST, body: request, hostnames: client.writeHosts, completionHandler: completionHandler)
    }
    
    /// Search inside the index
    ///
    /// - parameter query: Search parameters.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func search(query: Query, completionHandler: CompletionHandler) -> NSOperation {
        let path = "1/indexes/\(urlEncodedIndexName)/query"
        let request = ["params": query.build()]
        
        // First try the in-memory query cache.
        let cacheKey = "\(path)_body_\(request)"
        if let content = searchCache?.objectForKey(cacheKey) {
            // We *have* to return something, so we create a completionHandler operation.
            // Note that its execution will be deferred until the next iteration of the main run loop.
            let operation = NSBlockOperation() {
                completionHandler(content: content, error: nil)
            }
            NSOperationQueue.mainQueue().addOperation(operation)
            return operation
        }
        // Otherwise, run an online query.
        else {
            return client.performHTTPQuery(path, method: .POST, body: request, hostnames: client.readHosts, isSearchQuery: true) {
                (content, error) -> Void in
                assert(content != nil || error != nil)
                if content != nil {
                    self.searchCache?.setObject(content!, forKey: cacheKey)
                    completionHandler(content: content, error: error)
                } else {
                    completionHandler(content: content, error: error)
                }
            }
        }
    }
    
    /// Get settings of this index
    ///
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func getSettings(completionHandler: CompletionHandler) -> NSOperation {
        let path = "1/indexes/\(urlEncodedIndexName)/settings"
        return client.performHTTPQuery(path, method: .GET, body: nil, hostnames: client.readHosts, completionHandler: completionHandler)
    }
    
    /// Set settings for this index
    ///
    /// - parameter settings: The settings object
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    /// NB: The settings object can contains :
    ///
    /// - minWordSizefor1Typo: (integer) the minimum number of characters to accept one typo (default = 3).
    /// - minWordSizefor2Typos: (integer) the minimum number of characters to accept two typos (default = 7).
    /// - hitsPerPage: (integer) the number of hits per page (default = 10).
    /// - attributesToRetrieve: (array of strings) default list of attributes to retrieve in objects. If set to null, all attributes are retrieved.
    /// - attributesToHighlight: (array of strings) default list of attributes to highlight. If set to null, all indexed attributes are highlighted.
    /// - attributesToSnippet: (array of strings) default list of attributes to snippet alongside the number of words to return (syntax is attributeName:nbWords). By default no snippet is computed. If set to null, no snippet is computed.
    /// - attributesToIndex: (array of strings) the list of fields you want to index. If set to null, all textual and numerical attributes of your objects are indexed, but you should update it to get optimal results. This parameter has two important uses:
    ///     - Limit the attributes to index: For example if you store a binary image in base64, you want to store it and be able to retrieve it but you don't want to search in the base64 string.
    ///     - Control part of the ranking*: (see the ranking parameter for full explanation) Matches in attributes at the beginning of the list will be considered more important than matches in attributes further down the list. In one attribute, matching text at the beginning of the attribute will be considered more important than text after, you can disable this behavior if you add your attribute inside `unordered(AttributeName)`, for example attributesToIndex: ["title", "unordered(text)"].
    /// - attributesForFaceting: (array of strings) The list of fields you want to use for faceting. All strings in the attribute selected for faceting are extracted and added as a facet. If set to null, no attribute is used for faceting.
    /// - ranking: (array of strings) controls the way results are sorted. We have six available criteria:
    ///     - typo: sort according to number of typos,
    ///     - geo: sort according to decreassing distance when performing a geo-location based search,
    ///     - proximity: sort according to the proximity of query words in hits,
    ///     - attribute: sort according to the order of attributes defined by attributesToIndex,
    ///     - exact: sort according to the number of words that are matched identical to query word (and not as a prefix),
    ///     - custom: sort according to a user defined formula set in customRanking attribute. The standard order is ["typo", "geo", "proximity", "attribute", "exact", "custom"]
    /// - customRanking: (array of strings) lets you specify part of the ranking. The syntax of this condition is an array of strings containing attributes prefixed by asc (ascending order) or desc (descending order) operator. For example `"customRanking" => ["desc(population)", "asc(name)"]`
    /// - queryType: Select how the query words are interpreted, it can be one of the following value:
    ///     - prefixAll: all query words are interpreted as prefixes,
    ///     - prefixLast: only the last word is interpreted as a prefix (default behavior),
    ///     - prefixNone: no query word is interpreted as a prefix. This option is not recommended.
    /// - highlightPreTag: (string) Specify the string that is inserted before the highlighted parts in the query result (default to "<em>").
    /// - highlightPostTag: (string) Specify the string that is inserted after the highlighted parts in the query result (default to "</em>").
    /// - optionalWords: (array of strings) Specify a list of words that should be considered as optional when found in the query.
    ///
    @objc public func setSettings(settings: [String: AnyObject], completionHandler: CompletionHandler? = nil) -> NSOperation {
        let path = "1/indexes/\(urlEncodedIndexName)/settings"
        return client.performHTTPQuery(path, method: .PUT, body: settings, hostnames: client.writeHosts, completionHandler: completionHandler)
    }
    
    /// Delete the index content without removing settings and index specific API keys.
    ///
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func clearIndex(completionHandler: CompletionHandler? = nil) -> NSOperation {
        let path = "1/indexes/\(urlEncodedIndexName)/clear"
        return client.performHTTPQuery(path, method: .POST, body: nil, hostnames: client.writeHosts, completionHandler: completionHandler)
    }
    
    /// Custom batch operations.
    ///
    /// - parameter actions: The array of actions.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func batch(actions: [AnyObject], completionHandler: CompletionHandler? = nil) -> NSOperation {
        let path = "1/indexes/\(urlEncodedIndexName)/batch"
        let body = ["requests": actions]
        return client.performHTTPQuery(path, method: .POST, body: body, hostnames: client.writeHosts, completionHandler: completionHandler)
    }
    
    /// Browse all index content (initial call).
    /// This method should be called once to initiate a browse. It will return the first page of results and a cursor,
    /// unless the end of the index has been reached. To retrieve subsequent pages, call `browseFrom` with that cursor.
    ///
    /// - parameter query: The query parameters for the browse.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func browse(query: Query, completionHandler: CompletionHandler) -> NSOperation {
        let path = "1/indexes/\(urlEncodedIndexName)/browse"
        let body = [
            "params": query.build()
        ]
        return client.performHTTPQuery(path, method: .POST, body: body, hostnames: client.readHosts, completionHandler: completionHandler)
    }
    
    /// Browse the index from a cursor.
    /// This method should be called after an initial call to `browse()`. It returns a cursor, unless the end of the
    /// index has been reached.
    ///
    /// - parameter cursor: The cursor of the next page to retrieve
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func browseFrom(cursor: String, completionHandler: CompletionHandler) -> NSOperation {
        let path = "1/indexes/\(urlEncodedIndexName)/browse?cursor=\(cursor.urlEncode())"
        return client.performHTTPQuery(path, method: .GET, body: nil, hostnames: client.readHosts, completionHandler: completionHandler)
    }
    
    // MARK: - Helpers
    
    /// Wait the publication of a task on the server.
    /// All server task are asynchronous and you can check with this method that the task is published.
    ///
    /// - parameter taskID: The ID of the task returned by server
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func waitTask(taskID: Int, completionHandler: CompletionHandler) -> NSOperation {
        let operation = WaitOperation(index: self, taskID: taskID, completionHandler: completionHandler)
        operation.start()
        return operation
    }
    
    private class WaitOperation: AsyncOperation {
        let index: Index
        let taskID: Int
        let completionHandler: CompletionHandler
        let path: String
        
        init(index: Index, taskID: Int, completionHandler: CompletionHandler) {
            self.index = index
            self.taskID = taskID
            self.completionHandler = completionHandler
            path = "1/indexes/\(index.urlEncodedIndexName)/task/\(taskID)"
        }
        
        override func start() {
            super.start()
            startNext()
        }
        
        private func startNext() {
            if cancelled {
                finish()
            }
            index.client.performHTTPQuery(path, method: .GET, body: nil, hostnames: index.client.writeHosts) {
                (content, error) -> Void in
                if let content = content {
                    if (content["status"] as? String) == "published" {
                        if !self.cancelled {
                            self.completionHandler(content: content, error: nil)
                        }
                        self.finish()
                    } else {
                        NSThread.sleepForTimeInterval(0.1)
                        self.startNext()
                    }
                } else {
                    if !self.cancelled {
                        self.completionHandler(content: content, error: error)
                    }
                    self.finish()
                }
            }
        }
    }

    /// Delete all objects matching a query (helper).
    ///
    /// - parameter query: The query used to filter objects.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func deleteByQuery(query: Query, completionHandler: CompletionHandler? = nil) -> NSOperation {
        let operation = DeleteByQueryOperation(index: self, query: query, completionHandler: completionHandler)
        operation.start()
        return operation
    }
    
    private class DeleteByQueryOperation: AsyncOperation {
        let index: Index
        let query: Query
        let completionHandler: CompletionHandler?
        
        init(index: Index, query: Query, completionHandler: CompletionHandler?) {
            self.index = index
            self.query = Query(copy: query)
            self.completionHandler = completionHandler
        }
        
        override func start() {
            super.start()
            index.browse(query, completionHandler: self.handleResult)
        }
        
        private func handleResult(content: [String: AnyObject]?, error: NSError?) {
            if self.cancelled {
                return
            }
            var finalError: NSError? = error
            if finalError == nil {
                let hasMoreContent = content!["cursor"] != nil
                if let hits = content!["hits"] as? [AnyObject] {
                    // Fetch IDs of objects to delete.
                    var objectIDs: [String] = []
                    for hit in hits {
                        if let objectID = (hit as? [String: AnyObject])?["objectID"] as? String {
                            objectIDs.append(objectID)
                        }
                    }
                    // Delete the objects.
                    self.index.deleteObjects(objectIDs, completionHandler: { (content, error) in
                        if self.cancelled {
                            return
                        }
                        var finalError: NSError? = error
                        if finalError == nil {
                            if let taskID = content?["taskID"] as? Int {
                                // Wait for the deletion to be effective.
                                self.index.waitTask(taskID, completionHandler: { (content, error) in
                                    if self.cancelled {
                                        return
                                    }
                                    if error != nil || !hasMoreContent {
                                        self.finish(content, error: error)
                                    } else {
                                        // Browse again *from the beginning*, since the deletion invalidated the cursor.
                                        self.index.browse(self.query, completionHandler: self.handleResult)
                                    }
                                })
                            } else {
                                finalError = NSError(domain: Client.ErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "No task ID returned when deleting"])
                            }
                        }
                        if finalError != nil {
                            self.finish(nil, error: finalError)
                        }
                    })
                } else {
                    finalError = NSError(domain: Client.ErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "No hits returned when browsing"])
                }
            }
            if finalError != nil {
                self.finish(nil, error: finalError)
            }
        }
        
        private func finish(content: [String: AnyObject]?, error: NSError?) {
            if !cancelled {
                self.completionHandler?(content: nil, error: error)
            }
            self.finish()
        }
    }
    
    /// Perform a search with disjunctive facets, generating as many queries as number of disjunctive facets.
    ///
    /// - parameter query:              The query.
    /// - parameter disjunctiveFacets:  List of disjunctive facets.
    /// - parameter refinements:        The current refinements, mapping facet names to a list of values.
    /// - parameter completionHandler:              Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func searchDisjunctiveFaceting(query: Query, disjunctiveFacets: [String], refinements: [String: [String]], completionHandler: CompletionHandler) -> NSOperation {
        var requests = [IndexQuery]()
        
        // Build the first, global query.
        let globalQuery = Query(copy: query)
        globalQuery.facetFilters = Index._buildFacetFilters(disjunctiveFacets, refinements: refinements, excludedFacet: nil)
        requests.append(IndexQuery(index: self, query: globalQuery))
        
        // Build the refined queries.
        for disjunctiveFacet in disjunctiveFacets {
            let disjunctiveQuery = Query(copy: query)
            disjunctiveQuery.facets = [disjunctiveFacet]
            disjunctiveQuery.facetFilters = Index._buildFacetFilters(disjunctiveFacets, refinements: refinements, excludedFacet: disjunctiveFacet)
            // We are not interested in the hits for this query, only the facet counts, so let's limit the output.
            disjunctiveQuery.hitsPerPage = 0
            disjunctiveQuery.attributesToRetrieve = []
            disjunctiveQuery.attributesToHighlight = []
            disjunctiveQuery.attributesToSnippet = []
            // Do not show this query in analytics, either.
            disjunctiveQuery.analytics = false
            requests.append(IndexQuery(index: self, query: disjunctiveQuery))
        }
        
        // Run all the queries.
        let operation = client.multipleQueries(requests, completionHandler: { (content, error) -> Void in
            var finalContent: [String: AnyObject]? = nil
            var finalError: NSError? = error
            if error == nil {
                do {
                    finalContent = try Index._aggregateResults(disjunctiveFacets, refinements: refinements, content: content!)
                } catch let e as NSError {
                    finalError = e
                }
            }
            assert(finalContent != nil || finalError != nil)
            completionHandler(content: finalContent, error: finalError)
        })
        return operation
    }
    
    /// Aggregate disjunctive faceting search results.
    private class func _aggregateResults(disjunctiveFacets: [String], refinements: [String: [String]], content: [String: AnyObject]) throws -> [String: AnyObject] {
        guard let results = content["results"] as? [AnyObject] else {
            throw NSError(domain: Client.ErrorDomain, code: StatusCode.InvalidResponse.rawValue, userInfo: [NSLocalizedDescriptionKey: "No results in response"])
        }
        // The first answer is used as the basis for the response.
        guard var mainContent = results[0] as? [String: AnyObject] else {
            throw NSError(domain: Client.ErrorDomain, code: StatusCode.InvalidResponse.rawValue, userInfo: [NSLocalizedDescriptionKey: "Invalid results in response"])
        }
        // Following answers are just used for their facet counts.
        var disjunctiveFacetCounts = [String: AnyObject]()
        for i in 1..<results.count { // for each answer (= each disjunctive facet)
            guard let result = results[i] as? [String: AnyObject], allFacetCounts = result["facets"] as? [String: [String: AnyObject]] else {
                throw NSError(domain: Client.ErrorDomain, code: StatusCode.InvalidResponse.rawValue, userInfo: [NSLocalizedDescriptionKey: "Invalid results in response"])
            }
            // NOTE: Iterating, but there should be just one item.
            for (facetName, facetCounts) in allFacetCounts {
                var newFacetCounts = facetCounts
                // Add zeroes for missing values.
                if disjunctiveFacets.contains(facetName) {
                    if let refinedValues = refinements[facetName] {
                        for refinedValue in refinedValues {
                            if facetCounts[refinedValue] == nil {
                                newFacetCounts[refinedValue] = 0
                            }
                        }
                    }
                }
                disjunctiveFacetCounts[facetName] = newFacetCounts
            }
        }
        mainContent["disjunctiveFacets"] = disjunctiveFacetCounts
        return mainContent
    }
    
    /// Build the facet filters, either global or for the selected disjunctive facet.
    ///
    /// - parameter excludedFacet: The disjunctive facet to exclude from the filters. If nil, no facet is
    ///   excluded (thus building the global filters).
    ///
    private class func _buildFacetFilters(disjunctiveFacets: [String], refinements: [String: [String]], excludedFacet: String?) -> [AnyObject] {
        var facetFilters: [AnyObject] = []
        for (facetName, facetValues) in refinements {
            // Disjunctive facet: OR all values, and AND with the rest of the filters.
            if disjunctiveFacets.contains(facetName) {
                // Skip the specified disjunctive facet, if any.
                if facetName == excludedFacet {
                    continue
                }
                var disjunctiveOperator = [String]()
                for facetValue in facetValues {
                    disjunctiveOperator.append("\(facetName):\(facetValue)")
                }
                facetFilters.append(disjunctiveOperator)
            }
                // Conjunctive facet: AND all values with the rest of the filters.
            else {
                assert(facetName != excludedFacet)
                for facetValue in facetValues {
                    facetFilters.append("\(facetName):\(facetValue)")
                }
            }
        }
        return facetFilters
    }

    // MARK: - Search Cache
    
    /// Enable search cache.
    ///
    /// - parameter expiringTimeInterval: Each cached search will be valid during this interval of time
    @objc public func enableSearchCache(expiringTimeInterval: NSTimeInterval = 120) {
        searchCache = ExpiringCache(expiringTimeInterval: expiringTimeInterval)
    }
    
    /// Disable search cache
    @objc public func disableSearchCache() {
        searchCache?.clearCache()
        searchCache = nil
    }
    
    /// Clear search cache
    @objc public func clearSearchCache() {
        searchCache?.clearCache()
    }
}
