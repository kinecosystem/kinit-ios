//
// BIEvents.swift
//
// Don't edit this file.
// Generated at 2018-11-08 09:52:53 +0000 by Kik BI-Generator.
//

protocol BIEvent {
    var name: String { get }
    var properties: [String: Any] { get }
}

extension BIEvent {
    var properties: [String: Any] {
        return [:]
    }
}

struct Events {
    struct UserProperties { 
        static let balance = "balance" 
        static let earnCount = "earn_count" 
        static let pushEnabled = "push_enabled" 
        static let referralSource = "referral_source" 
        static let spendCount = "spend_count" 
        static let totalKinEarned = "total_KIN_earned" 
        static let totalKinSpent = "total_KIN_spent" 
        static let transactionCount = "transaction_count" 
    }
    
    enum Platform: String { 
        case android = "Android"
        case ios = "iOS"
        case web = "Web"
    }
    
    enum PushEnabled: String { 
        case no = "false"
        case yes = "true"
    }
    
    enum EventType: String { 
        case analytics = "analytics"
        case business = "business"
        case log = "log"
    }
    
    enum Action: String { 
        case click = "click"
        case view = "view"
    }
    
    enum ItemType: String { 
        case alert = "alert"
        case button = "button"
        case card = "card"
        case dropdown = "dropdown"
        case filter = "filter"
        case image = "image"
        case item = "item"
        case link = "link"
        case message = "message"
        case page = "page"
        case popup = "popup"
        case push = "push"
        case tab = "tab"
        case text = "text"
        case tooltip = "tooltip"
        case widget = "widget"
    }
    
    enum ParentType: String { 
        case alert = "alert"
        case button = "button"
        case card = "card"
        case dropdown = "dropdown"
        case filter = "filter"
        case image = "image"
        case item = "item"
        case link = "link"
        case message = "message"
        case page = "page"
        case popup = "popup"
        case push = "push"
        case tab = "tab"
        case text = "text"
        case tooltip = "tooltip"
        case widget = "widget"
    }
    
    enum TransactionType: String { 
        case earn = "earn"
        case p2p = "p2p"
        case spend = "spend"
    }
    
    enum TaskType: String { 
        case inviteFriend = "invite_friend"
        case questionnaire = "questionnaire"
        case quiz = "quiz"
        case truex = "truex"
        case videoQuestionnaire = "video_questionnaire"
    }
    
    enum MenuItemName: String { 
        case balance = "Balance"
        case earn = "Earn"
        case more = "More"
        case spend = "Spend"
    }
    
    enum QuestionType: String { 
        case dualImage = "dual-image"
        case text = "text"
        case textEmoji = "text-emoji"
        case textImage = "text-image"
        case textMultiple = "text-multiple"
        case tip = "tip"
    }
    
    enum ErrorType: String { 
        case codeNotProvided = "Code not provided"
        case exceedExistingKin = "Exceed existing Kin"
        case exceedMaxOrMinKin = "Exceed max/min Kin"
        case friendNotExists = "Friend not exists"
        case internetConnection = "Internet Connection"
        case offerNotAvailable = "Offer not available"
        case onboarding = "Onboarding"
        case reward = "Reward"
        case sendKinToSelf = "Send Kin to self"
        case taskSubmission = "Task Submission"
    }
    
    enum BackupFlowStep: String { 
        case emailConfirmation = "Email confirmation"
        case securityQuestion1 = "Security question 1"
        case securityQuestion2 = "Security question 2"
        case securityQuestionsConfirmation = "Security questions confirmation"
        case sendEmail = "Send Email"
    }
    
    enum BackupNotificationType: String { 
        case day1 = "Day 1"
        case day14 = "Day 14"
        case day30 = "Day 30"
        case day7 = "Day 7"
    }
    
    enum AlreadyBackedUp: String { 
        case no = "No"
        case yes = "Yes"
    }
    
    
    struct Log { 
        /// An error occurred while updating the user's balance using the client blockchain sdk (on app launch, after task completion, after purchase). Event name: `balance_update_failed`
        struct BalanceUpdateFailed: BIEvent {
            let name = "balance_update_failed"
            let failureReason: String
            
            var properties: [String: Any] {
                return [
                        "event_type": "log",
                        
                        
                        "failure_reason": failureReason, 
                        ]
            }
        } 
        /// An error occured while creating the stellar account or when funding it with lumens. Event name: `stellar_account_creation_failed`
        struct StellarAccountCreationFailed: BIEvent {
            let name = "stellar_account_creation_failed"
            let failureReason: String
            
            var properties: [String: Any] {
                return [
                        "event_type": "log",
                        
                        
                        "failure_reason": failureReason, 
                        ]
            }
        } 
        /// Our server created the stellar account successfully and funded it with lumens. Event name: `stellar_account_creation_succeeded`
        struct StellarAccountCreationSucceeded: BIEvent {
            let name = "stellar_account_creation_succeeded"
            
            var properties: [String: Any] {
                return [
                        "event_type": "log",
                        
                        ]
            }
        } 
        /// An error occurred while activating the client account using client blockchain sdk. Event name: `stellar_kin_trustline_setup_failed`
        struct StellarKinTrustlineSetupFailed: BIEvent {
            let name = "stellar_kin_trustline_setup_failed"
            let failureReason: String
            
            var properties: [String: Any] {
                return [
                        "event_type": "log",
                        
                        
                        "failure_reason": failureReason, 
                        ]
            }
        } 
        /// Client successfully activated the account using client blockchain sdk. Event name: `stellar_kin_trustline_setup_succeeded`
        struct StellarKinTrustlineSetupSucceeded: BIEvent {
            let name = "stellar_kin_trustline_setup_succeeded"
            
            var properties: [String: Any] {
                return [
                        "event_type": "log",
                        
                        ]
            }
        } 
        /// User registration failed. Event name: `user_registration_failed`
        struct UserRegistrationFailed: BIEvent {
            let name = "user_registration_failed"
            let failureReason: String
            
            var properties: [String: Any] {
                return [
                        "event_type": "log",
                        
                        
                        "failure_reason": failureReason, 
                        ]
            }
        } 
        /// When formatting of the phone inserted by the user when validating fails. Event name: `phone_formatting_failed`
        struct PhoneFormattingFailed: BIEvent {
            let name = "phone_formatting_failed"
            
            var properties: [String: Any] {
                return [
                        "event_type": "log",
                        
                        ]
            }
        } 
        /// When server sends the auth token via push, and the client receives it.. Event name: `auth_token_received`
        struct AuthTokenReceived: BIEvent {
            let name = "auth_token_received"
            
            var properties: [String: Any] {
                return [
                        "event_type": "log",
                        
                        ]
            }
        } 
        /// When asking the auth token to the server fails.. Event name: `auth_token_ack_failed`
        struct AuthTokenAckFailed: BIEvent {
            let name = "auth_token_ack_failed"
            let failureReason: String
            
