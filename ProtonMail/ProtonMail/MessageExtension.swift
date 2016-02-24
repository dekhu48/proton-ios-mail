//
//  MessageExtension.swift
//  ProtonMail
//
//
// Copyright 2015 ArcTouch, Inc.
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

import CoreData
import Foundation

extension Message {
    
    struct Attributes {
        static let entityName = "Message"
        static let locationNumber = "locationNumber"
        static let isDetailDownloaded = "isDetailDownloaded"
        static let isRead = "isRead"
        static let isStarred = "isStarred"
        static let messageID = "messageID"
        static let recipientList = "recipientList"
        static let senderName = "senderName"
        static let time = "time"
        static let title = "title"
        static let labels = "labels"
    }
    
    struct Constants {
        static let starredTag = "starred"
    }
    
    // MARK: - Public variables
    
    var allEmailAddresses: String {
        var lists: [String] = []
        
        if !recipientList.isEmpty {
            let to = MessageHelper.contactsToAddresses(recipientList)
            if !to.isEmpty  {
                lists.append(to)
            }
        }
        
        if !ccList.isEmpty {
            let cc = MessageHelper.contactsToAddresses(ccList)
            if !cc.isEmpty  {
                lists.append(cc)
            }
        }
        
        if !bccList.isEmpty {
            let bcc = MessageHelper.contactsToAddresses(bccList)
            if !bcc.isEmpty  {
                lists.append(bcc)
            }
        }
        
        if lists.isEmpty {
            return ""
        }
        
        return ",".join(lists)
    }
    
    var location: MessageLocation {
        get {
            return MessageLocation(rawValue: locationNumber.integerValue) ?? .inbox
        }
        set {
            locationNumber = newValue.rawValue
        }
    }
    
    var subject : String {
        return title //.decodeHtml()
    }
    
    var displaySender : String {
        get {
            return senderName.isEmpty ?  sender : senderName
        }
        
    }
    
    // MARK: - Public methods
    convenience init(context: NSManagedObjectContext) {
        self.init(entity: NSEntityDescription.entityForName(Attributes.entityName, inManagedObjectContext: context)!, insertIntoManagedObjectContext: context)
    }
    
    /// Removes all messages from the store.
    class func deleteAll(inContext context: NSManagedObjectContext) {
        context.deleteAll(Attributes.entityName)
    }
    
    /**
    delete the message from local cache only use the message id
    
    :param: messageID String
    */
    class func deleteMessage(messageID : String) {
        if let context = sharedCoreDataService.mainManagedObjectContext {
            if var message = Message.messageForMessageID(messageID, inManagedObjectContext: context) {
                var labelObjs = message.mutableSetValueForKey("labels")
                labelObjs.removeAllObjects()
                message.setValue(labelObjs, forKey: "labels")
                context.deleteObject(message)
            }
            if let error = context.saveUpstreamIfNeeded() {
                NSLog("\(__FUNCTION__) error: \(error)")
            }
        }
    }
    
