// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal static let bannerExclamation = ImageAsset(name: "banner_exclamation")
  internal static let envelope = ImageAsset(name: "envelope")
  internal static let fire = ImageAsset(name: "fire")
  internal static let hock = ImageAsset(name: "hock")
  internal static let icBell = ImageAsset(name: "ic-bell")
  internal static let icExclamationCircleFilled = ImageAsset(name: "ic-exclamation-circle-filled")
  internal static let icExclamationTriangle = ImageAsset(name: "ic-exclamation-triangle")
  internal static let lightbulb = ImageAsset(name: "lightbulb")
  internal static let unsubscribe = ImageAsset(name: "unsubscribe")
  internal static let backArrow = ImageAsset(name: "back-arrow")
  internal static let cellExternal = ImageAsset(name: "cell-external")
  internal static let cellRightArrow = ImageAsset(name: "cell_right_arrow")
  internal static let infoIcon = ImageAsset(name: "info_Icon")
  internal static let swipeArchive = ImageAsset(name: "swipe_archive")
  internal static let swipeLabelAs = ImageAsset(name: "swipe_labelAs")
  internal static let swipeMoveTo = ImageAsset(name: "swipe_moveTo")
  internal static let swipeNone = ImageAsset(name: "swipe_none")
  internal static let swipeRead = ImageAsset(name: "swipe_read")
  internal static let swipeSpam = ImageAsset(name: "swipe_spam")
  internal static let swipeStar = ImageAsset(name: "swipe_star")
  internal static let swipeTrash = ImageAsset(name: "swipe_trash")
  internal static let swipeUnread = ImageAsset(name: "swipe_unread")
  internal static let swipeUnstar = ImageAsset(name: "swipe_unstar")
  internal static let interactionStrong = ColorAsset(name: "InteractionStrong")
  internal static let notificationInfo = ColorAsset(name: "NotificationInfo")
  internal static let shadowGeneral5 = ColorAsset(name: "shadowGeneral5")
  internal static let shadowNorm10 = ColorAsset(name: "shadowNorm10")
  internal static let actionBarArchive = ImageAsset(name: "action_bar_archive")
  internal static let actionBarDelete = ImageAsset(name: "action_bar_delete")
  internal static let actionBarLabel = ImageAsset(name: "action_bar_label")
  internal static let actionBarMore = ImageAsset(name: "action_bar_more")
  internal static let actionBarMoveTo = ImageAsset(name: "action_bar_moveTo")
  internal static let actionBarReadUnread = ImageAsset(name: "action_bar_readUnread")
  internal static let actionBarReply = ImageAsset(name: "action_bar_reply")
  internal static let actionBarReplyAll = ImageAsset(name: "action_bar_replyAll")
  internal static let actionBarSpam = ImageAsset(name: "action_bar_spam")
  internal static let actionBarTrash = ImageAsset(name: "action_bar_trash")
  internal static let icClockPaperPlane = ImageAsset(name: "ic-clock-paper-plane")
  internal static let actionSheetArchive = ImageAsset(name: "action_sheet_archive")
  internal static let actionSheetClose = ImageAsset(name: "action_sheet_close")
  internal static let actionSheetContact = ImageAsset(name: "action_sheet_contact")
  internal static let actionSheetCopy = ImageAsset(name: "action_sheet_copy")
  internal static let actionSheetDark = ImageAsset(name: "action_sheet_dark")
  internal static let actionSheetEnvelope = ImageAsset(name: "action_sheet_envelope")
  internal static let actionSheetFolder = ImageAsset(name: "action_sheet_folder")
  internal static let actionSheetHeader = ImageAsset(name: "action_sheet_header")
  internal static let actionSheetHtml = ImageAsset(name: "action_sheet_html")
  internal static let actionSheetLabel = ImageAsset(name: "action_sheet_label")
  internal static let actionSheetLight = ImageAsset(name: "action_sheet_light")
  internal static let actionSheetPhishing = ImageAsset(name: "action_sheet_phishing")
  internal static let actionSheetPrint = ImageAsset(name: "action_sheet_print")
  internal static let actionSheetRead = ImageAsset(name: "action_sheet_read")
  internal static let actionSheetSpam = ImageAsset(name: "action_sheet_spam")
  internal static let actionSheetStar = ImageAsset(name: "action_sheet_star")
  internal static let actionSheetTrash = ImageAsset(name: "action_sheet_trash")
  internal static let actionSheetUnread = ImageAsset(name: "action_sheet_unread")
  internal static let actionSheetUnstar = ImageAsset(name: "action_sheet_unstar")
  internal static let icCamera = ImageAsset(name: "ic-camera")
  internal static let icExport = ImageAsset(name: "ic-export")
  internal static let icPhoto = ImageAsset(name: "ic-photo")
  internal static let signBackgroundNew = ImageAsset(name: "sign_background_new")
  internal static let composeAddcontact = ImageAsset(name: "compose_addcontact")
  internal static let composeAttachmentActive = ImageAsset(name: "compose_attachment-active")
  internal static let composeAttachment = ImageAsset(name: "compose_attachment")
  internal static let composeExpirationActive = ImageAsset(name: "compose_expiration-active")
  internal static let composeExpiration = ImageAsset(name: "compose_expiration")
  internal static let composeExpirationCancel = ImageAsset(name: "compose_expiration_cancel")
  internal static let composeLockActive = ImageAsset(name: "compose_lock-active")
  internal static let composeLock = ImageAsset(name: "compose_lock")
  internal static let composeMinuscontact = ImageAsset(name: "compose_minuscontact")
  internal static let composePluscontact = ImageAsset(name: "compose_pluscontact")
  internal static let composeScheduleStar = ImageAsset(name: "compose_schedule_star")
  internal static let composeSend = ImageAsset(name: "compose_send")
  internal static let icExclamationCircle = ImageAsset(name: "ic-exclamation-circle")
  internal static let icPaperClip = ImageAsset(name: "ic-paper-clip")
  internal static let icLockCheck = ImageAsset(name: "ic_Lock_check")
  internal static let icHourglassCheck = ImageAsset(name: "ic_hourglass_check")
  internal static let icHourglassNoCheck = ImageAsset(name: "ic_hourglass_no_check")
  internal static let icLockNoCkeck = ImageAsset(name: "ic_lock_no_ckeck")
  internal static let icSmallCheckmark = ImageAsset(name: "ic_small_checkmark")
  internal static let iconHourglass = ImageAsset(name: "icon-hourglass")
  internal static let iconLockWide = ImageAsset(name: "icon-lock-wide")
  internal static let groupCircle40px = ImageAsset(name: "Group-circle-40px")
  internal static let mail28px8a8fc6 = ImageAsset(name: "Mail-28px-#8a8fc6")
  internal static let mail28pxFfffff = ImageAsset(name: "Mail-28px-#ffffff")
  internal static let phone28px8a8fc6 = ImageAsset(name: "Phone-28px-#8a8fc6")
  internal static let phone28pxFfffff = ImageAsset(name: "Phone-28px-#ffffff")
  internal static let share28px8a8fc6 = ImageAsset(name: "Share-28px-#8a8fc6")
  internal static let share28pxFfffff = ImageAsset(name: "Share-28px-#ffffff")
  internal static let contactGroupsCheck = ImageAsset(name: "contact_groups_check")
  internal static let contactGroupsContactsTabbar = ImageAsset(name: "contact_groups_contacts_tabbar")
  internal static let contactGroupsContactsTabbarFilled = ImageAsset(name: "contact_groups_contacts_tabbar_filled")
  internal static let contactGroupsGroupsTabbar = ImageAsset(name: "contact_groups_groups_tabbar")
  internal static let contactGroupsGroupsTabbarFilled = ImageAsset(name: "contact_groups_groups_tabbar_filled")
  internal static let contactGroupsIcon = ImageAsset(name: "contact_groups_icon")
  internal static let contactGroupsNew = ImageAsset(name: "contact_groups_new")
  internal static let icContactGroupsFilled = ImageAsset(name: "ic-contact-groups-filled")
  internal static let contactDeviceUpload = ImageAsset(name: "contact_device_upload")
  internal static let contactsNew = ImageAsset(name: "contacts_new")
  internal static let contactsWarnings = ImageAsset(name: "contacts_warnings")
  internal static let internalNormal = ImageAsset(name: "internal_normal")
  internal static let internalSignFailed = ImageAsset(name: "internal_sign_failed")
  internal static let internalTrustedKey = ImageAsset(name: "internal_trusted_key")
  internal static let pgpClearSignFailed = ImageAsset(name: "pgp_clear_sign_failed")
  internal static let pgpEncryptTrustedKey = ImageAsset(name: "pgp_encrypt_trusted_key")
  internal static let pgpEncrypted = ImageAsset(name: "pgp_encrypted")
  internal static let pgpSigned = ImageAsset(name: "pgp_signed")
  internal static let pgpSignedVerified = ImageAsset(name: "pgp_signed_verified")
  internal static let pgpTrustedSignFailed = ImageAsset(name: "pgp_trusted_sign_failed")
  internal static let zeroAccessEncryption = ImageAsset(name: "zero_access_encryption")
  internal static let esIcon = ImageAsset(name: "es-icon")
  internal static let iapEmail = ImageAsset(name: "iap_email")
  internal static let iapFolder = ImageAsset(name: "iap_folder")
  internal static let iapHdd = ImageAsset(name: "iap_hdd")
  internal static let iapLifering = ImageAsset(name: "iap_lifering")
  internal static let iapLink = ImageAsset(name: "iap_link")
  internal static let iapLock = ImageAsset(name: "iap_lock")
  internal static let iapUsers = ImageAsset(name: "iap_users")
  internal static let iapVpn = ImageAsset(name: "iap_vpn")
  internal static let launchScreenBackground = ColorAsset(name: "LaunchScreenBackground")
  internal static let launchScreenMailLogo = ImageAsset(name: "LaunchScreenMailLogo")
  internal static let launchScreenMasterbrand = ImageAsset(name: "LaunchScreenMasterbrand")
  internal static let launchTextColor = ColorAsset(name: "launch_text_color")
  internal static let logo = ImageAsset(name: "Logo")
  internal static let welcomeLogo = ImageAsset(name: "welcome_logo")
  internal static let conversationNotice = ImageAsset(name: "conversationNotice")
  internal static let icUserStorage = ImageAsset(name: "ic-user-storage")
  internal static let mailAlertIcon = ImageAsset(name: "mail_alert_icon")
  internal static let mailAttachmentClosed = ImageAsset(name: "mail_attachment-closed")
  internal static let mailAttachmentDoc = ImageAsset(name: "mail_attachment-doc")
  internal static let mailAttachmentFile = ImageAsset(name: "mail_attachment-file")
  internal static let mailAttachmentJpeg = ImageAsset(name: "mail_attachment-jpeg")
  internal static let mailAttachmentOpen = ImageAsset(name: "mail_attachment-open")
  internal static let mailAttachmentPdf = ImageAsset(name: "mail_attachment-pdf")
  internal static let mailAttachmentPng = ImageAsset(name: "mail_attachment-png")
  internal static let mailAttachmentPpt = ImageAsset(name: "mail_attachment-ppt")
  internal static let mailAttachmentTxt = ImageAsset(name: "mail_attachment-txt")
  internal static let mailAttachmentXls = ImageAsset(name: "mail_attachment-xls")
  internal static let mailAttachmentZip = ImageAsset(name: "mail_attachment-zip")
  internal static let mailAttachment = ImageAsset(name: "mail_attachment")
  internal static let mailAttachmentAudio = ImageAsset(name: "mail_attachment_audio")
  internal static let mailAttachmentFileAudio = ImageAsset(name: "mail_attachment_file_audio")
  internal static let mailAttachmentFileDoc = ImageAsset(name: "mail_attachment_file_doc")
  internal static let mailAttachmentFileGeneral = ImageAsset(name: "mail_attachment_file_general")
  internal static let mailAttachmentFileImage = ImageAsset(name: "mail_attachment_file_image")
  internal static let mailAttachmentFilePdf = ImageAsset(name: "mail_attachment_file_pdf")
  internal static let mailAttachmentFilePpt = ImageAsset(name: "mail_attachment_file_ppt")
  internal static let mailAttachmentFileUnknow = ImageAsset(name: "mail_attachment_file_unknow")
  internal static let mailAttachmentFileVideo = ImageAsset(name: "mail_attachment_file_video")
  internal static let mailAttachmentFileXls = ImageAsset(name: "mail_attachment_file_xls")
  internal static let mailAttachmentFileZip = ImageAsset(name: "mail_attachment_file_zip")
  internal static let mailAttachmentGeneral = ImageAsset(name: "mail_attachment_general")
  internal static let mailAttachmentJpg = ImageAsset(name: "mail_attachment_jpg")
  internal static let mailAttachmentPdfNew = ImageAsset(name: "mail_attachment_pdf_new")
  internal static let mailAttachmentUnknow = ImageAsset(name: "mail_attachment_unknow")
  internal static let mailAttachmentVideo = ImageAsset(name: "mail_attachment_video")
  internal static let mailCalendarIcon = ImageAsset(name: "mail_calendar_icon")
  internal static let mailCheckActive = ImageAsset(name: "mail_check-active")
  internal static let mailCheckNeutral = ImageAsset(name: "mail_check-neutral")
  internal static let mailCheck = ImageAsset(name: "mail_check")
  internal static let mailDownArrow = ImageAsset(name: "mail_down_arrow")
  internal static let mailDownload = ImageAsset(name: "mail_download")
  internal static let mailExpiration = ImageAsset(name: "mail_expiration")
  internal static let mailForwarded = ImageAsset(name: "mail_forwarded")
  internal static let mailLabelCollapsed = ImageAsset(name: "mail_label-collapsed")
  internal static let mailLockOutside = ImageAsset(name: "mail_lock-outside")
  internal static let mailLockPgpmime = ImageAsset(name: "mail_lock-pgpmime")
  internal static let mailLock = ImageAsset(name: "mail_lock")
  internal static let mailLockDark = ImageAsset(name: "mail_lock_dark")
  internal static let mailRemoteContentIcon = ImageAsset(name: "mail_remote_content_icon")
  internal static let mailReplied = ImageAsset(name: "mail_replied")
  internal static let mailRepliedall = ImageAsset(name: "mail_repliedall")
  internal static let mailRightArrow = ImageAsset(name: "mail_right_arrow")
  internal static let mailShowimages = ImageAsset(name: "mail_showimages")
  internal static let mailStarredActiveSmall = ImageAsset(name: "mail_starred-active-small")
  internal static let mailStarredActive = ImageAsset(name: "mail_starred-active")
  internal static let mailStarred = ImageAsset(name: "mail_starred")
  internal static let mailTagIcon = ImageAsset(name: "mail_tag_icon")
  internal static let mailUnlock = ImageAsset(name: "mail_unlock")
  internal static let mailUpArrow = ImageAsset(name: "mail_up_arrow")
  internal static let placeholderBoundBox = ImageAsset(name: "placeholder_bound_box")
  internal static let trackingProtectionSpotlightIcon = ImageAsset(name: "tracking-protection-spotlight-icon")
  internal static let icCircle = ImageAsset(name: "ic-circle")
  internal static let mailAttachmentIcon = ImageAsset(name: "mail_attachment_icon")
  internal static let mailFolderNoResultIcon = ImageAsset(name: "mail_folder_no_result_icon")
  internal static let mailLabelCrossIcon = ImageAsset(name: "mail_label_cross_icon")
  internal static let mailLabelIcon = ImageAsset(name: "mail_label_icon")
  internal static let mailListCellSelectedIcon = ImageAsset(name: "mail_list_cell_selected_icon")
  internal static let mailListExpiration = ImageAsset(name: "mail_list_expiration")
  internal static let mailNoResultIcon = ImageAsset(name: "mail_no_result_icon")
  internal static let mailUnreadIcon = ImageAsset(name: "mail_unread_icon")
  internal static let icFolderPlus = ImageAsset(name: "ic-folder-plus")
  internal static let icLabelAdd = ImageAsset(name: "ic-label-add")
  internal static let menuAllMail = ImageAsset(name: "menu_all_mail")
  internal static let menuArchive = ImageAsset(name: "menu_archive")
  internal static let menuBugs = ImageAsset(name: "menu_bugs")
  internal static let menuContacts = ImageAsset(name: "menu_contacts")
  internal static let menuDraft = ImageAsset(name: "menu_draft")
  internal static let menuFeedbackActive = ImageAsset(name: "menu_feedback-active")
  internal static let menuFeedback = ImageAsset(name: "menu_feedback")
  internal static let menuFeedbackNew = ImageAsset(name: "menu_feedback_new")
  internal static let menuFolder = ImageAsset(name: "menu_folder")
  internal static let menuFolderMultiple = ImageAsset(name: "menu_folder_multiple")
  internal static let menuInbox = ImageAsset(name: "menu_inbox")
  internal static let menuLabel = ImageAsset(name: "menu_label")
  internal static let menuLockApp = ImageAsset(name: "menu_lock_app")
  internal static let menuLogout = ImageAsset(name: "menu_logout")
  internal static let menuPlus = ImageAsset(name: "menu_plus")
  internal static let menuSent = ImageAsset(name: "menu_sent")
  internal static let menuServicePlan = ImageAsset(name: "menu_service_plan")
  internal static let menuSettings = ImageAsset(name: "menu_settings")
  internal static let menuSnoozeActive = ImageAsset(name: "menu_snooze-active")
  internal static let menuSnoozeNone = ImageAsset(name: "menu_snooze-none")
  internal static let menuSnooze = ImageAsset(name: "menu_snooze")
  internal static let menuSpam = ImageAsset(name: "menu_spam")
  internal static let menuStarred = ImageAsset(name: "menu_starred")
  internal static let menuTrash = ImageAsset(name: "menu_trash")
  internal static let mailArchiveIcon = ImageAsset(name: "mail_archive_icon")
  internal static let mailConversationDraft = ImageAsset(name: "mail_conversation_draft")
  internal static let mailCustomFolder = ImageAsset(name: "mail_custom_folder")
  internal static let mailDraftIcon = ImageAsset(name: "mail_draft_icon")
  internal static let mailForward = ImageAsset(name: "mail_forward")
  internal static let mailHourglass = ImageAsset(name: "mail_hourglass")
  internal static let mailInboxIcon = ImageAsset(name: "mail_inbox_icon")
  internal static let mailReply = ImageAsset(name: "mail_reply")
  internal static let mailReplyAll = ImageAsset(name: "mail_reply_all")
  internal static let mailSendIcon = ImageAsset(name: "mail_send_icon")
  internal static let mailSpamIcon = ImageAsset(name: "mail_spam_icon")
  internal static let mailStar = ImageAsset(name: "mail_star")
  internal static let mailTickIcon = ImageAsset(name: "mail_tick_icon")
  internal static let mailTrashIcon = ImageAsset(name: "mail_trash_icon")
  internal static let newMailAttachment = ImageAsset(name: "new_mail_attachment")
  internal static let icArrowOutBox = ImageAsset(name: "ic-arrow-out-box")
  internal static let icMagnifier = ImageAsset(name: "ic-magnifier")
  internal static let icPenSquare = ImageAsset(name: "ic-pen-square")
  internal static let icStarFilled = ImageAsset(name: "ic-star-filled")
  internal static let messageDeatilsStarActive = ImageAsset(name: "message_deatils_star_active")
  internal static let messageDetailsStarInactive = ImageAsset(name: "message_details_star_inactive")
  internal static let messageExpandCollapse = ImageAsset(name: "message_expand_collapse")
  internal static let composeIcon = ImageAsset(name: "compose_icon")
  internal static let searchIcon = ImageAsset(name: "search_icon")
  internal static let topBack = ImageAsset(name: "top_back")
  internal static let topFolder = ImageAsset(name: "top_folder")
  internal static let topLabel = ImageAsset(name: "top_label")
  internal static let topMenu = ImageAsset(name: "top_menu")
  internal static let topMore = ImageAsset(name: "top_more")
  internal static let topTrash = ImageAsset(name: "top_trash")
  internal static let topUnread = ImageAsset(name: "top_unread")
  internal static let arrowDown = ImageAsset(name: "arrow_down")
  internal static let arrowUp = ImageAsset(name: "arrow_up")
  internal static let feedbackContact = ImageAsset(name: "feedback_contact")
  internal static let icInfoCircle = ImageAsset(name: "ic-info-circle")
  internal static let icLockWide = ImageAsset(name: "ic-lock-wide")
  internal static let icThreeDotsHorizontal = ImageAsset(name: "ic-three-dots-horizontal")
  internal static let inboxSelected = ImageAsset(name: "inbox_selected")
  internal static let navSearchIcon = ImageAsset(name: "nav_search_icon")
  internal static let next = ImageAsset(name: "next")
  internal static let nextDisable = ImageAsset(name: "next_disable")
  internal static let pinCodeDel = ImageAsset(name: "pin_code_del")
  internal static let popupBehindImage = ImageAsset(name: "popup_behind_image")
  internal static let replyAllButtonIcon = ImageAsset(name: "reply_all_button_icon")
  internal static let search = ImageAsset(name: "search")
  internal static let signupLogo = ImageAsset(name: "signup_logo")
  internal static let touchIdIcon = ImageAsset(name: "touch_id_icon")
  internal static let upgradeBackground = ImageAsset(name: "upgrade_background")
  internal static let welcome1 = ImageAsset(name: "welcome_1")
  internal static let welcome2 = ImageAsset(name: "welcome_2")
  internal static let welcome3 = ImageAsset(name: "welcome_3")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  #if os(iOS) || os(tvOS)
  @available(iOS 11.0, tvOS 11.0, *)
  internal func color(compatibleWith traitCollection: UITraitCollection) -> Color {
    let bundle = BundleToken.bundle
    guard let color = Color(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}


internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  internal func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif

}

internal extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}


// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type