            var properties: [String: Any] {
                return [
                        "event_type": "log",
                        
                        
                        "failure_reason": failureReason, 
                        ]
            }
        } 
        /// When captcha fails or is cancelled . Event name: `captcha_failed`
        struct CaptchaFailed: BIEvent {
            let name = "captcha_failed"
            let failureReason: String
            
            var properties: [String: Any] {
                return [
                        "event_type": "log",
                        
                        
                        "failure_reason": failureReason, 
                        ]
            }
        } 
    } 
    struct Business { 
        /// user completes a task (e.g. answered all questionnaire's Qs). Event name: `earning_task_completed`
        struct EarningTaskCompleted: BIEvent {
            let name = "earning_task_completed"
            let creator: String
            let estimatedTimeToComplete: Float
            let kinReward: Int
            let taskCategory: String
            let taskId: String
            let taskTitle: String
            let taskType: TaskType
            
            var properties: [String: Any] {
                return [
                        "event_type": "business",
                        
                        
                        "creator": creator,
                        "estimated_time_to_complete": estimatedTimeToComplete,
                        "KIN_reward": kinReward,
                        "task_category": taskCategory,
                        "task_id": taskId,
                        "task_title": taskTitle,
                        "task_type": taskType.rawValue, 
                        ]
            }
        } 
        /// user starts a task to earn KIN. Event name: `earning_task_started`
        struct EarningTaskStarted: BIEvent {
            let name = "earning_task_started"
            let creator: String
            let estimatedTimeToComplete: Float
            let kinReward: Int
            let taskCategory: String
            let taskId: String
            let taskTitle: String
            let taskType: TaskType
            
            var properties: [String: Any] {
                return [
                        "event_type": "business",
                        
                        
                        "creator": creator,
                        "estimated_time_to_complete": estimatedTimeToComplete,
                        "KIN_reward": kinReward,
                        "task_category": taskCategory,
                        "task_id": taskId,
                        "task_title": taskTitle,
                        "task_type": taskType.rawValue, 
                        ]
            }
        } 
        /// KIN transaction failure. Event name: `KIN_transaction_failed`
        struct KINTransactionFailed: BIEvent {
            let name = "KIN_transaction_failed"
            let failureReason: String
            let kinAmount: Float
            let transactionType: TransactionType
            
            var properties: [String: Any] {
                return [
                        "event_type": "business",
                        
                        
                        "failure_reason": failureReason,
                        "KIN_amount": kinAmount,
                        "transaction_type": transactionType.rawValue, 
                        ]
            }
        } 
        /// successful KIN transaction (send / receive). Event name: `KIN_transaction_succeeded`
        struct KINTransactionSucceeded: BIEvent {
            let name = "KIN_transaction_succeeded"
            let kinAmount: Float
            let transactionId: String
            let transactionType: TransactionType
            
            var properties: [String: Any] {
                return [
                        "event_type": "business",
                        
                        
                        "KIN_amount": kinAmount,
                        "transaction_id": transactionId,
                        "transaction_type": transactionType.rawValue, 
                        ]
            }
        } 
        /// user receives the spending offer he purchased (e.g. coupon code) . Event name: `spending_offer_provided`
        struct SpendingOfferProvided: BIEvent {
            let name = "spending_offer_provided"
            let brandName: String
            let kinPrice: Int
            let offerCategory: String
            let offerId: String
            let offerName: String
            let offerType: String
            
            var properties: [String: Any] {
                return [
                        "event_type": "business",
                        
                        
                        "brand_name": brandName,
                        "KIN_price": kinPrice,
                        "offer_category": offerCategory,
                        "offer_id": offerId,
                        "offer_name": offerName,
                        "offer_type": offerType, 
                        ]
            }
        } 
        /// user purchases a spending offer. Event name: `spending_offer_requested`
        struct SpendingOfferRequested: BIEvent {
            let name = "spending_offer_requested"
            let brandName: String
            let kinPrice: Int
            let offerCategory: String
            let offerId: String
            let offerName: String
            let offerType: String
            
            var properties: [String: Any] {
                return [
                        "event_type": "business",
                        
                        
                        "brand_name": brandName,
                        "KIN_price": kinPrice,
                        "offer_category": offerCategory,
                        "offer_id": offerId,
                        "offer_name": offerName,
                        "offer_type": offerType, 
                        ]
            }
        } 
        /// user submits a support request. Event name: `support_request_sent`
        struct SupportRequestSent: BIEvent {
            let name = "support_request_sent"
            
            var properties: [String: Any] {
                return [
                        "event_type": "business",
                        
                        ]
            }
        } 
        /// user was successfully created in the server (user ID). Event name: `user_registered`
        struct UserRegistered: BIEvent {
            let name = "user_registered"
            
            var properties: [String: Any] {
                return [
                        "event_type": "business",
                        
                        ]
            }
        } 
        /// Stellar wallet (account) successfully created for the user. Event name: `wallet_created`
        struct WalletCreated: BIEvent {
            let name = "wallet_created"
            
            var properties: [String: Any] {
                return [
                        "event_type": "business",
                        
                        ]
            }
        } 
        /// user was successfully verified (completed phone verification). Event name: `user_verified`
        struct UserVerified: BIEvent {
            let name = "user_verified"
            
            var properties: [String: Any] {
                return [
                        "event_type": "business",
                        
                        ]
            }
        } 
        /// user successfully completed the wallet backup process. Event name: `wallet_backed_up`
        struct WalletBackedUp: BIEvent {
            let name = "wallet_backed_up"
            
            var properties: [String: Any] {
                return [
                        "event_type": "business",
                        
                        ]
            }
        } 
        /// user successfully restored his/her wallet. Event name: `wallet_restored`
        struct WalletRestored: BIEvent {
            let name = "wallet_restored"
            
            var properties: [String: Any] {
                return [
                        "event_type": "business",
                        
                        ]
            }
        } 
        /// user submits a feedback email. Event name: `feedback_sent`
        struct FeedbackSent: BIEvent {
            let name = "feedback_sent"
            
            var properties: [String: Any] {
                return [
                        "event_type": "business",
                        
                        ]
            }
        } 
    } 
    struct Analytics { 
        /// user views splash screen (=app launch). Event name: `view_Splashscreen_page`
        struct ViewSplashscreenPage: BIEvent {
            let name = "view_Splashscreen_page"
            
            var properties: [String: Any] {
                return [
                        "item_name": "Splashscreen",
                        "item_type": "page",
                        "event_type": "analytics",
                        "action": "view",
                        
                        ]
            }
        } 
        /// user clicks an item on the navigation menu. Event name: `click_Menu_item`
        struct ClickMenuItem: BIEvent {
            let name = "click_Menu_item"
            let menuItemName: MenuItemName
            
