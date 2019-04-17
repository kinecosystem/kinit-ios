//
// BIEvents.swift
//
// Don't edit this file.
// Generated at 2019-04-17 08:14:50 +0000 by Kik BI-Generator.
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
        case crossApp = "cross_app"
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
        case useKin = "Use Kin"
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
        case generic = "Generic"
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
    
    enum PageContent: String { 
        case sendKinComingSoon = "Send Kin Coming Soon"
        case sendKinFunctionality = "Send Kin Functionality"
    }
    
    enum FailureType: String { 
        case cancel = "Cancel"
        case error = "Error"
    }
    
    enum Topic: String { 
        case entertainment = "Entertainment"
        case environment = "Environment"
        case finance = "Finance"
        case food = "Food"
        case geography = "Geography"
        case history = "History"
        case holidays = "Holidays"
        case literature = "Literature"
        case science = "Science"
        case sports = "Sports"
        case tech = "Tech"
        case transportation = "Transportation"
        case travel = "Travel"
    }
    
    
    struct Business { 
        /// User failed to send Kin to another app. Event name: `cross_app_KIN_failure`
        struct CrossAppKinFailure: BIEvent {
            let name = "cross_app_KIN_failure"
            let failureReason: String
            let failureType: FailureType
            
            var properties: [String: Any] {
                return [
                        "event_type": "business",
                        
                        
                        "failure_reason": failureReason,
                        "failure_type": failureType.rawValue, 
                        ]
            }
        } 
        /// user successfully sent Kin to another app. Event name: `cross_app_KIN_sent`
        struct CrossAppKinSent: BIEvent {
            let name = "cross_app_KIN_sent"
            let appCategory: String
            let appId: String
            let appName: String
            let kinAmount: Int
            
            var properties: [String: Any] {
                return [
                        "event_type": "business",
                        
                        
                        "app_category": appCategory,
                        "app_id": appId,
                        "app_name": appName,
                        "KIN_amount": kinAmount, 
                        ]
            }
        } 
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
        /// user submits a feedback email. Event name: `feedback_sent`
        struct FeedbackSent: BIEvent {
            let name = "feedback_sent"
            
            var properties: [String: Any] {
                return [
                        "event_type": "business",
                        
                        ]
            }
        } 
        /// User successfully submitted a Feedback form. Event name: `feedbackform_sent`
        struct FeedbackformSent: BIEvent {
            let name = "feedbackform_sent"
            
            var properties: [String: Any] {
                return [
                        "event_type": "business",
                        
                        ]
            }
        } 
        /// KIN transaction failure. Event name: `KIN_transaction_failed`
        struct KINTransactionFailed: BIEvent {
            let name = "KIN_transaction_failed"
            let failureReason: String
            let kinAmount: Int
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
            let kinAmount: Int
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
            let faqCategory: String
            let faqSubcategory: String
            
            var properties: [String: Any] {
                return [
                        "event_type": "business",
                        
                        
                        "FAQ_category": faqCategory,
                        "FAQ_subcategory": faqSubcategory, 
                        ]
            }
        } 
        /// User submitted at least 5 topics he/she likes. Event name: `topics_chosen`
        struct TopicsChosen: BIEvent {
            let name = "topics_chosen"
            let topic: Topic
            
            var properties: [String: Any] {
                return [
                        "event_type": "business",
                        
                        
                        "topic": topic.rawValue, 
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
        /// User failed to back up wallet. Event name: `wallet_backup_failed`
        struct WalletBackupFailed: BIEvent {
            let name = "wallet_backup_failed"
            let failureReason: String
            
            var properties: [String: Any] {
                return [
                        "event_type": "business",
                        
                        
                        "failure_reason": failureReason, 
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
        /// User failed to restore wallet. Event name: `wallet_restore_failed`
        struct WalletRestoreFailed: BIEvent {
            let name = "wallet_restore_failed"
            let failureReason: String
            
            var properties: [String: Any] {
                return [
                        "event_type": "business",
                        
                        
                        "failure_reason": failureReason, 
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
        /// User started migration. Event name: `migration_started`
        struct MigrationStarted: BIEvent {
            let name = "migration_started"
            
            var properties: [String: Any] {
                return [
                        "event_type": "business",
                        
                        ]
            }
        } 
        /// User's migration succeeded. Event name: `migration_succeeded`
        struct MigrationSucceeded: BIEvent {
            let name = "migration_succeeded"
            
            var properties: [String: Any] {
                return [
                        "event_type": "business",
                        
                        ]
            }
        } 
    } 
    struct Log { 
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
        /// When server sends the auth token via push, and the client receives it.. Event name: `auth_token_received`
        struct AuthTokenReceived: BIEvent {
            let name = "auth_token_received"
            
            var properties: [String: Any] {
                return [
                        "event_type": "log",
                        
                        ]
            }
        } 
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
        /// When formatting of the phone inserted by the user when validating fails. Event name: `phone_formatting_failed`
        struct PhoneFormattingFailed: BIEvent {
            let name = "phone_formatting_failed"
            
            var properties: [String: Any] {
                return [
                        "event_type": "log",
                        
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
        /// User's migration failed. Event name: `migration_failed`
        struct MigrationFailed: BIEvent {
            let name = "migration_failed"
            let failureReason: String
            
            var properties: [String: Any] {
                return [
                        "event_type": "log",
                        
                        
                        "failure_reason": failureReason, 
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
                        "action": "view",
                        "item_name": "Splashscreen",
                        "event_type": "analytics",
                        "item_type": "page",
                        
                        ]
            }
        } 
        /// user clicks an item on the navigation menu. Event name: `click_Menu_item`
        struct ClickMenuItem: BIEvent {
            let name = "click_Menu_item"
            let menuItemName: MenuItemName
            
            var properties: [String: Any] {
                return [
                        "action": "click",
                        "item_name": "Menu",
                        "event_type": "analytics",
                        "item_type": "item",
                        
                        
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
                        "action": "click",
                        "item_name": "Answer",
                        "event_type": "analytics",
                        "parent_name": "Question",
                        "item_type": "button",
                        "parent_type": "page",
                        
                        
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
                        "action": "click",
                        "item_name": "Close",
                        "event_type": "analytics",
                        "parent_name": "Question",
                        "item_type": "button",
                        "parent_type": "page",
                        
                        
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
                        "action": "click",
                        "item_name": "Close",
                        "event_type": "analytics",
                        "parent_name": "Reward",
                        "item_type": "button",
                        "parent_type": "page",
                        
                        
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
                        "action": "click",
                        "item_name": "Start",
                        "event_type": "analytics",
                        "parent_name": "Task",
                        "item_type": "button",
                        "parent_type": "page",
                        
                        
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
                        "action": "view",
                        "item_name": "KIN_Provided",
                        "event_type": "analytics",
                        "parent_name": "Reward",
                        "item_type": "image",
                        "parent_type": "page",
                        
                        
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
                        "action": "view",
                        "item_name": "Locked_Task",
                        "event_type": "analytics",
                        "item_type": "page",
                        
                        
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
                        "action": "view",
                        "item_name": "Question",
                        "event_type": "analytics",
                        "item_type": "page",
                        
                        
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
                        "action": "view",
                        "item_name": "Reward",
                        "event_type": "analytics",
                        "item_type": "page",
                        
                        
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
                        "action": "view",
                        "item_name": "Task_End",
                        "event_type": "analytics",
                        "item_type": "page",
                        
                        
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
                        "action": "view",
                        "item_name": "Task",
                        "event_type": "analytics",
                        "item_type": "page",
                        
                        
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
                        "action": "click",
                        "item_name": "Offer",
                        "event_type": "analytics",
                        "parent_name": "Spend",
                        "item_type": "item",
                        "parent_type": "page",
                        
                        
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
                        "action": "click",
                        "item_name": "Share",
                        "event_type": "analytics",
                        "parent_name": "Offer",
                        "item_type": "button",
                        "parent_type": "page",
                        
                        
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
                        "action": "view",
                        "item_name": "Code",
                        "event_type": "analytics",
                        "parent_name": "Offer",
                        "item_type": "text",
                        "parent_type": "page",
                        
                        
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
                        "action": "view",
                        "item_name": "Offer",
                        "event_type": "analytics",
                        "item_type": "page",
                        
                        
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
                        "action": "view",
                        "item_name": "Spend",
                        "event_type": "analytics",
                        "item_type": "page",
                        
                        
                        "number_of_offers": numberOfOffers, 
                        ]
            }
        } 
        /// user views Explore page, with live ecosystem apps . Event name: `view_Explore_page`
        struct ViewExplorePage: BIEvent {
            let name = "view_Explore_page"
            
            var properties: [String: Any] {
                return [
                        "action": "view",
                        "item_name": "Explore",
                        "event_type": "analytics",
                        "item_type": "page",
                        
                        ]
            }
        } 
        /// user views app details page. Event name: `view_App_page`
        struct ViewAppPage: BIEvent {
            let name = "view_App_page"
            let appCategory: String
            let appId: String
            let appName: String
            let transferReady: Bool
            
            var properties: [String: Any] {
                return [
                        "action": "view",
                        "item_name": "App",
                        "event_type": "analytics",
                        "item_type": "page",
                        
                        
                        "app_category": appCategory,
                        "app_id": appId,
                        "app_name": appName,
                        "transfer_ready": transferReady, 
                        ]
            }
        } 
        /// user clicks to send Kin to specific app in the ecosystem, a specific app page. Event name: `click_Send_button_on_App_page`
        struct ClickSendButtonOnAppPage: BIEvent {
            let name = "click_Send_button_on_App_page"
            let appCategory: String
            let appId: String
            let appName: String
            let transferReady: Bool
            
            var properties: [String: Any] {
                return [
                        "action": "click",
                        "item_name": "Send",
                        "event_type": "analytics",
                        "parent_name": "App",
                        "item_type": "button",
                        "parent_type": "page",
                        
                        
                        "app_category": appCategory,
                        "app_id": appId,
                        "app_name": appName,
                        "transfer_ready": transferReady, 
                        ]
            }
        } 
        /// user clicks to send Kin to specific app in the ecosystem, from the app item (discovery). Event name: `click_Send_button_on_App_item`
        struct ClickSendButtonOnAppItem: BIEvent {
            let name = "click_Send_button_on_App_item"
            let appCategory: String
            let appId: String
            let appName: String
            
            var properties: [String: Any] {
                return [
                        "action": "click",
                        "item_name": "Send",
                        "event_type": "analytics",
                        "parent_name": "App",
                        "item_type": "button",
                        "parent_type": "item",
                        
                        
                        "app_category": appCategory,
                        "app_id": appId,
                        "app_name": appName, 
                        ]
            }
        } 
        /// user clicks on the discovery page to get the app from the app item (discovery). Event name: `click_Get_button_on_App_item`
        struct ClickGetButtonOnAppItem: BIEvent {
            let name = "click_Get_button_on_App_item"
            let appCategory: String
            let appId: String
            let appName: String
            
            var properties: [String: Any] {
                return [
                        "action": "click",
                        "item_name": "Get",
                        "event_type": "analytics",
                        "parent_name": "App",
                        "item_type": "button",
                        "parent_type": "item",
                        
                        
                        "app_category": appCategory,
                        "app_id": appId,
                        "app_name": appName, 
                        ]
            }
        } 
        /// user clicks to get the app from a specific app page. Event name: `click_Get_button_on_App_page`
        struct ClickGetButtonOnAppPage: BIEvent {
            let name = "click_Get_button_on_App_page"
            let appCategory: String
            let appId: String
            let appName: String
            let transferReady: Bool
            
            var properties: [String: Any] {
                return [
                        "action": "click",
                        "item_name": "Get",
                        "event_type": "analytics",
                        "parent_name": "App",
                        "item_type": "button",
                        "parent_type": "page",
                        
                        
                        "app_category": appCategory,
                        "app_id": appId,
                        "app_name": appName,
                        "transfer_ready": transferReady, 
                        ]
            }
        } 
        /// user views the balance page  . Event name: `view_Balance_page`
        struct ViewBalancePage: BIEvent {
            let name = "view_Balance_page"
            
            var properties: [String: Any] {
                return [
                        "action": "view",
                        "item_name": "Balance",
                        "event_type": "analytics",
                        "item_type": "page",
                        
                        ]
            }
        } 
        /// user views the profile page . Event name: `view_Profile_page`
        struct ViewProfilePage: BIEvent {
            let name = "view_Profile_page"
            
            var properties: [String: Any] {
                return [
                        "action": "view",
                        "item_name": "Profile",
                        "event_type": "analytics",
                        "item_type": "page",
                        
                        ]
            }
        } 
        /// users clicks on support button (opens email), on specific FAQ page. Event name: `click_Support_button`
        struct ClickSupportButton: BIEvent {
            let name = "click_Support_button"
            let faqCategory: String
            let faqSubcategory: String
            
            var properties: [String: Any] {
                return [
                        "action": "click",
                        "item_name": "Support",
                        "event_type": "analytics",
                        "item_type": "button",
                        
                        
                        "FAQ_category": faqCategory,
                        "FAQ_subcategory": faqSubcategory, 
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
                        "action": "click",
                        "item_name": "Engagement",
                        "event_type": "analytics",
                        "item_type": "push",
                        
                        
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
                        "action": "click",
                        "item_name": "Reminder",
                        "event_type": "analytics",
                        "parent_name": "Locked_Task",
                        "item_type": "button",
                        "parent_type": "page",
                        
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
                        "action": "view",
                        "item_name": "Engagement",
                        "event_type": "analytics",
                        "item_type": "push",
                        
                        
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
                        "action": "view",
                        "item_name": "Error",
                        "event_type": "analytics",
                        "item_type": "page",
                        
                        
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
                        "action": "click",
                        "item_name": "Retry",
                        "event_type": "analytics",
                        "parent_name": "Error",
                        "item_type": "button",
                        "parent_type": "page",
                        
                        
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
                        "action": "click",
                        "item_name": "Close",
                        "event_type": "analytics",
                        "parent_name": "Error",
                        "item_type": "button",
                        "parent_type": "page",
                        
                        
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
                        "action": "view",
                        "item_name": "Empty_State",
                        "event_type": "analytics",
                        "item_type": "page",
                        
                        
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
                        "action": "click",
                        "item_name": "Contact",
                        "event_type": "analytics",
                        "parent_name": "Error",
                        "item_type": "link",
                        "parent_type": "page",
                        
                        
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
                        "action": "view",
                        "item_name": "Error",
                        "event_type": "analytics",
                        "parent_name": "Offer",
                        "item_type": "popup",
                        "parent_type": "page",
                        
                        
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
                        "action": "click",
                        "item_name": "OK",
                        "event_type": "analytics",
                        "parent_name": "Error",
                        "item_type": "button",
                        "parent_type": "popup",
                        
                        
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
                        "action": "click",
                        "item_name": "Start",
                        "event_type": "analytics",
                        "parent_name": "Onboarding",
                        "item_type": "button",
                        "parent_type": "page",
                        
                        
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
                        "action": "view",
                        "item_name": "Onboarding",
                        "event_type": "analytics",
                        "item_type": "page",
                        
                        
                        "onboarding_tutorial_page": onboardingTutorialPage, 
                        ]
            }
        } 
        /// user views the phone authentication page when phone number should be inserted. Event name: `view_Phone_Auth_page`
        struct ViewPhoneAuthPage: BIEvent {
            let name = "view_Phone_Auth_page"
            
            var properties: [String: Any] {
                return [
                        "action": "view",
                        "item_name": "Phone_Auth",
                        "event_type": "analytics",
                        "item_type": "page",
                        
                        ]
            }
        } 
        /// user click the button to continue to verification page. Event name: `click_Next_button_on_Phone_Auth_page`
        struct ClickNextButtonOnPhoneAuthPage: BIEvent {
            let name = "click_Next_button_on_Phone_Auth_page"
            
            var properties: [String: Any] {
                return [
                        "action": "click",
                        "item_name": "Next",
                        "event_type": "analytics",
                        "parent_name": "Phone_Auth",
                        "item_type": "button",
                        "parent_type": "page",
                        
                        ]
            }
        } 
        /// user views the verification page, where a verification code should be inserted. Event name: `view_Verification_page`
        struct ViewVerificationPage: BIEvent {
            let name = "view_Verification_page"
            
            var properties: [String: Any] {
                return [
                        "action": "view",
                        "item_name": "Verification",
                        "event_type": "analytics",
                        "item_type": "page",
                        
                        ]
            }
        } 
        /// user gets an error message when entering a wrong verification code. Event name: `view_Error_message_on_Verification_page`
        struct ViewErrorMessageOnVerificationPage: BIEvent {
            let name = "view_Error_message_on_Verification_page"
            
            var properties: [String: Any] {
                return [
                        "action": "view",
                        "item_name": "Error",
                        "event_type": "analytics",
                        "parent_name": "Verification",
                        "item_type": "message",
                        "parent_type": "page",
                        
                        ]
            }
        } 
        /// user view the completion message after successfully completed onboarding. Event name: `view_Onboarding_Completed_page`
        struct ViewOnboardingCompletedPage: BIEvent {
            let name = "view_Onboarding_Completed_page"
            
            var properties: [String: Any] {
                return [
                        "action": "view",
                        "item_name": "Onboarding_Completed",
                        "event_type": "analytics",
                        "item_type": "page",
                        
                        ]
            }
        } 
        /// user clicks the new code link to receive a new SMS with verification code. Event name: `click_New_Code_link_on_Verification_page`
        struct ClickNewCodeLinkOnVerificationPage: BIEvent {
            let name = "click_New_Code_link_on_Verification_page"
            let verificationCodeCount: Int
            
            var properties: [String: Any] {
                return [
                        "action": "click",
                        "item_name": "New_Code",
                        "event_type": "analytics",
                        "parent_name": "Verification",
                        "item_type": "link",
                        "parent_type": "page",
                        
                        
                        "verification_code_count": verificationCodeCount, 
                        ]
            }
        } 
        /// existing user receives a popup message explaining the phone auth required. Event name: `view_Phone_Auth_popup`
        struct ViewPhoneAuthPopup: BIEvent {
            let name = "view_Phone_Auth_popup"
            
            var properties: [String: Any] {
                return [
                        "action": "view",
                        "item_name": "Phone_Auth",
                        "event_type": "analytics",
                        "item_type": "popup",
                        
                        ]
            }
        } 
        /// existing user clicks the button on the popup message to start phone auth flow. Event name: `click_Verify_button_on_Phone_Auth_popup`
        struct ClickVerifyButtonOnPhoneAuthPopup: BIEvent {
            let name = "click_Verify_button_on_Phone_Auth_popup"
            
            var properties: [String: Any] {
                return [
                        "action": "click",
                        "item_name": "Verify",
                        "event_type": "analytics",
                        "parent_name": "Phone_Auth",
                        "item_type": "button",
                        "parent_type": "popup",
                        
                        ]
            }
        } 
        /// user views the Send Kin page where he sets up the Kin amount he wants to send to a friend. Event name: `view_Send_Kin_page`
        struct ViewSendKinPage: BIEvent {
            let name = "view_Send_Kin_page"
            
            var properties: [String: Any] {
                return [
                        "action": "view",
                        "item_name": "Send_Kin",
                        "event_type": "analytics",
                        "item_type": "page",
                        
                        ]
            }
        } 
        /// user clicks on the Send button to send Kin to a friend. Event name: `click_Send_button_on_Send_Kin_page`
        struct ClickSendButtonOnSendKinPage: BIEvent {
            let name = "click_Send_button_on_Send_Kin_page"
            let kinAmount: Int
            
            var properties: [String: Any] {
                return [
                        "action": "click",
                        "item_name": "Send",
                        "event_type": "analytics",
                        "parent_name": "Send_Kin",
                        "item_type": "button",
                        "parent_type": "page",
                        
                        
                        "KIN_amount": kinAmount, 
                        ]
            }
        } 
        /// user views the success message on successful transaction of Kin to a friend. Event name: `view_Success_message_on_Send_Kin_page`
        struct ViewSuccessMessageOnSendKinPage: BIEvent {
            let name = "view_Success_message_on_Send_Kin_page"
            let kinAmount: Int
            
            var properties: [String: Any] {
                return [
                        "action": "view",
                        "item_name": "Success",
                        "event_type": "analytics",
                        "parent_name": "Send_Kin",
                        "item_type": "message",
                        "parent_type": "page",
                        
                        
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
                        "action": "view",
                        "item_name": "Error",
                        "event_type": "analytics",
                        "parent_name": "Send_Kin",
                        "item_type": "popup",
                        "parent_type": "page",
                        
                        
                        "error_type": errorType.rawValue, 
                        ]
            }
        } 
        /// user views the Video page as part of a "tip" task . Event name: `view_Video_page`
        struct ViewVideoPage: BIEvent {
            let name = "view_Video_page"
            
            var properties: [String: Any] {
                return [
                        "action": "view",
                        "item_name": "Video",
                        "event_type": "analytics",
                        "item_type": "page",
                        
                        ]
            }
        } 
        /// user playes the Video page as part of a "tip" task . Event name: `click_Play_button_on_Video_page`
        struct ClickPlayButtonOnVideoPage: BIEvent {
            let name = "click_Play_button_on_Video_page"
            let videoTitle: String
            
            var properties: [String: Any] {
                return [
                        "action": "click",
                        "item_name": "Play",
                        "event_type": "analytics",
                        "parent_name": "Video",
                        "item_type": "button",
                        "parent_type": "page",
                        
                        
                        "video_title": videoTitle, 
                        ]
            }
        } 
        /// user views the backup intro page. Event name: `view_Backup_Intro_page`
        struct ViewBackupIntroPage: BIEvent {
            let name = "view_Backup_Intro_page"
            
            var properties: [String: Any] {
                return [
                        "action": "view",
                        "item_name": "Backup_Intro",
                        "event_type": "analytics",
                        "item_type": "page",
                        
                        ]
            }
        } 
        /// user clicks the button on the backup intro page to start the backup flow. Event name: `click_Backup_button_on_Backup_Intro_page`
        struct ClickBackupButtonOnBackupIntroPage: BIEvent {
            let name = "click_Backup_button_on_Backup_Intro_page"
            
            var properties: [String: Any] {
                return [
                        "action": "click",
                        "item_name": "Backup",
                        "event_type": "analytics",
                        "parent_name": "Backup_Intro",
                        "item_type": "button",
                        "parent_type": "page",
                        
                        ]
            }
        } 
        /// user views any of the steps on the backup flow (total of 5 steps). Event name: `view_Backup_Flow_page`
        struct ViewBackupFlowPage: BIEvent {
            let name = "view_Backup_Flow_page"
            let backupFlowStep: BackupFlowStep
            
            var properties: [String: Any] {
                return [
                        "action": "view",
                        "item_name": "Backup_Flow",
                        "event_type": "analytics",
                        "item_type": "page",
                        
                        
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
                        "action": "click",
                        "item_name": "Completed_Step",
                        "event_type": "analytics",
                        "parent_name": "Backup_Flow",
                        "item_type": "button",
                        "parent_type": "page",
                        
                        
                        "backup_flow_step": backupFlowStep.rawValue, 
                        ]
            }
        } 
        /// user views the completion message after successfully completed backup flow. Event name: `view_Backup_Completed_page`
        struct ViewBackupCompletedPage: BIEvent {
            let name = "view_Backup_Completed_page"
            
            var properties: [String: Any] {
                return [
                        "action": "view",
                        "item_name": "Backup_Completed",
                        "event_type": "analytics",
                        "item_type": "page",
                        
                        ]
            }
        } 
        /// user views the backup notification popup after completing last earn activity for day 1/7/14/30. Event name: `view_Backup_Notification_popup`
        struct ViewBackupNotificationPopup: BIEvent {
            let name = "view_Backup_Notification_popup"
            let backupNotificationType: BackupNotificationType
            
            var properties: [String: Any] {
                return [
                        "action": "view",
                        "item_name": "Backup_Notification",
                        "event_type": "analytics",
                        "item_type": "popup",
                        
                        
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
                        "action": "click",
                        "item_name": "Backup",
                        "event_type": "analytics",
                        "parent_name": "Backup_Notification",
                        "item_type": "button",
                        "parent_type": "popup",
                        
                        
                        "backup_notification_type": backupNotificationType.rawValue, 
                        ]
            }
        } 
        /// existing user views welcome back page after completing phone verification. Event name: `view_Welcome_Back_page`
        struct ViewWelcomeBackPage: BIEvent {
            let name = "view_Welcome_Back_page"
            
            var properties: [String: Any] {
                return [
                        "action": "view",
                        "item_name": "Welcome_Back",
                        "event_type": "analytics",
                        "item_type": "page",
                        
                        ]
            }
        } 
        /// user chooses to restore wallet on welcome back page. Event name: `click_Restore_Wallet_button_on_Welcome_Back_page`
        struct ClickRestoreWalletButtonOnWelcomeBackPage: BIEvent {
            let name = "click_Restore_Wallet_button_on_Welcome_Back_page"
            
            var properties: [String: Any] {
                return [
                        "action": "click",
                        "item_name": "Restore_Wallet",
                        "event_type": "analytics",
                        "parent_name": "Welcome_Back",
                        "item_type": "button",
                        "parent_type": "page",
                        
                        ]
            }
        } 
        /// user chooses to create new wallet on welcome back page. Event name: `click_Create_New_Wallet_button_on_Welcome_Back_page`
        struct ClickCreateNewWalletButtonOnWelcomeBackPage: BIEvent {
            let name = "click_Create_New_Wallet_button_on_Welcome_Back_page"
            
            var properties: [String: Any] {
                return [
                        "action": "click",
                        "item_name": "Create_New_Wallet",
                        "event_type": "analytics",
                        "parent_name": "Welcome_Back",
                        "item_type": "button",
                        "parent_type": "page",
                        
                        ]
            }
        } 
        /// user views the scan page after staring the restore flow. Event name: `view_Scan_page`
        struct ViewScanPage: BIEvent {
            let name = "view_Scan_page"
            
            var properties: [String: Any] {
                return [
                        "action": "view",
                        "item_name": "Scan",
                        "event_type": "analytics",
                        "item_type": "page",
                        
                        ]
            }
        } 
        /// user clicks the Scan button to start scanning the process of the QR code. Event name: `click_Scan_button_on_2_Steps_Away_page`
        struct ClickScanButtonOn2StepsAwayPage: BIEvent {
            let name = "click_Scan_button_on_2_Steps_Away_page"
            
            var properties: [String: Any] {
                return [
                        "action": "click",
                        "item_name": "Scan",
                        "event_type": "analytics",
                        "parent_name": "2_Steps_Away",
                        "item_type": "button",
                        "parent_type": "page",
                        
                        ]
            }
        } 
        /// user views the security questions page as part of the restore flow. Event name: `view_Answer_Security_Questions_page`
        struct ViewAnswerSecurityQuestionsPage: BIEvent {
            let name = "view_Answer_Security_Questions_page"
            
            var properties: [String: Any] {
                return [
                        "action": "view",
                        "item_name": "Answer_Security_Questions",
                        "event_type": "analytics",
                        "item_type": "page",
                        
                        ]
            }
        } 
        /// user confirms the answers entered for security questions as part of the restore flow (the button is "Next" and not confirm). Event name: `click_Confirm_button_on_Answer_Security_Questions_page`
        struct ClickConfirmButtonOnAnswerSecurityQuestionsPage: BIEvent {
            let name = "click_Confirm_button_on_Answer_Security_Questions_page"
            
            var properties: [String: Any] {
                return [
                        "action": "click",
                        "item_name": "Confirm",
                        "event_type": "analytics",
                        "parent_name": "Answer_Security_Questions",
                        "item_type": "button",
                        "parent_type": "page",
                        
                        ]
            }
        } 
        /// user views the completion message after successfully restoring the wallet. Event name: `view_Wallet_Restored_page`
        struct ViewWalletRestoredPage: BIEvent {
            let name = "view_Wallet_Restored_page"
            
            var properties: [String: Any] {
                return [
                        "action": "view",
                        "item_name": "Wallet_Restored",
                        "event_type": "analytics",
                        "item_type": "page",
                        
                        ]
            }
        } 
        /// user views the creating wallet page (animation) when creating new wallet. Event name: `view_Creating_Wallet_page`
        struct ViewCreatingWalletPage: BIEvent {
            let name = "view_Creating_Wallet_page"
            
            var properties: [String: Any] {
                return [
                        "action": "view",
                        "item_name": "Creating_Wallet",
                        "event_type": "analytics",
                        "item_type": "page",
                        
                        ]
            }
        } 
        /// user clicks on backup button on More page. Event name: `click_Backup_button_on_More_page`
        struct ClickBackupButtonOnMorePage: BIEvent {
            let name = "click_Backup_button_on_More_page"
            let alreadyBackedUp: AlreadyBackedUp
            
            var properties: [String: Any] {
                return [
                        "action": "click",
                        "item_name": "Backup",
                        "event_type": "analytics",
                        "parent_name": "More",
                        "item_type": "button",
                        "parent_type": "page",
                        
                        
                        "already_backed_up": alreadyBackedUp.rawValue, 
                        ]
            }
        } 
        /// user views the FAQ main page (with all the categories). Event name: `view_FAQ_Main_page`
        struct ViewFaqMainPage: BIEvent {
            let name = "view_FAQ_Main_page"
            
            var properties: [String: Any] {
                return [
                        "action": "view",
                        "item_name": "FAQ_Main",
                        "event_type": "analytics",
                        "item_type": "page",
                        
                        ]
            }
        } 
        /// user views a FAQ specific page . Event name: `view_FAQ_page`
        struct ViewFaqPage: BIEvent {
            let name = "view_FAQ_page"
            let faqCategory: String
            let faqSubcategory: String
            
            var properties: [String: Any] {
                return [
                        "action": "view",
                        "item_name": "FAQ",
                        "event_type": "analytics",
                        "item_type": "page",
                        
                        
                        "FAQ_category": faqCategory,
                        "FAQ_subcategory": faqSubcategory, 
                        ]
            }
        } 
        /// user clicks the feedback button on the More page. Event name: `click_Feedback_button`
        struct ClickFeedbackButton: BIEvent {
            let name = "click_Feedback_button"
            
            var properties: [String: Any] {
                return [
                        "action": "click",
                        "item_name": "Feedback",
                        "event_type": "analytics",
                        "item_type": "button",
                        
                        ]
            }
        } 
        /// user clicks the Yes/No buttons on FAQ page, to share if the page info was helpful or not. Event name: `click_Page_Helpful_button_on_FAQ_page`
        struct ClickPageHelpfulButtonOnFaqPage: BIEvent {
            let name = "click_Page_Helpful_button_on_FAQ_page"
            let faqCategory: String
            let faqSubcategory: String
            let helpful: Bool
            
            var properties: [String: Any] {
                return [
                        "action": "click",
                        "item_name": "Page_Helpful",
                        "event_type": "analytics",
                        "parent_name": "FAQ",
                        "item_type": "button",
                        "parent_type": "page",
                        
                        
                        "FAQ_category": faqCategory,
                        "FAQ_subcategory": faqSubcategory,
                        "Helpful": helpful, 
                        ]
            }
        } 
        /// User views captcha popup. Event name: `view_Captcha_popup`
        struct ViewCaptchaPopup: BIEvent {
            let name = "view_Captcha_popup"
            
            var properties: [String: Any] {
                return [
                        "action": "view",
                        "item_name": "Captcha",
                        "event_type": "analytics",
                        "item_type": "popup",
                        
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
                        "action": "view",
                        "item_name": "Campaign",
                        "event_type": "analytics",
                        "item_type": "popup",
                        
                        
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
                        "action": "click",
                        "item_name": "Link",
                        "event_type": "analytics",
                        "parent_name": "Campaign",
                        "item_type": "button",
                        "parent_type": "popup",
                        
                        
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
                        "action": "view",
                        "item_name": "Task_Categories",
                        "event_type": "analytics",
                        "item_type": "page",
                        
                        ]
            }
        } 
        /// User clicks a specific task category. Event name: `click_Category_button_on_Task_Categories_page`
        struct ClickCategoryButtonOnTaskCategoriesPage: BIEvent {
            let name = "click_Category_button_on_Task_Categories_page"
            let taskCategory: String
            
            var properties: [String: Any] {
                return [
                        "action": "click",
                        "item_name": "Category",
                        "event_type": "analytics",
                        "parent_name": "Task_Categories",
                        "item_type": "button",
                        "parent_type": "page",
                        
                        
                        "task_category": taskCategory, 
                        ]
            }
        } 
        /// User views Learn More page about any topic (event can be triggered for any Learn page we will have). Event name: `view_Learn_More_page`
        struct ViewLearnMorePage: BIEvent {
            let name = "view_Learn_More_page"
            let pageContent: PageContent
            
            var properties: [String: Any] {
                return [
                        "action": "view",
                        "item_name": "Learn_More",
                        "event_type": "analytics",
                        "item_type": "page",
                        
                        
                        "page_content": pageContent.rawValue, 
                        ]
            }
        } 
        /// User clicks the "I need help" button to get help. Event name: `click_Help_button_on_More_page`
        struct ClickHelpButtonOnMorePage: BIEvent {
            let name = "click_Help_button_on_More_page"
            
            var properties: [String: Any] {
                return [
                        "action": "click",
                        "item_name": "Help",
                        "event_type": "analytics",
                        "parent_name": "More",
                        "item_type": "button",
                        "parent_type": "page",
                        
                        ]
            }
        } 
        /// User clicks the "contact us" button after choosing a category and a sub category from the FAQ page. Event name: `click_Contact_button_on_Specific_FAQ_page`
        struct ClickContactButtonOnSpecificFaqPage: BIEvent {
            let name = "click_Contact_button_on_Specific_FAQ_page"
            let faqCategory: String
            let faqSubcategory: String
            
            var properties: [String: Any] {
                return [
                        "action": "click",
                        "item_name": "Contact",
                        "event_type": "analytics",
                        "parent_name": "Specific_FAQ",
                        "item_type": "button",
                        "parent_type": "page",
                        
                        
                        "FAQ_category": faqCategory,
                        "FAQ_subcategory": faqSubcategory, 
                        ]
            }
        } 
        /// User clicks on the "submit" button to send a Support form. Event name: `click_Submit_button_on_Support_form_page`
        struct ClickSubmitButtonOnSupportFormPage: BIEvent {
            let name = "click_Submit_button_on_Support_form_page"
            let faqCategory: String
            let faqSubcategory: String
            
            var properties: [String: Any] {
                return [
                        "action": "click",
                        "item_name": "Submit",
                        "event_type": "analytics",
                        "parent_name": "Support_form",
                        "item_type": "button",
                        "parent_type": "page",
                        
                        
                        "FAQ_category": faqCategory,
                        "FAQ_subcategory": faqSubcategory, 
                        ]
            }
        } 
        /// User clicks on the "submit" button to send a Feedback form. Event name: `click_Submit_button_on_Feedback_form`
        struct ClickSubmitButtonOnFeedbackForm: BIEvent {
            let name = "click_Submit_button_on_Feedback_form"
            
            var properties: [String: Any] {
                return [
                        "action": "click",
                        "item_name": "Submit",
                        "event_type": "analytics",
                        "parent_name": "Feedback",
                        "item_type": "button",
                        "parent_type": "form",
                        
                        ]
            }
        } 
        /// User click on "Yes" or "No" to tell us whether the FAQ page was helpful or not. Event name: `click_Helpful_button_on_FAQ_page`
        struct ClickHelpfulButtonOnFaqPage: BIEvent {
            let name = "click_Helpful_button_on_FAQ_page"
            let helpful: Bool
            
            var properties: [String: Any] {
                return [
                        "action": "click",
                        "item_name": "Helpful",
                        "event_type": "analytics",
                        "parent_name": "FAQ",
                        "item_type": "button",
                        "parent_type": "page",
                        
                        
                        "Helpful": helpful, 
                        ]
            }
        } 
        /// User clicks on "Start Now" to choose fav content. Event name: `click_Start_Now_button_on_Fav_Topics_popup`
        struct ClickStartNowButtonOnFavTopicsPopup: BIEvent {
            let name = "click_Start_Now_button_on_Fav_Topics_popup"
            
            var properties: [String: Any] {
                return [
                        "action": "click",
                        "item_name": "Start_Now",
                        "event_type": "analytics",
                        "parent_name": "Fav_Topics",
                        "item_type": "button",
                        "parent_type": "popup",
                        
                        ]
            }
        } 
        /// User clicks on "My Topics" to choose fav content. Event name: `click_My_Topics_button_on_More_page`
        struct ClickMyTopicsButtonOnMorePage: BIEvent {
            let name = "click_My_Topics_button_on_More_page"
            
            var properties: [String: Any] {
                return [
                        "action": "click",
                        "item_name": "My_Topics",
                        "event_type": "analytics",
                        "parent_name": "More",
                        "item_type": "button",
                        "parent_type": "page",
                        
                        ]
            }
        } 
        /// User clicks "Done" after choosing at least 5 topics he/she's interested in. Event name: `click_Done_button_on_Topics_page`
        struct ClickDoneButtonOnTopicsPage: BIEvent {
            let name = "click_Done_button_on_Topics_page"
            let topic: Topic
            
            var properties: [String: Any] {
                return [
                        "action": "click",
                        "item_name": "Done",
                        "event_type": "analytics",
                        "parent_name": "Topics",
                        "item_type": "button",
                        "parent_type": "page",
                        
                        
                        "topic": topic.rawValue, 
                        ]
            }
        } 
        /// User clicks on Backup Now in the Backup my Kin page . Event name: `click_Backup_Now_button_on_Backup_My_Kin_page`
        struct ClickBackupNowButtonOnBackupMyKinPage: BIEvent {
            let name = "click_Backup_Now_button_on_Backup_My_Kin_page"
            
            var properties: [String: Any] {
                return [
                        "action": "click",
                        "item_name": "Backup_Now",
                        "event_type": "analytics",
                        "parent_name": "Backup_My_Kin",
                        "item_type": "button",
                        "parent_type": "page",
                        
                        ]
            }
        } 
        /// User clicks Confirm after entering a 4-digit code to approve a QR code was received to his/her mail. Event name: `click_Confirm_button_on_Check_Mail_page`
        struct ClickConfirmButtonOnCheckMailPage: BIEvent {
            let name = "click_Confirm_button_on_Check_Mail_page"
            
            var properties: [String: Any] {
                return [
                        "action": "click",
                        "item_name": "Confirm",
                        "event_type": "analytics",
                        "parent_name": "Check_Mail",
                        "item_type": "button",
                        "parent_type": "page",
                        
                        ]
            }
        } 
        /// user clicks the Upload button to upload his/her saved QR code. Event name: `click_Upload_QR_button_on_2_Steps_Away_page`
        struct ClickUploadQrButtonOn2StepsAwayPage: BIEvent {
            let name = "click_Upload_QR_button_on_2_Steps_Away_page"
            
            var properties: [String: Any] {
                return [
                        "action": "click",
                        "item_name": "Upload_QR",
                        "event_type": "analytics",
                        "parent_name": "2_Steps_Away",
                        "item_type": "button",
                        "parent_type": "page",
                        
                        ]
            }
        } 
        /// User clicks Next after filling the 2 security answers. Event name: `click_Next_button_on_1_Step_Away_page`
        struct ClickNextButtonOn1StepAwayPage: BIEvent {
            let name = "click_Next_button_on_1_Step_Away_page"
            
            var properties: [String: Any] {
                return [
                        "action": "click",
                        "item_name": "Next",
                        "event_type": "analytics",
                        "parent_name": "1_Step_Away",
                        "item_type": "button",
                        "parent_type": "page",
                        
                        ]
            }
        } 
        /// User chooses to re-backup his/her wallet on a popup that will display to 50% of users who already backed up in the past. Event name: `click_Update_Backup_button_on_Getting_Better_popup`
        struct ClickUpdateBackupButtonOnGettingBetterPopup: BIEvent {
            let name = "click_Update_Backup_button_on_Getting_Better_popup"
            
            var properties: [String: Any] {
                return [
                        "action": "click",
                        "item_name": "Update_Backup",
                        "event_type": "analytics",
                        "parent_name": "Getting_Better",
                        "item_type": "button",
                        "parent_type": "popup",
                        
                        ]
            }
        } 
        /// User views the "We're getting better" popup that will display to 50% of users who already backed up in the past. Event name: `view_Getting_Better_popup`
        struct ViewGettingBetterPopup: BIEvent {
            let name = "view_Getting_Better_popup"
            
            var properties: [String: Any] {
                return [
                        "action": "view",
                        "item_name": "Getting_Better",
                        "event_type": "analytics",
                        "item_type": "popup",
                        
                        ]
            }
        } 
        /// User clicks on the start button to start scanning . Event name: `click_Scan_button_on_Scan_page`
        struct ClickScanButtonOnScanPage: BIEvent {
            let name = "click_Scan_button_on_Scan_page"
            
            var properties: [String: Any] {
                return [
                        "action": "click",
                        "item_name": "Scan",
                        "event_type": "analytics",
                        "parent_name": "Scan",
                        "item_type": "button",
                        "parent_type": "page",
                        
                        ]
            }
        } 
        /// User clicks Top up Tippic after choosing the amount to Top up on Kinit's calculator. Event name: `click_Top_up_tippic_button_on_Calculator_screen`
        struct ClickTopUpTippicButtonOnCalculatorScreen: BIEvent {
            let name = "click_Top_up_tippic_button_on_Calculator_screen"
            
            var properties: [String: Any] {
                return [
                        "action": "click",
                        "item_name": "Top_up_tippic",
                        "event_type": "analytics",
                        "parent_name": "Calculator",
                        "item_type": "button",
                        "parent_type": "screen",
                        
                        ]
            }
        } 
        /// User clicks Back to Tippic, to go back from Kinit to Tippic. Event name: `click_Back_to_tippic_link_on_Calculator_screen`
        struct ClickBackToTippicLinkOnCalculatorScreen: BIEvent {
            let name = "click_Back_to_tippic_link_on_Calculator_screen"
            
            var properties: [String: Any] {
                return [
                        "action": "click",
                        "item_name": "Back_to_tippic",
                        "event_type": "analytics",
                        "parent_name": "Calculator",
                        "item_type": "link",
                        "parent_type": "screen",
                        
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
                        "action": "click",
                        "item_name": "Buy",
                        "event_type": "analytics",
                        "parent_name": "Offer",
                        "item_type": "button",
                        "parent_type": "page",
                        
                        
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