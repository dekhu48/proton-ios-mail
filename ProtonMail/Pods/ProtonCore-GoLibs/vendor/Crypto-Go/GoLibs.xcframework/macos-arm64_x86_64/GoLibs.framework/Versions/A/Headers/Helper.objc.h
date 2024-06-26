// Objective-C API for talking to github.com/ProtonMail/gopenpgp/v2/helper Go package.
//   gobind -lang=objc github.com/ProtonMail/gopenpgp/v2/helper
//
// File is generated by gobind. Do not edit.

#ifndef __Helper_H__
#define __Helper_H__

@import Foundation;
#include "ref.h"
#include "Universe.objc.h"

#include "Crypto.objc.h"

@class HelperEncryptSignArmoredDetachedMobileResult;
@class HelperEncryptSignBinaryDetachedMobileResult;
@class HelperExplicitVerifyMessage;
@class HelperGo2AndroidReader;
@class HelperGo2IOSReader;
@class HelperMobile2GoReader;
@class HelperMobile2GoWriter;
@class HelperMobile2GoWriterWithSHA256;
@class HelperMobileReadResult;
@protocol HelperMobileReader;
@class HelperMobileReader;

@protocol HelperMobileReader <NSObject>
- (HelperMobileReadResult* _Nullable)read:(long)max error:(NSError* _Nullable* _Nullable)error;
@end

@interface HelperEncryptSignArmoredDetachedMobileResult : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
@property (nonatomic) NSString* _Nonnull ciphertextArmored;
@property (nonatomic) NSString* _Nonnull encryptedSignatureArmored;
@end

@interface HelperEncryptSignBinaryDetachedMobileResult : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
@property (nonatomic) NSData* _Nullable encryptedData;
@property (nonatomic) NSString* _Nonnull encryptedSignatureArmored;
@end

@interface HelperExplicitVerifyMessage : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
@property (nonatomic) CryptoPlainMessage* _Nullable message;
@property (nonatomic) CryptoSignatureVerificationError* _Nullable signatureVerificationError;
@end

/**
 * Go2AndroidReader is used to wrap a native golang Reader in the golang runtime,
to be usable in the android app runtime (via gomobile).
 */
@interface HelperGo2AndroidReader : NSObject <goSeqRefInterface, CryptoReader> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
/**
 * NewGo2AndroidReader wraps a native golang Reader to be usable in the mobile app runtime (via gomobile).
It doesn't follow the standard golang Reader behavior, and returns n = -1 on EOF.
 */
- (nullable instancetype)init:(id<CryptoReader> _Nullable)reader;
/**
 * Read reads bytes into the provided buffer and returns the number of bytes read
It doesn't follow the standard golang Reader behavior, and returns n = -1 on EOF.
 */
- (BOOL)read:(NSData* _Nullable)b n:(long* _Nullable)n error:(NSError* _Nullable* _Nullable)error;
@end

/**
 * Go2IOSReader is used to wrap a native golang Reader in the golang runtime,
to be usable in the iOS app runtime (via gomobile) as a MobileReader.
 */
@interface HelperGo2IOSReader : NSObject <goSeqRefInterface, HelperMobileReader> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
/**
 * NewGo2IOSReader wraps a native golang Reader to be usable in the ios app runtime (via gomobile).
 */
- (nullable instancetype)init:(id<CryptoReader> _Nullable)reader;
/**
 * Read reads at most <max> bytes from the wrapped Reader and returns the read data as a MobileReadResult.
 */
- (HelperMobileReadResult* _Nullable)read:(long)max error:(NSError* _Nullable* _Nullable)error;
@end

/**
 * Mobile2GoReader is used to wrap a MobileReader in the mobile app runtime,
to be usable in the golang runtime (via gomobile) as a native Reader.
 */
@interface HelperMobile2GoReader : NSObject <goSeqRefInterface, CryptoReader> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
/**
 * NewMobile2GoReader wraps a MobileReader to be usable in the golang runtime (via gomobile).
 */
- (nullable instancetype)init:(id<HelperMobileReader> _Nullable)reader;
/**
 * Read reads data from the wrapped MobileReader and copies the read data in the provided buffer.
It also handles the conversion of EOF to an error.
 */