            var properties: [String: Any] {
                return [
                        "item_name": "Menu",
                        "item_type": "item",
                        "event_type": "analytics",
                        "action": "click",
                        
                        
                        "menu_item_name": menuItemName.rawValue, 
                        ]
            }
        } 
        /// user answers a question, as part of a questionnaire. Event name: `click_Answer_button_on_Question_page`
        struct ClickAnswerButtonOnQuestionPage: BIEvent {
            let name = "click_Answer_button_on_Question_page"
            let answerId: String
            let answerOrder: Int
            let creator: String
            let estimatedTimeToComplete: Float
            let kinReward: Int
            let numberOfAnswers: Int
            let numberOfQuestions: Int
            let questionId: String
            let questionOrder: Int
            let questionType: QuestionType
            let taskCategory: String
            let taskId: String
            let taskTitle: String
            
            var properties: [String: Any] {
                return [
                        "item_name": "Answer",
                        "item_type": "button",
                        "parent_type": "page",
                        "event_type": "analytics",
                        "action": "click",
                        "parent_name": "Question",
                        
                        
                        "answer_id": answerId,
                        "answer_order": answerOrder,
                        "creator": creator,
                        "estimated_time_to_complete": estimatedTimeToComplete,
                        "KIN_reward": kinReward,
                        "number_of_answers": numberOfAnswers,
                        "number_of_questions": numberOfQuestions,
                        "question_id": questionId,
                        "question_order": questionOrder,
                        "question_type": questionType.rawValue,
                        "task_category": taskCategory,
                        "task_id": taskId,
                        "task_title": taskTitle, 
                        ]
            }
        } 
        /// user closes a question page, as part of a questionnaire. Event name: `click_Close_button_on_Question_page`
        struct ClickCloseButtonOnQuestionPage: BIEvent {
            let name = "click_Close_button_on_Question_page"
            let creator: String
            let estimatedTimeToComplete: Float
            let kinReward: Int
            let numberOfAnswers: Int
            let numberOfQuestions: Int
            let questionId: String
            let questionOrder: Int
            let questionType: QuestionType
            let taskCategory: String
            let taskId: String
            let taskTitle: String
            
            var properties: [String: Any] {
                return [
                        "item_name": "Close",
                        "item_type": "button",
                        "parent_type": "page",
                        "event_type": "analytics",
                        "action": "click",
                        "parent_name": "Question",
                        
                        
                        "creator": creator,
                        "estimated_time_to_complete": estimatedTimeToComplete,
                        "KIN_reward": kinReward,
                        "number_of_answers": numberOfAnswers,
                        "number_of_questions": numberOfQuestions,
                        "question_id": questionId,
                        "question_order": questionOrder,
                        "question_type": questionType.rawValue,
                        "task_category": taskCategory,
                        "task_id": taskId,
                        "task_title": taskTitle, 
                        ]
            }
        } 
        /// user closes the earning task end page . Event name: `click_Close_button_on_Reward_page`
        struct ClickCloseButtonOnRewardPage: BIEvent {
            let name = "click_Close_button_on_Reward_page"
            let creator: String
            let estimatedTimeToComplete: Float
            let kinReward: Int
            let taskCategory: String
            let taskId: String
            let taskTitle: String
            let taskType: TaskType
            
            var properties: [String: Any] {
                return [
                        "item_name": "Close",
                        "item_type": "button",
                        "parent_type": "page",
                        "event_type": "analytics",
                        "action": "click",
                        "parent_name": "Reward",
                        
                        
                        "creator": creator,
                        "estimated_time_to_complete": estimatedTimeToComplete,
                        "KIN_reward": kinReward,
                        "task_category": taskCategory,
                        "task_id": taskId,
                        "task_title": taskTitle,
                        "task_type": taskType.rawValue, 
                        ]
            }
        } 
        /// user clicks on button to start an earning task. Event name: `click_Start_button_on_Task_page`
        struct ClickStartButtonOnTaskPage: BIEvent {
            let name = "click_Start_button_on_Task_page"
            let alreadyStarted: Bool
            let creator: String
            let estimatedTimeToComplete: Float
            let kinReward: Int
            let taskCategory: String
            let taskId: String
            let taskTitle: String
            let taskType: TaskType
            
            var properties: [String: Any] {
                return [
                        "item_name": "Start",
                        "item_type": "button",
                        "parent_type": "page",
                        "event_type": "analytics",
                        "action": "click",
                        "parent_name": "Task",
                        
                        
                        "already_started": alreadyStarted,
                        "creator": creator,
                        "estimated_time_to_complete": estimatedTimeToComplete,
                        "KIN_reward": kinReward,
                        "task_category": taskCategory,
                        "task_id": taskId,
                        "task_title": taskTitle,
                        "task_type": taskType.rawValue, 
                        ]
            }
        } 
        /// user views the animation after KIN was successfully provided. Event name: `view_KIN_Provided_image_on_Reward_page`
        struct ViewKinProvidedImageOnRewardPage: BIEvent {
            let name = "view_KIN_Provided_image_on_Reward_page"
            let creator: String
            let estimatedTimeToComplete: Float
            let kinReward: Int
            let taskCategory: String
            let taskId: String
            let taskTitle: String
            let taskType: TaskType
            
            var properties: [String: Any] {
                return [
                        "item_name": "KIN_Provided",
                        "item_type": "image",
                        "parent_type": "page",
                        "event_type": "analytics",
                        "action": "view",
                        "parent_name": "Reward",
                        
                        
                        "creator": creator,
                        "estimated_time_to_complete": estimatedTimeToComplete,
                        "KIN_reward": kinReward,
                        "task_category": taskCategory,
                        "task_id": taskId,
                        "task_title": taskTitle,
                        "task_type": taskType.rawValue, 
                        ]
            }
        } 
        /// user views the next task availability . Event name: `view_Locked_Task_page`
        struct ViewLockedTaskPage: BIEvent {
            let name = "view_Locked_Task_page"
            let timeToUnlock: Int
            
            var properties: [String: Any] {
                return [
                        "item_name": "Locked_Task",
                        "item_type": "page",
                        "event_type": "analytics",
                        "action": "view",
                        
                        
                        "time_to_unlock": timeToUnlock, 
                        ]
            }
        } 
        /// user views question page, as part of a questionnaire. Event name: `view_Question_page`
        struct ViewQuestionPage: BIEvent {
            let name = "view_Question_page"
            let creator: String
            let estimatedTimeToComplete: Float
            let kinReward: Int
            let numberOfQuestions: Int
            let questionId: String
            let questionOrder: Int
            let questionType: QuestionType
            let taskCategory: String
            let taskId: String
            let taskTitle: String
            
            var properties: [String: Any] {
                return [
                        "item_name": "Question",
                        "item_type": "page",
                        "event_type": "analytics",
                        "action": "view",
                        
                        
                        "creator": creator,
                        "estimated_time_to_complete": estimatedTimeToComplete,
                        "KIN_reward": kinReward,
                        "number_of_questions": numberOfQuestions,
                        "question_id": questionId,
                        "question_order": questionOrder,
                        "question_type": questionType.rawValue,
                        "task_category": taskCategory,
                        "task_id": taskId,
                        "task_title": taskTitle, 
                        ]
            }
        } 
        /// user views Reward page after completing a task. Event name: `view_Reward_page`
        struct ViewRewardPage: BIEvent {
            let name = "view_Reward_page"
            let creator: String
            let estimatedTimeToComplete: Float
            let kinReward: Int
            let taskCategory: String
            let taskId: String
            let taskTitle: String
            let taskType: TaskType
            