    class func deleteLocation(location : MessageLocation) -> Bool{
        if let mContext = sharedCoreDataService.mainManagedObjectContext {
            let fetchRequest = NSFetchRequest(entityName: Message.Attributes.entityName)
            
            if location == .spam || location == .trash {
                var error : NSError?
                fetchRequest.predicate = NSPredicate(format: "%K == %i", Message.Attributes.locationNumber, location.rawValue)
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: Message.Attributes.time, ascending: false)]
                if let oldMessages = mContext.executeFetchRequest(fetchRequest, error: &error) as? [Message] {
                    for message in oldMessages {
                        mContext.deleteObject(message)
                    }
                    if let error = mContext.saveUpstreamIfNeeded() {
                        PMLog.D(" error: \(error)")
                    } else {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    
    class func messageForMessageID(messageID: String, inManagedObjectContext context: NSManagedObjectContext) -> Message? {
        return context.managedObjectWithEntityName(Attributes.entityName, forKey: Attributes.messageID, matchingValue: messageID) as? Message
    }
    
    class func messagesForObjectIDs(objectIDs: [NSManagedObjectID], inManagedObjectContext context: NSManagedObjectContext, error: NSErrorPointer) -> [Message]? {
        return context.managedObjectsWithEntityName(Attributes.entityName, forManagedObjectIDs: objectIDs, error: error) as? [Message]
    }
    
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        replaceNilStringAttributesWithEmptyString()
    }
    
    func updateTag(tag: String) {
        self.tag = tag
        isStarred = tag.rangeOfString(Constants.starredTag) != nil
    }
    
    
    
    // MARK: Public methods
    
    func decryptBody(error: NSErrorPointer?) -> String? {
        return body.decryptMessage(passphrase, error: error)
    }
    
    func decryptBodyIfNeeded(error: NSErrorPointer?) -> String? {
        
        //PMLog.D("\(body)")
        
        if !checkIsEncrypted() {
            return body
        } else {
            var body = decryptBody(error)
            if body == nil {
                return body
            }
            
            if isEncrypted == 8 {
                body = body?.multipartGetHtmlContent () ?? ""
            } else if isEncrypted == 7 {
                body = body?.ln2br() ?? ""
            }
            return body
        }
    }
    
    func encryptBody(body: String, error: NSErrorPointer?) {
        self.body = body.encryptMessage(getAddressID, error: error) ?? "" //body.encryptWithPublicKey(publicKey, error: error) ?? ""
    }
    
    func checkIsEncrypted() -> Bool! {
        let enc_type = EncryptTypes(rawValue: isEncrypted.integerValue) ?? EncryptTypes.Internal
        let checkIsEncrypted:Bool = enc_type.isEncrypted
        return checkIsEncrypted
    }
    
    var encryptType : EncryptTypes! {
        let enc_type = EncryptTypes(rawValue: isEncrypted.integerValue) ?? EncryptTypes.Internal
        return enc_type
    }
    
    var lockType : LockTypes! {
        return self.encryptType.lockType
    }
    
    // MARK: Private variables
    
    private var passphrase: String {
        return sharedUserDataService.mailboxPassword ?? ""
    }
    
    var getAddressID: String {
        if let addressID = addressID {
            if !addressID.isEmpty {
                return addressID;
            }
        } else {
            if let addr_id = sharedUserDataService.userAddresses.getDefaultAddress()?.address_id {
                return addr_id
            }
        }
        
        return ""
    }
    
    //    private var privateKey: String {
    //        return sharedUserDataService.userInfo?.privateKey ?? ""
    //    }
    //
    //    private var publicKey: String {
    //        return sharedUserDataService.userInfo?.publicKey ?? ""
    //    }
    //
    
    
    func copyMessage (copyAtts : Bool) -> Message {
        let message = self
        let newMessage = Message(context: sharedCoreDataService.mainManagedObjectContext!)
        
        newMessage.location = MessageLocation.draft
        newMessage.recipientList = message.recipientList
        newMessage.bccList = message.bccList
        newMessage.ccList = message.ccList
        newMessage.title = message.title
        newMessage.time = NSDate()
        newMessage.body = message.body
        newMessage.isEncrypted = message.isEncrypted
        newMessage.sender = message.sender
        newMessage.senderName = message.senderName
        
        newMessage.orginalTime = message.time
        newMessage.orginalMessageID = message.messageID
        newMessage.expirationOffset = 0
        
        newMessage.addressID = message.addressID
        
        if let error = newMessage.managedObjectContext?.saveUpstreamIfNeeded() {
            PMLog.D("error: \(error)")
        }
        
        
        if copyAtts {
            for (index, attachment) in enumerate(message.attachments) {
                if let att = attachment as? Attachment {
                    let attachment = Attachment(context: newMessage.managedObjectContext!)
                    attachment.attachmentID = "0"
                    attachment.message = newMessage
                    attachment.fileName = att.fileName
                    attachment.mimeType = "image/jpg"
                    attachment.fileData = att.fileData
                    attachment.fileSize = att.fileSize
                    attachment.isTemp = true
                    if let error = attachment.managedObjectContext?.saveUpstreamIfNeeded() {
                        PMLog.D("error: \(error)")
                    }
                    
                }
            }
        }
        
        return newMessage
    }
    
    func fetchDetailIfNeeded(completion: MessageDataService.CompletionFetchDetail) {
        sharedMessageDataService.fetchMessageDetailForMessage(self, completion: completion)
        
    }
    
}

extension String {
    