- (BOOL)read:(NSData* _Nullable)b n:(long* _Nullable)n error:(NSError* _Nullable* _Nullable)error;
@end

/**
 * Mobile2GoWriter is used to wrap a writer in the mobile app runtime,
to be usable in the golang runtime (via gomobile).
 */
@interface HelperMobile2GoWriter : NSObject <goSeqRefInterface, CryptoWriter> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
/**
 * NewMobile2GoWriter wraps a writer to be usable in the golang runtime (via gomobile).
 */
- (nullable instancetype)init:(id<CryptoWriter> _Nullable)writer;
/**
 * Write writes the data in the provided buffer in the wrapped writer.
It clones the provided data to prevent errors with garbage collectors.
 */
- (BOOL)write:(NSData* _Nullable)b n:(long* _Nullable)n error:(NSError* _Nullable* _Nullable)error;
@end

/**
 * Mobile2GoWriterWithSHA256 is used to wrap a writer in the mobile app runtime,
to be usable in the golang runtime (via gomobile).
It also computes the SHA256 hash of the data being written on the fly.
 */
@interface HelperMobile2GoWriterWithSHA256 : NSObject <goSeqRefInterface, CryptoWriter> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
/**
 * NewMobile2GoWriterWithSHA256 wraps a writer to be usable in the golang runtime (via gomobile).
The wrapper also computes the SHA256 hash of the data being written on the fly.
 */
- (nullable instancetype)init:(id<CryptoWriter> _Nullable)writer;
/**
 * GetSHA256 returns the SHA256 hash of the data that's been written so far.
 */
- (NSData* _Nullable)getSHA256;
/**
 * Write writes the data in the provided buffer in the wrapped writer.
It clones the provided data to prevent errors with garbage collectors.
It also computes the SHA256 hash of the data being written on the fly.
 */
- (BOOL)write:(NSData* _Nullable)b n:(long* _Nullable)n error:(NSError* _Nullable* _Nullable)error;
@end

/**
 * MobileReadResult is what needs to be returned by MobileReader.Read.
The read data is passed as a return value rather than passed as an argument to the reader.
This avoids problems introduced by gomobile that prevent the use of native golang readers.
 */
@interface HelperMobileReadResult : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
/**
 * NewMobileReadResult initialize a MobileReadResult with the correct values.
It clones the data to avoid the garbage collector freeing the data too early.
 */
- (nullable instancetype)init:(long)n eof:(BOOL)eof data:(NSData* _Nullable)data;
@property (nonatomic) long n;
@property (nonatomic) BOOL isEOF;
@property (nonatomic) NSData* _Nullable data;
@end

FOUNDATION_EXPORT const int64_t HelperAES_BLOCK_SIZE;

/**
 * DecryptAttachment takes a keypacket and datpacket
and returns a decrypted PlainMessage
Specifically designed for attachments rather than text messages.
 */
FOUNDATION_EXPORT CryptoPlainMessage* _Nullable HelperDecryptAttachment(NSData* _Nullable keyPacket, NSData* _Nullable dataPacket, CryptoKeyRing* _Nullable keyRing, NSError* _Nullable* _Nullable error);

/**
 * DecryptAttachmentWithKey decrypts a binary file
Using a given armored private key and its passphrase.
 */
FOUNDATION_EXPORT NSData* _Nullable HelperDecryptAttachmentWithKey(NSString* _Nullable privateKey, NSData* _Nullable passphrase, NSData* _Nullable keyPacket, NSData* _Nullable dataPacket, NSError* _Nullable* _Nullable error);

/**
 * DecryptBinaryMessageArmored decrypts an armored PGP message given a private key
and its passphrase.
 */
FOUNDATION_EXPORT NSData* _Nullable HelperDecryptBinaryMessageArmored(NSString* _Nullable privateKey, NSData* _Nullable passphrase, NSString* _Nullable ciphertext, NSError* _Nullable* _Nullable error);

/**
 * DecryptExplicitVerify decrypts a PGP message given a private keyring
and a public keyring to verify the embedded signature. Returns the plain
data and an error on signature verification failure.
 */