            var properties: [String: Any] {
                return [
                        "item_name": "Reward",
                        "item_type": "page",
                        "event_type": "analytics",
                        "action": "view",
                        
                        
                        "creator": creator,
                        "estimated_time_to_complete": estimatedTimeToComplete,
                        "KIN_reward": kinReward,
                        "task_category": taskCategory,
                        "task_id": taskId,
                        "task_title": taskTitle,
                        "task_type": taskType.rawValue, 
                        ]
            }
        } 
        /// user views earning task end page (Yay!). Event name: `view_Task_End_page`
        struct ViewTaskEndPage: BIEvent {
            let name = "view_Task_End_page"
            let creator: String
            let estimatedTimeToComplete: Float
            let kinReward: Int
            let taskCategory: String
            let taskId: String
            let taskTitle: String
            let taskType: TaskType
            
            var properties: [String: Any] {
                return [
                        "item_name": "Task_End",
                        "item_type": "page",
                        "event_type": "analytics",
                        "action": "view",
                        
                        
                        "creator": creator,
                        "estimated_time_to_complete": estimatedTimeToComplete,
                        "KIN_reward": kinReward,
                        "task_category": taskCategory,
                        "task_id": taskId,
                        "task_title": taskTitle,
                        "task_type": taskType.rawValue, 
                        ]
            }
        } 
        /// user views earning task info (intro) page . Event name: `view_Task_page`
        struct ViewTaskPage: BIEvent {
            let name = "view_Task_page"
            let creator: String
            let estimatedTimeToComplete: Float
            let kinReward: Int
            let taskCategory: String
            let taskId: String
            let taskTitle: String
            let taskType: TaskType
            
            var properties: [String: Any] {
                return [
                        "item_name": "Task",
                        "item_type": "page",
                        "event_type": "analytics",
                        "action": "view",
                        
                        
                        "creator": creator,
                        "estimated_time_to_complete": estimatedTimeToComplete,
                        "KIN_reward": kinReward,
                        "task_category": taskCategory,
                        "task_id": taskId,
                        "task_title": taskTitle,
                        "task_type": taskType.rawValue, 
                        ]
            }
        } 
        /// user clicks on spending offer item on Spend page . Event name: `click_Offer_item_on_Spend_page`
        struct ClickOfferItemOnSpendPage: BIEvent {
            let name = "click_Offer_item_on_Spend_page"
            let brandName: String
            let kinPrice: Int
            let numberOfOffers: Int
            let offerCategory: String
            let offerId: String
            let offerName: String
            let offerOrder: Int
            let offerType: String
            
            var properties: [String: Any] {
                return [
                        "item_name": "Offer",
                        "item_type": "item",
                        "parent_type": "page",
                        "event_type": "analytics",
                        "action": "click",
                        "parent_name": "Spend",
                        
                        
                        "brand_name": brandName,
                        "KIN_price": kinPrice,
                        "number_of_offers": numberOfOffers,
                        "offer_category": offerCategory,
                        "offer_id": offerId,
                        "offer_name": offerName,
                        "offer_order": offerOrder,
                        "offer_type": offerType, 
                        ]
            }
        } 
        /// user clicks to share/save a coupon code. Event name: `click_Share_button_on_Offer_page`
        struct ClickShareButtonOnOfferPage: BIEvent {
            let name = "click_Share_button_on_Offer_page"
            let brandName: String
            let kinPrice: Int
            let offerCategory: String
            let offerId: String
            let offerName: String
            let offerType: String
            
            var properties: [String: Any] {
                return [
                        "item_name": "Share",
                        "item_type": "button",
                        "parent_type": "page",
                        "event_type": "analytics",
                        "action": "click",
                        "parent_name": "Offer",
                        
                        
                        "brand_name": brandName,
                        "KIN_price": kinPrice,
                        "offer_category": offerCategory,
                        "offer_id": offerId,
                        "offer_name": offerName,
                        "offer_type": offerType, 
                        ]
            }
        } 
        /// user views the coupon code after purchasing . Event name: `view_Code_text_on_Offer_page`
        struct ViewCodeTextOnOfferPage: BIEvent {
            let name = "view_Code_text_on_Offer_page"
            let brandName: String
            let kinPrice: Int
            let offerCategory: String
            let offerId: String
            let offerName: String
            let offerType: String
            
            var properties: [String: Any] {
                return [
                        "item_name": "Code",
                        "item_type": "text",
                        "parent_type": "page",
                        "event_type": "analytics",
                        "action": "view",
                        "parent_name": "Offer",
                        
                        
                        "brand_name": brandName,
                        "KIN_price": kinPrice,
                        "offer_category": offerCategory,
                        "offer_id": offerId,
                        "offer_name": offerName,
                        "offer_type": offerType, 
                        ]
            }
        } 
        /// user views offer details page. Event name: `view_Offer_page`
        struct ViewOfferPage: BIEvent {
            let name = "view_Offer_page"
            let brandName: String
            let kinPrice: Int
            let offerCategory: String
            let offerId: String
            let offerName: String
            let offerType: String
            
            var properties: [String: Any] {
                return [
                        "item_name": "Offer",
                        "item_type": "page",
                        "event_type": "analytics",
                        "action": "view",
                        
                        
                        "brand_name": brandName,
                        "KIN_price": kinPrice,
                        "offer_category": offerCategory,
                        "offer_id": offerId,
                        "offer_name": offerName,
                        "offer_type": offerType, 
                        ]
            }
        } 
        /// user views Spend page, with spending offers. Event name: `view_Spend_page`
        struct ViewSpendPage: BIEvent {
            let name = "view_Spend_page"
            let numberOfOffers: Int
            
            var properties: [String: Any] {
                return [
                        "item_name": "Spend",
                        "item_type": "page",
                        "event_type": "analytics",
                        "action": "view",
                        
                        
                        "number_of_offers": numberOfOffers, 
                        ]
            }
        } 
        /// user views the balance page  . Event name: `view_Balance_page`
        struct ViewBalancePage: BIEvent {
            let name = "view_Balance_page"
            
            var properties: [String: Any] {
                return [
                        "item_name": "Balance",
                        "item_type": "page",
                        "event_type": "analytics",
                        "action": "view",
                        
                        ]
            }
        } 
        /// user views the profile page . Event name: `view_Profile_page`
        struct ViewProfilePage: BIEvent {
            let name = "view_Profile_page"
            
            var properties: [String: Any] {
                return [
                        "item_name": "Profile",
                        "item_type": "page",
                        "event_type": "analytics",
                        "action": "view",
                        
                        ]
            }
        } 
        /// users clicks on support button (opens email), on specific FAQ page. Event name: `click_Support_button`
        struct ClickSupportButton: BIEvent {
            let name = "click_Support_button"
            let faqCategory: String
            let faqTitle: String
            