    public func multipartGetHtmlContent() -> String {
        //PMLog.D(self)
        let textplainType = "text/plain".dataUsingEncoding(NSUTF8StringEncoding)!
        let htmlType = "text/html".dataUsingEncoding(NSUTF8StringEncoding)!
        
        var data = self.dataUsingEncoding(NSUTF8StringEncoding)!
        var len = data.length as Int;
        
        //get boundary=
        let boundarLine = "boundary=".dataUsingEncoding(NSASCIIStringEncoding)!
        let boundaryRange = data.rangeOfData(boundarLine, options: nil, range: NSMakeRange(0, len))
        if boundaryRange.location == NSNotFound {
            return "";
        }
        
        //new len
        len = len - (boundaryRange.location + boundaryRange.length);
        data = data.subdataWithRange(NSMakeRange(boundaryRange.location + boundaryRange.length, len))
        let lineEnd = "\n".dataUsingEncoding(NSASCIIStringEncoding)!;
        let nextLine = data.rangeOfData(lineEnd, options: nil, range: NSMakeRange(0, len))
        if nextLine.location == NSNotFound {
            return "";
        }
        let boundary = data.subdataWithRange(NSMakeRange(0, nextLine.location))
        var boundaryString = NSString(data: boundary, encoding: NSUTF8StringEncoding) as! String
        boundaryString = boundaryString.stringByReplacingOccurrencesOfString("\"", withString: "")
        boundaryString = boundaryString.stringByReplacingOccurrencesOfString("\r", withString: "")
        boundaryString = "--" + boundaryString;
        
        len = len - (nextLine.location + nextLine.length);
        data = data.subdataWithRange(NSMakeRange(nextLine.location + nextLine.length, len))
        
        var html : String = "";
        var plaintext : String = "";
        
        var count = 0;
        let nextBoundaryLine = boundaryString.dataUsingEncoding(NSASCIIStringEncoding)!
        var firstboundaryRange = data.rangeOfData(nextBoundaryLine, options: nil, range: NSMakeRange(0, len))
        
        if firstboundaryRange.location == NSNotFound {
            return "";
        }
        
        while true {
            if count >= 10 {
                break;
            }
            count++;
            len = len - (firstboundaryRange.location + firstboundaryRange.length) - 1;
            data = data.subdataWithRange(NSMakeRange(1 + firstboundaryRange.location + firstboundaryRange.length, len))
            
            if data.subdataWithRange(NSMakeRange(0 , 1)).isEqualToData("-".dataUsingEncoding(NSASCIIStringEncoding)!) {
                break;
            }
            
            var bodyString = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
            
            let ContentEnd = data.rangeOfData(lineEnd, options: nil, range: NSMakeRange(2, len - 2))
            if ContentEnd.location == NSNotFound {
                break
            }
            let ContentType = data.subdataWithRange(NSMakeRange(0, ContentEnd.location))
            len = len - (ContentEnd.location + ContentEnd.length);
            data = data.subdataWithRange(NSMakeRange(ContentEnd.location + ContentEnd.length, len))
            
            bodyString = NSString(data: ContentType, encoding: NSUTF8StringEncoding) as! String
            
            let EncodingEnd = data.rangeOfData(lineEnd, options: nil, range: NSMakeRange(2, len - 2))
            if EncodingEnd.location == NSNotFound {
                break
            }
            let EncodingType = data.subdataWithRange(NSMakeRange(0, EncodingEnd.location))
            len = len - (EncodingEnd.location + EncodingEnd.length);
            data = data.subdataWithRange(NSMakeRange(EncodingEnd.location + EncodingEnd.length, len))
            
            bodyString = NSString(data: EncodingType, encoding: NSUTF8StringEncoding) as! String
            
            var secondboundaryRange = data.rangeOfData(nextBoundaryLine, options: nil, range: NSMakeRange(0, len))
            if secondboundaryRange.location == NSNotFound {
                break
            }
            //get data
            
            var text = data.subdataWithRange(NSMakeRange(1, secondboundaryRange.location - 1))
            let plainFound = ContentType.rangeOfData(textplainType, options: nil, range: NSMakeRange(0, ContentType.length))
            if plainFound.location != NSNotFound {
                plaintext = NSString(data: text, encoding: NSUTF8StringEncoding) as! String;
            }
            
            let htmlFound = ContentType.rangeOfData(htmlType, options: nil, range: NSMakeRange(0, ContentType.length))
            if htmlFound.location != NSNotFound {
                html = NSString(data: text, encoding: NSUTF8StringEncoding) as! String;
            }
            
            
            // check html or plain text
            bodyString = NSString(data: text, encoding: NSUTF8StringEncoding) as! String
            
            firstboundaryRange = secondboundaryRange
        }
        
        return html.isEmpty ? plaintext.ln2br() : html;
    }
    
}