FOUNDATION_EXPORT HelperExplicitVerifyMessage* _Nullable HelperDecryptExplicitVerify(CryptoPGPMessage* _Nullable pgpMessage, CryptoKeyRing* _Nullable privateKeyRing, CryptoKeyRing* _Nullable publicKeyRing, int64_t verifyTime, NSError* _Nullable* _Nullable error);

/**
 * DecryptExplicitVerifyWithContext decrypts a PGP message given a private keyring
and a public keyring to verify the embedded signature. Returns the plain
data and an error on signature verification failure.
The caller can provide a context that will be used to verify the signature.
 */
FOUNDATION_EXPORT HelperExplicitVerifyMessage* _Nullable HelperDecryptExplicitVerifyWithContext(CryptoPGPMessage* _Nullable pgpMessage, CryptoKeyRing* _Nullable privateKeyRing, CryptoKeyRing* _Nullable publicKeyRing, int64_t verifyTime, CryptoVerificationContext* _Nullable verificationContext, NSError* _Nullable* _Nullable error);

/**
 * DecryptMessageArmored decrypts an armored PGP message given a private key
and its passphrase.
 */
FOUNDATION_EXPORT NSString* _Nonnull HelperDecryptMessageArmored(NSString* _Nullable privateKey, NSData* _Nullable passphrase, NSString* _Nullable ciphertext, NSError* _Nullable* _Nullable error);

/**
 * DecryptMessageWithPassword decrypts an armored message with a random token.
The algorithm is derived from the armoring.
 */
FOUNDATION_EXPORT NSString* _Nonnull HelperDecryptMessageWithPassword(NSData* _Nullable password, NSString* _Nullable ciphertext, NSError* _Nullable* _Nullable error);

/**
 * DecryptSessionKey decrypts a session key
using a given armored private key
and its passphrase.
 */
FOUNDATION_EXPORT CryptoSessionKey* _Nullable HelperDecryptSessionKey(NSString* _Nullable privateKey, NSData* _Nullable passphrase, NSData* _Nullable encryptedSessionKey, NSError* _Nullable* _Nullable error);

/**
 * DecryptSessionKeyExplicitVerify decrypts a PGP data packet given a session key
and a public keyring to verify the embedded signature. Returns the plain data and
an error on signature verification failure.
 */
FOUNDATION_EXPORT HelperExplicitVerifyMessage* _Nullable HelperDecryptSessionKeyExplicitVerify(NSData* _Nullable dataPacket, CryptoSessionKey* _Nullable sessionKey, CryptoKeyRing* _Nullable publicKeyRing, int64_t verifyTime, NSError* _Nullable* _Nullable error);

/**
 * DecryptSessionKeyExplicitVerifyWithContext decrypts a PGP data packet given a session key
and a public keyring to verify the embedded signature. Returns the plain data and
an error on signature verification failure.
The caller can provide a context that will be used to verify the signature.
 */
FOUNDATION_EXPORT HelperExplicitVerifyMessage* _Nullable HelperDecryptSessionKeyExplicitVerifyWithContext(NSData* _Nullable dataPacket, CryptoSessionKey* _Nullable sessionKey, CryptoKeyRing* _Nullable publicKeyRing, int64_t verifyTime, CryptoVerificationContext* _Nullable verificationContext, NSError* _Nullable* _Nullable error);

/**
 * DecryptVerifyArmoredDetached decrypts an armored pgp message
and verify a detached armored encrypted signature
given a publicKey, and a privateKey with its passphrase.
Returns the plain data or an error on
signature verification failure.
 */
FOUNDATION_EXPORT NSData* _Nullable HelperDecryptVerifyArmoredDetached(NSString* _Nullable publicKey, NSString* _Nullable privateKey, NSData* _Nullable passphrase, NSString* _Nullable ciphertextArmored, NSString* _Nullable encryptedSignatureArmored, NSError* _Nullable* _Nullable error);

/**
 * DecryptVerifyAttachment decrypts and verifies an attachment split into the
keyPacket, dataPacket and an armored (!) signature, given a publicKey, and a
privateKey with its passphrase. Returns the plain data or an error on
signature verification failure.
 */