            var properties: [String: Any] {
                return [
                        "item_name": "Support",
                        "item_type": "button",
                        "event_type": "analytics",
                        "action": "click",
                        
                        
                        "FAQ_category": faqCategory,
                        "FAQ_title": faqTitle, 
                        ]
            }
        } 
        /// user clicks push notification to engage with the app. Event name: `click_Engagement_push`
        struct ClickEngagementPush: BIEvent {
            let name = "click_Engagement_push"
            let pushId: String
            let pushText: String
            
            var properties: [String: Any] {
                return [
                        "item_name": "Engagement",
                        "item_type": "push",
                        "event_type": "analytics",
                        "action": "click",
                        
                        
                        "push_id": pushId,
                        "push_text": pushText, 
                        ]
            }
        } 
        /// for iOS only. user clicks the reminder button on locked task page to trigger the push notification approval popup. Event name: `click_Reminder_button_on_Locked_Task_page`
        struct ClickReminderButtonOnLockedTaskPage: BIEvent {
            let name = "click_Reminder_button_on_Locked_Task_page"
            
            var properties: [String: Any] {
                return [
                        "item_name": "Reminder",
                        "item_type": "button",
                        "parent_type": "page",
                        "event_type": "analytics",
                        "action": "click",
                        "parent_name": "Locked_Task",
                        
                        ]
            }
        } 
        /// user views push notification to engage with the app. Event name: `view_Engagement_push`
        struct ViewEngagementPush: BIEvent {
            let name = "view_Engagement_push"
            let pushId: String
            let pushText: String
            
            var properties: [String: Any] {
                return [
                        "item_name": "Engagement",
                        "item_type": "push",
                        "event_type": "analytics",
                        "action": "view",
                        
                        
                        "push_id": pushId,
                        "push_text": pushText, 
                        ]
            }
        } 
        /// user views any of the error pages: onboarding, reward, submission, connection. Event name: `view_Error_page`
        struct ViewErrorPage: BIEvent {
            let name = "view_Error_page"
            let errorType: ErrorType
            let failureReason: String
            
            var properties: [String: Any] {
                return [
                        "item_name": "Error",
                        "item_type": "page",
                        "event_type": "analytics",
                        "action": "view",
                        
                        
                        "error_type": errorType.rawValue,
                        "failure_reason": failureReason, 
                        ]
            }
        } 
        /// user clicks Retry button on onboarding error page. Event name: `click_Retry_button_on_Error_page`
        struct ClickRetryButtonOnErrorPage: BIEvent {
            let name = "click_Retry_button_on_Error_page"
            let errorType: ErrorType
            
            var properties: [String: Any] {
                return [
                        "item_name": "Retry",
                        "item_type": "button",
                        "parent_type": "page",
                        "event_type": "analytics",
                        "action": "click",
                        "parent_name": "Error",
                        
                        
                        "error_type": errorType.rawValue, 
                        ]
            }
        } 
        /// user clicks the close button on submission / reward errors. Event name: `click_Close_button_on_Error_page`
        struct ClickCloseButtonOnErrorPage: BIEvent {
            let name = "click_Close_button_on_Error_page"
            let errorType: ErrorType
            
            var properties: [String: Any] {
                return [
                        "item_name": "Close",
                        "item_type": "button",
                        "parent_type": "page",
                        "event_type": "analytics",
                        "action": "click",
                        "parent_name": "Error",
                        
                        
                        "error_type": errorType.rawValue, 
                        ]
            }
        } 
        /// user views empty state for no earn tasks / spend offers. Event name: `view_Empty_State_page`
        struct ViewEmptyStatePage: BIEvent {
            let name = "view_Empty_State_page"
            let menuItemName: MenuItemName
            let taskCategory: String
            
            var properties: [String: Any] {
                return [
                        "item_name": "Empty_State",
                        "item_type": "page",
                        "event_type": "analytics",
                        "action": "view",
                        
                        
                        "menu_item_name": menuItemName.rawValue,
                        "task_category": taskCategory, 
                        ]
            }
        } 
        /// user clicks the link on onboarding error, to open support email. Event name: `click_Contact_link_on_Error_page`
        struct ClickContactLinkOnErrorPage: BIEvent {
            let name = "click_Contact_link_on_Error_page"
            let errorType: ErrorType
            
            var properties: [String: Any] {
                return [
                        "item_name": "Contact",
                        "item_type": "link",
                        "parent_type": "page",
                        "event_type": "analytics",
                        "action": "click",
                        "parent_name": "Error",
                        
                        
                        "error_type": errorType.rawValue, 
                        ]
            }
        } 
        /// user views error popup when trying to buy an offer. Event name: `view_Error_popup_on_Offer_page`
        struct ViewErrorPopupOnOfferPage: BIEvent {
            let name = "view_Error_popup_on_Offer_page"
            let errorType: ErrorType
            
            var properties: [String: Any] {
                return [
                        "item_name": "Error",
                        "item_type": "popup",
                        "parent_type": "page",
                        "event_type": "analytics",
                        "action": "view",
                        "parent_name": "Offer",
                        
                        
                        "error_type": errorType.rawValue, 
                        ]
            }
        } 
        /// user clicks the button on the error popup (OK / Back to list). Event name: `click_OK_button_on_Error_popup`
        struct ClickOkButtonOnErrorPopup: BIEvent {
            let name = "click_OK_button_on_Error_popup"
            let errorType: ErrorType
            
            var properties: [String: Any] {
                return [
                        "item_name": "OK",
                        "item_type": "button",
                        "parent_type": "popup",
                        "event_type": "analytics",
                        "action": "click",
                        "parent_name": "Error",
                        
                        
                        "error_type": errorType.rawValue, 
                        ]
            }
        } 
        /// user clicks the button on the onboarding page (tutorial pages). Event name: `click_Start_button_on_Onboarding_page`
        struct ClickStartButtonOnOnboardingPage: BIEvent {
            let name = "click_Start_button_on_Onboarding_page"
            let onboardingTutorialPage: Int
            
            var properties: [String: Any] {
                return [
                        "item_name": "Start",
                        "item_type": "button",
                        "parent_type": "page",
                        "event_type": "analytics",
                        "action": "click",
                        "parent_name": "Onboarding",
                        
                        
                        "onboarding_tutorial_page": onboardingTutorialPage, 
                        ]
            }
        } 
        /// user views the onboarding page (tutorial pages). sent also when moving to other tutorial slide. Event name: `view_Onboarding_page`
        struct ViewOnboardingPage: BIEvent {
            let name = "view_Onboarding_page"
            let onboardingTutorialPage: Int
            
            var properties: [String: Any] {
                return [
                        "item_name": "Onboarding",
                        "item_type": "page",
                        "event_type": "analytics",
                        "action": "view",
                        
                        
                        "onboarding_tutorial_page": onboardingTutorialPage, 
                        ]
            }
        } 
        /// user views the phone authentication page when phone number should be inserted. Event name: `view_Phone_Auth_page`
        struct ViewPhoneAuthPage: BIEvent {
            let name = "view_Phone_Auth_page"
            
