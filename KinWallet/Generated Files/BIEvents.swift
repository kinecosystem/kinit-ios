//
// BIEvents.swift
//
// Don't edit this file.
// Generated at 2018-04-11 09:06:09 +0000 by Kik BI-Generator.
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
        case spend = "spend"
    }
    
    enum TaskType: String { 
        case inviteFriend = "invite friend"
        case questionnaire = "questionnaire"
        case quiz = "quiz"
        case video = "video"
    }
    
    enum MenuItemName: String { 
        case balance = "Balance"
        case earn = "Earn"
        case more = "More"
        case spend = "Spend"
    }
    
    enum QuestionType: String { 
        case text = "text"
        case textEmoji = "text-emoji"
        case textImage = "text-image"
        case textMultiple = "text-multiple"
    }
    
    enum ErrorType: String { 
        case codeNotProvided = "Code not provided"
        case internetConnection = "Internet Connection"
        case offerNotAvailable = "Offer not available"
        case onboarding = "Onboarding"
        case reward = "Reward"
        case taskSubmission = "Task Submission"
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
        /// user was successfully created in the server (user_id). Event name: `user_registered`
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
    } 
    struct Analytics { 
        /// user views splash screen (=app launch). Event name: `view_Splashscreen_page`
        struct ViewSplashscreenPage: BIEvent {
            let name = "view_Splashscreen_page"
            
            var properties: [String: Any] {
                return [
                        "item_name": "Splashscreen",
                        "item_type": "page",
                        "action": "view",
                        "event_type": "analytics",
                        
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
                        "action": "click",
                        "event_type": "analytics",
                        
                        
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
                        "action": "click",
                        "event_type": "analytics",
                        "parent_name": "Question",
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
                        "item_name": "Close",
                        "item_type": "button",
                        "action": "click",
                        "event_type": "analytics",
                        "parent_name": "Question",
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
                        "item_name": "Close",
                        "item_type": "button",
                        "action": "click",
                        "event_type": "analytics",
                        "parent_name": "Reward",
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
                        "item_name": "Start",
                        "item_type": "button",
                        "action": "click",
                        "event_type": "analytics",
                        "parent_name": "Task",
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
                        "item_name": "KIN_Provided",
                        "item_type": "image",
                        "action": "view",
                        "event_type": "analytics",
                        "parent_name": "Reward",
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
                        "item_name": "Locked_Task",
                        "item_type": "page",
                        "action": "view",
                        "event_type": "analytics",
                        
                        
                        "time_to_unlock": timeToUnlock, 
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
                        "action": "view",
                        "event_type": "analytics",
                        
                        
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
                        "action": "view",
                        "event_type": "analytics",
                        
                        
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
                        "action": "view",
                        "event_type": "analytics",
                        
                        
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
                        "action": "click",
                        "event_type": "analytics",
                        "parent_name": "Offer",
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
                        "action": "click",
                        "event_type": "analytics",
                        "parent_name": "Spend",
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
                        "item_name": "Share",
                        "item_type": "button",
                        "action": "click",
                        "event_type": "analytics",
                        "parent_name": "Offer",
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
                        "item_name": "Code",
                        "item_type": "text",
                        "action": "view",
                        "event_type": "analytics",
                        "parent_name": "Offer",
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
                        "item_name": "Offer",
                        "item_type": "page",
                        "action": "view",
                        "event_type": "analytics",
                        
                        
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
                        "action": "view",
                        "event_type": "analytics",
                        
                        
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
                        "action": "view",
                        "event_type": "analytics",
                        
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
                        "action": "view",
                        "event_type": "analytics",
                        
                        ]
            }
        } 
        /// users clicks on support button (opens email). Event name: `click_Support_button`
        struct ClickSupportButton: BIEvent {
            let name = "click_Support_button"
            
            var properties: [String: Any] {
                return [
                        "item_name": "Support",
                        "item_type": "button",
                        "action": "click",
                        "event_type": "analytics",
                        
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
                        "action": "click",
                        "event_type": "analytics",
                        
                        
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
                        "action": "click",
                        "event_type": "analytics",
                        "parent_name": "Locked_Task",
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
                        "item_name": "Engagement",
                        "item_type": "push",
                        "action": "view",
                        "event_type": "analytics",
                        
                        
                        "push_id": pushId,
                        "push_text": pushText, 
                        ]
            }
        } 
        /// user views any of the error pages: onboarding, reward, submission, connection. Event name: `view_Error_page`
        struct ViewErrorPage: BIEvent {
            let name = "view_Error_page"
            let errorType: ErrorType
            
            var properties: [String: Any] {
                return [
                        "item_name": "Error",
                        "item_type": "page",
                        "action": "view",
                        "event_type": "analytics",
                        
                        
                        "error_type": errorType.rawValue, 
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
                        "action": "click",
                        "event_type": "analytics",
                        "parent_name": "Error",
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
                        "item_name": "Close",
                        "item_type": "button",
                        "action": "click",
                        "event_type": "analytics",
                        "parent_name": "Error",
                        "parent_type": "page",
                        
                        
                        "error_type": errorType.rawValue, 
                        ]
            }
        } 
        /// user views empty state for no earn tasks / spend offers. Event name: `view_Empty_State_page`
        struct ViewEmptyStatePage: BIEvent {
            let name = "view_Empty_State_page"
            let menuItemName: MenuItemName
            
            var properties: [String: Any] {
                return [
                        "item_name": "Empty_State",
                        "item_type": "page",
                        "action": "view",
                        "event_type": "analytics",
                        
                        
                        "menu_item_name": menuItemName.rawValue, 
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
                        "action": "click",
                        "event_type": "analytics",
                        "parent_name": "Error",
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
                        "item_name": "Error",
                        "item_type": "popup",
                        "action": "view",
                        "event_type": "analytics",
                        "parent_name": "Offer",
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
                        "item_name": "OK",
                        "item_type": "button",
                        "action": "click",
                        "event_type": "analytics",
                        "parent_name": "Error",
                        "parent_type": "popup",
                        
                        
                        "error_type": errorType.rawValue, 
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
                        "action": "view",
                        "event_type": "analytics",
                        
                        
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
    } 
}