FOUNDATION_EXPORT NSData* _Nullable HelperDecryptVerifyAttachment(NSString* _Nullable publicKey, NSString* _Nullable privateKey, NSData* _Nullable passphrase, NSData* _Nullable keyPacket, NSData* _Nullable dataPacket, NSString* _Nullable armoredSignature, NSError* _Nullable* _Nullable error);

/**
 * DecryptVerifyBinaryDetached decrypts binary encrypted data
and verify a detached armored encrypted signature
given a publicKey, and a privateKey with its passphrase.
Returns the plain data or an error on
signature verification failure.
 */
FOUNDATION_EXPORT NSData* _Nullable HelperDecryptVerifyBinaryDetached(NSString* _Nullable publicKey, NSString* _Nullable privateKey, NSData* _Nullable passphrase, NSData* _Nullable encryptedData, NSString* _Nullable encryptedSignatureArmored, NSError* _Nullable* _Nullable error);

/**
 * DecryptVerifyMessageArmored decrypts an armored PGP message given a private
key and its passphrase and verifies the embedded signature. Returns the
plain data or an error on signature verification failure.
 */
FOUNDATION_EXPORT NSString* _Nonnull HelperDecryptVerifyMessageArmored(NSString* _Nullable publicKey, NSString* _Nullable privateKey, NSData* _Nullable passphrase, NSString* _Nullable ciphertext, NSError* _Nullable* _Nullable error);

/**
 * EncryptAttachment encrypts a file given a plainData and a fileName.
Returns a PGPSplitMessage containing a session key packet and symmetrically
encrypted data. Specifically designed for attachments rather than text
messages.
 */
FOUNDATION_EXPORT CryptoPGPSplitMessage* _Nullable HelperEncryptAttachment(NSData* _Nullable plainData, NSString* _Nullable filename, CryptoKeyRing* _Nullable keyRing, NSError* _Nullable* _Nullable error);

/**
 * EncryptAttachmentWithKey encrypts a binary file
Using a given armored public key.
 */
FOUNDATION_EXPORT CryptoPGPSplitMessage* _Nullable HelperEncryptAttachmentWithKey(NSString* _Nullable publicKey, NSString* _Nullable filename, NSData* _Nullable plainData, NSError* _Nullable* _Nullable error);

/**
 * EncryptBinaryMessageArmored generates an armored PGP message given a binary data and
an armored public key.
 */
FOUNDATION_EXPORT NSString* _Nonnull HelperEncryptBinaryMessageArmored(NSString* _Nullable key, NSData* _Nullable data, NSError* _Nullable* _Nullable error);

/**
 * EncryptMessageArmored generates an armored PGP message given a plaintext and
an armored public key.
 */
FOUNDATION_EXPORT NSString* _Nonnull HelperEncryptMessageArmored(NSString* _Nullable key, NSString* _Nullable plaintext, NSError* _Nullable* _Nullable error);

/**
 * EncryptMessageWithPassword encrypts a string with a passphrase using AES256.
 */
FOUNDATION_EXPORT NSString* _Nonnull HelperEncryptMessageWithPassword(NSData* _Nullable password, NSString* _Nullable plaintext, NSError* _Nullable* _Nullable error);

/**
 * EncryptPGPMessageToAdditionalKey decrypts the session key of the input PGPSplitMessage with a private key in keyRing
and encrypts it towards the additionalKeys by adding the additional key packets to the input PGPSplitMessage.
If successful, new key packets are added to message.
* messageToModify : The encrypted pgp message that should be modified
* keyRing         : The private keys to decrypt the session key in the messageToModify.
* additionalKey   : The public keys the message should be additionally encrypted to.
 */
FOUNDATION_EXPORT BOOL HelperEncryptPGPMessageToAdditionalKey(CryptoPGPSplitMessage* _Nullable messageToModify, CryptoKeyRing* _Nullable keyRing, CryptoKeyRing* _Nullable additionalKey, NSError* _Nullable* _Nullable error);

/**
 * EncryptSessionKey encrypts a session key
using a given armored public key.
 */
FOUNDATION_EXPORT NSData* _Nullable HelperEncryptSessionKey(NSString* _Nullable publicKey, CryptoSessionKey* _Nullable sessionKey, NSError* _Nullable* _Nullable error);