            var properties: [String: Any] {
                return [
                        "item_name": "Phone_Auth",
                        "item_type": "page",
                        "event_type": "analytics",
                        "action": "view",
                        
                        ]
            }
        } 
        /// user click the button to continue to verification page. Event name: `click_Next_button_on_Phone_Auth_page`
        struct ClickNextButtonOnPhoneAuthPage: BIEvent {
            let name = "click_Next_button_on_Phone_Auth_page"
            
            var properties: [String: Any] {
                return [
                        "item_name": "Next",
                        "item_type": "button",
                        "parent_type": "page",
                        "event_type": "analytics",
                        "action": "click",
                        "parent_name": "Phone_Auth",
                        
                        ]
            }
        } 
        /// user views the verification page, where a verification code should be inserted. Event name: `view_Verification_page`
        struct ViewVerificationPage: BIEvent {
            let name = "view_Verification_page"
            
            var properties: [String: Any] {
                return [
                        "item_name": "Verification",
                        "item_type": "page",
                        "event_type": "analytics",
                        "action": "view",
                        
                        ]
            }
        } 
        /// user gets an error message when entering a wrong verification code. Event name: `view_Error_message_on_Verification_page`
        struct ViewErrorMessageOnVerificationPage: BIEvent {
            let name = "view_Error_message_on_Verification_page"
            
            var properties: [String: Any] {
                return [
                        "item_name": "Error",
                        "item_type": "message",
                        "parent_type": "page",
                        "event_type": "analytics",
                        "action": "view",
                        "parent_name": "Verification",
                        
                        ]
            }
        } 
        /// user view the completion message after successfully completed onboarding. Event name: `view_Onboarding_Completed_page`
        struct ViewOnboardingCompletedPage: BIEvent {
            let name = "view_Onboarding_Completed_page"
            
            var properties: [String: Any] {
                return [
                        "item_name": "Onboarding_Completed",
                        "item_type": "page",
                        "event_type": "analytics",
                        "action": "view",
                        
                        ]
            }
        } 
        /// user clicks the new code link to receive a new SMS with verification code. Event name: `click_New_Code_link_on_Verification_page`
        struct ClickNewCodeLinkOnVerificationPage: BIEvent {
            let name = "click_New_Code_link_on_Verification_page"
            let verificationCodeCount: Int
            
            var properties: [String: Any] {
                return [
                        "item_name": "New_Code",
                        "item_type": "link",
                        "parent_type": "page",
                        "event_type": "analytics",
                        "action": "click",
                        "parent_name": "Verification",
                        
                        
                        "verification_code_count": verificationCodeCount, 
                        ]
            }
        } 
        /// existing user receives a popup message explaining the phone auth required. Event name: `view_Phone_Auth_popup`
        struct ViewPhoneAuthPopup: BIEvent {
            let name = "view_Phone_Auth_popup"
            
            var properties: [String: Any] {
                return [
                        "item_name": "Phone_Auth",
                        "item_type": "popup",
                        "event_type": "analytics",
                        "action": "view",
                        
                        ]
            }
        } 
        /// existing user clicks the button on the popup message to start phone auth flow. Event name: `click_Verify_button_on_Phone_Auth_popup`
        struct ClickVerifyButtonOnPhoneAuthPopup: BIEvent {
            let name = "click_Verify_button_on_Phone_Auth_popup"
            
            var properties: [String: Any] {
                return [
                        "item_name": "Verify",
                        "item_type": "button",
                        "parent_type": "popup",
                        "event_type": "analytics",
                        "action": "click",
                        "parent_name": "Phone_Auth",
                        
                        ]
            }
        } 
        /// user views the Send Kin page where he sets up the Kin amount he wants to send to a friend. Event name: `view_Send_Kin_page`
        struct ViewSendKinPage: BIEvent {
            let name = "view_Send_Kin_page"
            
            var properties: [String: Any] {
                return [
                        "item_name": "Send_Kin",
                        "item_type": "page",
                        "event_type": "analytics",
                        "action": "view",
                        
                        ]
            }
        } 
        /// user clicks on the Send button to send Kin to a friend. Event name: `click_Send_button_on_Send_Kin_page`
        struct ClickSendButtonOnSendKinPage: BIEvent {
            let name = "click_Send_button_on_Send_Kin_page"
            let kinAmount: Float
            
            var properties: [String: Any] {
                return [
                        "item_name": "Send",
                        "item_type": "button",
                        "parent_type": "page",
                        "event_type": "analytics",
                        "action": "click",
                        "parent_name": "Send_Kin",
                        
                        
                        "KIN_amount": kinAmount, 
                        ]
            }
        } 
        /// user views the success message on successful transaction of Kin to a friend. Event name: `view_Success_message_on_Send_Kin_page`
        struct ViewSuccessMessageOnSendKinPage: BIEvent {
            let name = "view_Success_message_on_Send_Kin_page"
            let kinAmount: Float
            
            var properties: [String: Any] {
                return [
                        "item_name": "Success",
                        "item_type": "message",
                        "parent_type": "page",
                        "event_type": "analytics",
                        "action": "view",
                        "parent_name": "Send_Kin",
                        
                        
                        "KIN_amount": kinAmount, 
                        ]
            }
        } 
        /// user views error message popup on several use cases on Send Kin page. Event name: `view_Error_popup_on_Send_Kin_page`
        struct ViewErrorPopupOnSendKinPage: BIEvent {
            let name = "view_Error_popup_on_Send_Kin_page"
            let errorType: ErrorType
            
            var properties: [String: Any] {
                return [
                        "item_name": "Error",
                        "item_type": "popup",
                        "parent_type": "page",
                        "event_type": "analytics",
                        "action": "view",
                        "parent_name": "Send_Kin",
                        
                        
                        "error_type": errorType.rawValue, 
                        ]
            }
        } 
        /// user views the Video page as part of a "tip" task . Event name: `view_Video_page`
        struct ViewVideoPage: BIEvent {
            let name = "view_Video_page"
            
            var properties: [String: Any] {
                return [
                        "item_name": "Video",
                        "item_type": "page",
                        "event_type": "analytics",
                        "action": "view",
                        
                        ]
            }
        } 
        /// user playes the Video page as part of a "tip" task . Event name: `click_Play_button_on_Video_page`
        struct ClickPlayButtonOnVideoPage: BIEvent {
            let name = "click_Play_button_on_Video_page"
            let videoTitle: String
            
            var properties: [String: Any] {
                return [
                        "item_name": "Play",
                        "item_type": "button",
                        "parent_type": "page",
                        "event_type": "analytics",
                        "action": "click",
                        "parent_name": "Video",
                        
                        
                        "video_title": videoTitle, 
                        ]
            }
        } 
        /// user views the backup intro page. Event name: `view_Backup_Intro_page`
        struct ViewBackupIntroPage: BIEvent {
            let name = "view_Backup_Intro_page"
            
            var properties: [String: Any] {
                return [
                        "item_name": "Backup_Intro",
                        "item_type": "page",
                        "event_type": "analytics",
                        "action": "view",
                        
                        ]
            }
        } 
        /// user clicks the button on the backup intro page to start the backup flow. Event name: `click_Backup_button_on_Backup_Intro_page`
        struct ClickBackupButtonOnBackupIntroPage: BIEvent {
            let name = "click_Backup_button_on_Backup_Intro_page"
            
            var properties: [String: Any] {
                return [
                        "item_name": "Backup",
                        "item_type": "button",
                        "parent_type": "page",
                        "event_type": "analytics",
                        "action": "click",
                        "parent_name": "Backup_Intro",
                        
                        ]
            }
        } 
        /// user views any of the steps on the backup flow (total of 5 steps). Event name: `view_Backup_Flow_page`
        struct ViewBackupFlowPage: BIEvent {
            let name = "view_Backup_Flow_page"
            let backupFlowStep: BackupFlowStep
            
            var properties: [String: Any] {
                return [
                        "item_name": "Backup_Flow",
                        "item_type": "page",
                        "event_type": "analytics",
                        "action": "view",
                        
                        
                        "backup_flow_step": backupFlowStep.rawValue, 
                        ]
            }
        } 
        /// user clicks the complete button on each step to move to next step / finish the flow. Event name: `click_Completed_Step_button_on_Backup_Flow_page`
        struct ClickCompletedStepButtonOnBackupFlowPage: BIEvent {
            let name = "click_Completed_Step_button_on_Backup_Flow_page"
            let backupFlowStep: BackupFlowStep
            
            var properties: [String: Any] {
                return [
                        "item_name": "Completed_Step",
                        "item_type": "button",
                        "parent_type": "page",
                        "event_type": "analytics",
                        "action": "click",
                        "parent_name": "Backup_Flow",
                        
                        
                        "backup_flow_step": backupFlowStep.rawValue, 
                        ]
            }
        } 
        /// user views the completion message after successfully completed backup flow. Event name: `view_Backup_Completed_page`
        struct ViewBackupCompletedPage: BIEvent {
            let name = "view_Backup_Completed_page"
            
            var properties: [String: Any] {
                return [
                        "item_name": "Backup_Completed",
                        "item_type": "page",
                        "event_type": "analytics",
                        "action": "view",
                        
                        ]
            }
        } 
        /// user views the backup notification popup after completing last earn activity for day 1/7/14/30. Event name: `view_Backup_Notification_popup`
        struct ViewBackupNotificationPopup: BIEvent {
            let name = "view_Backup_Notification_popup"
            let backupNotificationType: BackupNotificationType
            
            var properties: [String: Any] {
                return [
                        "item_name": "Backup_Notification",
                        "item_type": "popup",
                        "event_type": "analytics",
                        "action": "view",
                        
                        
                        "backup_notification_type": backupNotificationType.rawValue, 
                        ]
            }
        } 
        /// user clicks the backup button to start the backup flow (navigates to backup intro page). Event name: `click_Backup_button_on_Backup_Notification_popup`
        struct ClickBackupButtonOnBackupNotificationPopup: BIEvent {
            let name = "click_Backup_button_on_Backup_Notification_popup"
            let backupNotificationType: BackupNotificationType
            
            var properties: [String: Any] {
                return [
                        "item_name": "Backup",
                        "item_type": "button",
                        "parent_type": "popup",
                        "event_type": "analytics",
                        "action": "click",
                        "parent_name": "Backup_Notification",
                        
                        
                        "backup_notification_type": backupNotificationType.rawValue, 
                        ]
            }
        } 
        /// existing user views welcome back page after completing phone verification. Event name: `view_Welcome_Back_page`
        struct ViewWelcomeBackPage: BIEvent {
            let name = "view_Welcome_Back_page"
            
            var properties: [String: Any] {
                return [
                        "item_name": "Welcome_Back",
                        "item_type": "page",
                        "event_type": "analytics",
                        "action": "view",
                        
                        ]
            }
        } 
        /// user chooses to restore wallet on welcome back page. Event name: `click_Restore_Wallet_button_on_Welcome_Back_page`
        struct ClickRestoreWalletButtonOnWelcomeBackPage: BIEvent {
            let name = "click_Restore_Wallet_button_on_Welcome_Back_page"
            
            var properties: [String: Any] {
                return [
                        "item_name": "Restore_Wallet",
                        "item_type": "button",
                        "parent_type": "page",
                        "event_type": "analytics",
                        "action": "click",
                        "parent_name": "Welcome_Back",
                        
                        ]
            }
        } 
        /// user chooses to create new wallet on welcome back page. Event name: `click_Create_New_Wallet_button_on_Welcome_Back_page`
        struct ClickCreateNewWalletButtonOnWelcomeBackPage: BIEvent {
            let name = "click_Create_New_Wallet_button_on_Welcome_Back_page"
            
            var properties: [String: Any] {
                return [
                        "item_name": "Create_New_Wallet",
                        "item_type": "button",
                        "parent_type": "page",
                        "event_type": "analytics",
                        "action": "click",
                        "parent_name": "Welcome_Back",
                        
                        ]
            }
        } 
        /// user views the scan page after staring the restore flow. Event name: `view_Scan_page`
        struct ViewScanPage: BIEvent {
            let name = "view_Scan_page"
            
            var properties: [String: Any] {
                return [
                        "item_name": "Scan",
                        "item_type": "page",
                        "event_type": "analytics",
                        "action": "view",
                        
                        ]
            }
        } 
        /// user clicks the scan button to start scanning the process of the QR code. Event name: `click_Scan_button_on_Scan_page`
        struct ClickScanButtonOnScanPage: BIEvent {
            let name = "click_Scan_button_on_Scan_page"
            
            var properties: [String: Any] {
                return [
                        "item_name": "Scan",
                        "item_type": "button",
                        "parent_type": "page",
                        "event_type": "analytics",
                        "action": "click",
                        "parent_name": "Scan",
                        
                        ]
            }
        } 
        /// user views the security questions page as part of the restore flow. Event name: `view_Answer_Security_Questions_page`
        struct ViewAnswerSecurityQuestionsPage: BIEvent {
            let name = "view_Answer_Security_Questions_page"
            
            var properties: [String: Any] {
                return [
                        "item_name": "Answer_Security_Questions",
                        "item_type": "page",
                        "event_type": "analytics",
                        "action": "view",
                        
                        ]
            }
        } 
        /// user confirms the answers entered for security questions as part of the restore flow. Event name: `click_Confirm_button_on_Answer_Security_Questions_page`
        struct ClickConfirmButtonOnAnswerSecurityQuestionsPage: BIEvent {
            let name = "click_Confirm_button_on_Answer_Security_Questions_page"
            