/**
 * EncryptSignArmoredDetachedMobile wraps the encryptSignArmoredDetached method
to have only one return argument for mobile.
 */
FOUNDATION_EXPORT HelperEncryptSignArmoredDetachedMobileResult* _Nullable HelperEncryptSignArmoredDetachedMobile(NSString* _Nullable publicKey, NSString* _Nullable privateKey, NSData* _Nullable passphrase, NSData* _Nullable plainData, NSError* _Nullable* _Nullable error);

/**
 * EncryptSignBinaryDetachedMobile wraps the encryptSignBinaryDetached method
to have only one return argument for mobile.
 */
FOUNDATION_EXPORT HelperEncryptSignBinaryDetachedMobileResult* _Nullable HelperEncryptSignBinaryDetachedMobile(NSString* _Nullable publicKey, NSString* _Nullable privateKey, NSData* _Nullable passphrase, NSData* _Nullable plainData, NSError* _Nullable* _Nullable error);

/**
 * EncryptSignMessageArmored generates an armored signed PGP message given a
plaintext and an armored public key a private key and its passphrase.
 */
FOUNDATION_EXPORT NSString* _Nonnull HelperEncryptSignMessageArmored(NSString* _Nullable publicKey, NSString* _Nullable privateKey, NSData* _Nullable passphrase, NSString* _Nullable plaintext, NSError* _Nullable* _Nullable error);

/**
 * FreeOSMemory can be used to explicitly
call the garbage collector and
return the unused memory to the OS.
 */
FOUNDATION_EXPORT void HelperFreeOSMemory(void);

/**
 * GenerateKey generates a key of the given keyType ("rsa" or "x25519"), encrypts it, and returns an armored string.
If keyType is "rsa", bits is the RSA bitsize of the key.
If keyType is "x25519" bits is unused.
 */
FOUNDATION_EXPORT NSString* _Nonnull HelperGenerateKey(NSString* _Nullable name, NSString* _Nullable email, NSData* _Nullable passphrase, NSString* _Nullable keyType, long bits, NSError* _Nullable* _Nullable error);

/**
 * GetJsonSHA256Fingerprints returns the SHA256 fingeprints of key and subkeys,
encoded in JSON, since gomobile can not handle arrays.
 */
FOUNDATION_EXPORT NSData* _Nullable HelperGetJsonSHA256Fingerprints(NSString* _Nullable publicKey, NSError* _Nullable* _Nullable error);

// skipped function GetSHA256Fingerprints with unsupported parameter or return types


/**
 * NewGo2AndroidReader wraps a native golang Reader to be usable in the mobile app runtime (via gomobile).
It doesn't follow the standard golang Reader behavior, and returns n = -1 on EOF.
 */
FOUNDATION_EXPORT HelperGo2AndroidReader* _Nullable HelperNewGo2AndroidReader(id<CryptoReader> _Nullable reader);

/**
 * NewGo2IOSReader wraps a native golang Reader to be usable in the ios app runtime (via gomobile).
 */
FOUNDATION_EXPORT HelperGo2IOSReader* _Nullable HelperNewGo2IOSReader(id<CryptoReader> _Nullable reader);

/**
 * NewMobile2GoReader wraps a MobileReader to be usable in the golang runtime (via gomobile).
 */
FOUNDATION_EXPORT HelperMobile2GoReader* _Nullable HelperNewMobile2GoReader(id<HelperMobileReader> _Nullable reader);

/**
 * NewMobile2GoWriter wraps a writer to be usable in the golang runtime (via gomobile).
 */
FOUNDATION_EXPORT HelperMobile2GoWriter* _Nullable HelperNewMobile2GoWriter(id<CryptoWriter> _Nullable writer);

/**
 * NewMobile2GoWriterWithSHA256 wraps a writer to be usable in the golang runtime (via gomobile).
The wrapper also computes the SHA256 hash of the data being written on the fly.
 */
FOUNDATION_EXPORT HelperMobile2GoWriterWithSHA256* _Nullable HelperNewMobile2GoWriterWithSHA256(id<CryptoWriter> _Nullable writer);