            var properties: [String: Any] {
                return [
                        "item_name": "Confirm",
                        "item_type": "button",
                        "parent_type": "page",
                        "event_type": "analytics",
                        "action": "click",
                        "parent_name": "Answer_Security_Questions",
                        
                        ]
            }
        } 
        /// user views the completion message after successfully restoring the wallet. Event name: `view_Wallet_Restored_page`
        struct ViewWalletRestoredPage: BIEvent {
            let name = "view_Wallet_Restored_page"
            
            var properties: [String: Any] {
                return [
                        "item_name": "Wallet_Restored",
                        "item_type": "page",
                        "event_type": "analytics",
                        "action": "view",
                        
                        ]
            }
        } 
        /// user views the creating wallet page (animation) when creating new wallet. Event name: `view_Creating_Wallet_page`
        struct ViewCreatingWalletPage: BIEvent {
            let name = "view_Creating_Wallet_page"
            
            var properties: [String: Any] {
                return [
                        "item_name": "Creating_Wallet",
                        "item_type": "page",
                        "event_type": "analytics",
                        "action": "view",
                        
                        ]
            }
        } 
        /// user clicks on backup button on More page. Event name: `click_Backup_button_on_More_page`
        struct ClickBackupButtonOnMorePage: BIEvent {
            let name = "click_Backup_button_on_More_page"
            let alreadyBackedUp: AlreadyBackedUp
            
            var properties: [String: Any] {
                return [
                        "item_name": "Backup",
                        "item_type": "button",
                        "parent_type": "page",
                        "event_type": "analytics",
                        "action": "click",
                        "parent_name": "More",
                        
                        
                        "already_backed_up": alreadyBackedUp.rawValue, 
                        ]
            }
        } 
        /// user views the FAQ main page (with all the categories). Event name: `view_FAQ_Main_page`
        struct ViewFaqMainPage: BIEvent {
            let name = "view_FAQ_Main_page"
            
            var properties: [String: Any] {
                return [
                        "item_name": "FAQ_Main",
                        "item_type": "page",
                        "event_type": "analytics",
                        "action": "view",
                        
                        ]
            }
        } 
        /// user views a FAQ specific page . Event name: `view_FAQ_page`
        struct ViewFaqPage: BIEvent {
            let name = "view_FAQ_page"
            let faqCategory: String
            let faqTitle: String
            
            var properties: [String: Any] {
                return [
                        "item_name": "FAQ",
                        "item_type": "page",
                        "event_type": "analytics",
                        "action": "view",
                        
                        
                        "FAQ_category": faqCategory,
                        "FAQ_title": faqTitle, 
                        ]
            }
        } 
        /// user clicks the feedback button on the More page. Event name: `click_Feedback_button`
        struct ClickFeedbackButton: BIEvent {
            let name = "click_Feedback_button"
            
            var properties: [String: Any] {
                return [
                        "item_name": "Feedback",
                        "item_type": "button",
                        "event_type": "analytics",
                        "action": "click",
                        
                        ]
            }
        } 
        /// user clicks the Yes/No buttons on FAQ page, to share if the page info was helpful or not. Event name: `click_Page_Helpful_button_on_FAQ_page`
        struct ClickPageHelpfulButtonOnFaqPage: BIEvent {
            let name = "click_Page_Helpful_button_on_FAQ_page"
            let faqCategory: String
            let faqTitle: String
            let helpful: Bool
            
            var properties: [String: Any] {
                return [
                        "item_name": "Page_Helpful",
                        "item_type": "button",
                        "parent_type": "page",
                        "event_type": "analytics",
                        "action": "click",
                        "parent_name": "FAQ",
                        
                        
                        "FAQ_category": faqCategory,
                        "FAQ_title": faqTitle,
                        "Helpful": helpful, 
                        ]
            }
        } 
        /// User views captcha popup. Event name: `view_Captcha_popup`
        struct ViewCaptchaPopup: BIEvent {
            let name = "view_Captcha_popup"
            
            var properties: [String: Any] {
                return [
                        "item_name": "Captcha",
                        "item_type": "popup",
                        "event_type": "analytics",
                        "action": "view",
                        
                        ]
            }
        } 
        /// User views a campaign popup after completing a task with a campaign related. Event name: `view_Campaign_popup`
        struct ViewCampaignPopup: BIEvent {
            let name = "view_Campaign_popup"
            let campaignName: String
            let taskId: String
            
            var properties: [String: Any] {
                return [
                        "item_name": "Campaign",
                        "item_type": "popup",
                        "event_type": "analytics",
                        "action": "view",
                        
                        
                        "campaign_name": campaignName,
                        "task_id": taskId, 
                        ]
            }
        } 
        /// User clicks on a button that open a campaign link, opens a web browser . Event name: `click_Link_button_on_Campaign_popup`
        struct ClickLinkButtonOnCampaignPopup: BIEvent {
            let name = "click_Link_button_on_Campaign_popup"
            let campaignName: String
            let taskId: String
            
            var properties: [String: Any] {
                return [
                        "item_name": "Link",
                        "item_type": "button",
                        "parent_type": "popup",
                        "event_type": "analytics",
                        "action": "click",
                        "parent_name": "Campaign",
                        
                        
                        "campaign_name": campaignName,
                        "task_id": taskId, 
                        ]
            }
        } 
        /// User views the task category page with all tasks options. Event name: `view_Task_Categories_page`
        struct ViewTaskCategoriesPage: BIEvent {
            let name = "view_Task_Categories_page"
            
            var properties: [String: Any] {
                return [
                        "item_name": "Task_Categories",
                        "item_type": "page",
                        "event_type": "analytics",
                        "action": "view",
                        
                        ]
            }
        } 
        /// User clicks a specific task category. Event name: `click_Category_button_on_Task_Categories_page`
        struct ClickCategoryButtonOnTaskCategoriesPage: BIEvent {
            let name = "click_Category_button_on_Task_Categories_page"
            let taskCategory: String
            
            var properties: [String: Any] {
                return [
                        "item_name": "Category",
                        "item_type": "button",
                        "parent_type": "page",
                        "event_type": "analytics",
                        "action": "click",
                        "parent_name": "Task_Categories",
                        
                        
                        "task_category": taskCategory, 
                        ]
            }
        } 
        /// user clicks to purchase a spending offer. Event name: `click_Buy_button_on_Offer_page`
        struct ClickBuyButtonOnOfferPage: BIEvent {
            let name = "click_Buy_button_on_Offer_page"
            let brandName: String
            let kinPrice: Int
            let offerCategory: String
            let offerId: String
            let offerName: String
            let offerType: String
            
            var properties: [String: Any] {
                return [
                        "item_name": "Buy",
                        "item_type": "button",
                        "parent_type": "page",
                        "event_type": "analytics",
                        "action": "click",
                        "parent_name": "Offer",
                        
                        
                        "brand_name": brandName,
                        "KIN_price": kinPrice,
                        "offer_category": offerCategory,
                        "offer_id": offerId,
                        "offer_name": offerName,
                        "offer_type": offerType, 
                        ]
            }
        } 
    } 
}