/**
 * NewMobileReadResult initialize a MobileReadResult with the correct values.
It clones the data to avoid the garbage collector freeing the data too early.
 */
FOUNDATION_EXPORT HelperMobileReadResult* _Nullable HelperNewMobileReadResult(long n, BOOL eof, NSData* _Nullable data);

/**
 * QuickCheckDecrypt checks with high probability if the provided session key
can decrypt the encrypted data packet given its 24 byte long prefix.
The method only considers the first 24 bytes of the prefix slice (prefix[:24]).
NOTE: Only works for SEIPDv1 packets with AES.
 */
FOUNDATION_EXPORT BOOL HelperQuickCheckDecrypt(CryptoSessionKey* _Nullable sessionKey, NSData* _Nullable prefix, BOOL* _Nullable ret0_, NSError* _Nullable* _Nullable error);

/**
 * QuickCheckDecryptReader checks with high probability if the provided session key
can decrypt a data packet given its 24 byte long prefix.
The method reads up to but not exactly 24 bytes from the prefixReader.
NOTE: Only works for SEIPDv1 packets with AES.
 */
FOUNDATION_EXPORT BOOL HelperQuickCheckDecryptReader(CryptoSessionKey* _Nullable sessionKey, id<CryptoReader> _Nullable prefixReader, BOOL* _Nullable ret0_, NSError* _Nullable* _Nullable error);

/**
 * SignCleartextMessage signs text given a private keyring, canonicalizes and
trims the newlines, and returns the PGP-compliant special armoring.
 */
FOUNDATION_EXPORT NSString* _Nonnull HelperSignCleartextMessage(CryptoKeyRing* _Nullable keyRing, NSString* _Nullable text, NSError* _Nullable* _Nullable error);

/**
 * SignCleartextMessageArmored signs text given a private key and its
passphrase, canonicalizes and trims the newlines, and returns the
PGP-compliant special armoring.
 */
FOUNDATION_EXPORT NSString* _Nonnull HelperSignCleartextMessageArmored(NSString* _Nullable privateKey, NSData* _Nullable passphrase, NSString* _Nullable text, NSError* _Nullable* _Nullable error);

/**
 * UpdatePrivateKeyPassphrase decrypts the given armored privateKey with oldPassphrase,
re-encrypts it with newPassphrase, and returns the new armored key.
 */
FOUNDATION_EXPORT NSString* _Nonnull HelperUpdatePrivateKeyPassphrase(NSString* _Nullable privateKey, NSData* _Nullable oldPassphrase, NSData* _Nullable newPassphrase, NSError* _Nullable* _Nullable error);

/**
 * VerifyCleartextMessage verifies PGP-compliant armored signed plain text
given the public keyring and returns the text or err if the verification
fails.
 */
FOUNDATION_EXPORT NSString* _Nonnull HelperVerifyCleartextMessage(CryptoKeyRing* _Nullable keyRing, NSString* _Nullable armored, int64_t verifyTime, NSError* _Nullable* _Nullable error);

/**
 * VerifyCleartextMessageArmored verifies PGP-compliant armored signed plain
text given the public key and returns the text or err if the verification
fails.
 */
FOUNDATION_EXPORT NSString* _Nonnull HelperVerifyCleartextMessageArmored(NSString* _Nullable publicKey, NSString* _Nullable armored, int64_t verifyTime, NSError* _Nullable* _Nullable error);

/**
 * VerifySignatureExplicit calls the reader's VerifySignature()
and tries to cast the returned error to a SignatureVerificationError.
 */
FOUNDATION_EXPORT CryptoSignatureVerificationError* _Nullable HelperVerifySignatureExplicit(CryptoPlainMessageReader* _Nullable reader, NSError* _Nullable* _Nullable error);

@class HelperMobileReader;

/**
 * MobileReader is the interface that readers in the mobile runtime must use and implement.
This is a workaround to some of the gomobile limitations.
 */
@interface HelperMobileReader : NSObject <goSeqRefInterface, HelperMobileReader> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (HelperMobileReadResult* _Nullable)read:(long)max error:(NSError* _Nullable* _Nullable)error;
@end

#endif
