//
//  HealthInfo.swift
//  PharmacyApp
//
//  Created by Omar Al dulaimi on 2025-03-02.
//

import Foundation

struct HealthInfo: Identifiable, Codable {
    var id: String = UUID().uuidString
    var title: String
    var summary: String
    var content: String
    var category: HealthInfoCategory
    var imageUrl: String?
    var publishDate: Date
    var isRead: Bool = false
    var readDate: Date?
    var awardsBadge: Bool = false
    var relatedBadgeId: String?
    
    enum HealthInfoCategory: String, Codable {
        case general = "General Health"
        case condition = "Health Condition"
        case medication = "Medication Information"
        case awareness = "Health Awareness"
        case nutrition = "Nutrition"
        case exercise = "Exercise"
    }
    
    static var examples: [HealthInfo] {
        let now = Date()
        return [
            HealthInfo(
                title: "World Leukemia Day",
                summary: "Learn about advances in leukemia treatment and awareness",
                content: """
                September 4th marks World Leukemia Day, a time to raise awareness about this type of blood cancer that affects both children and adults.
                
                Leukemia is a type of cancer that affects the blood and bone marrow. It occurs when the body produces large numbers of abnormal white blood cells. These cells crowd out normal white blood cells, red blood cells, and platelets, making it difficult for the body to fight infections, carry oxygen, and control bleeding.
                
                Recent advances in treatment have significantly improved outcomes for many leukemia patients. Targeted therapies, immunotherapies, and CAR-T cell therapy are revolutionizing how we treat various forms of leukemia.
                
                Early symptoms to watch for include:
                - Fatigue and weakness
                - Frequent infections
                - Easy bruising or bleeding
                - Fever or night sweats
                - Unexplained weight loss
                
                Regular check-ups and blood tests can help detect leukemia early. If you experience any concerning symptoms, consult with your healthcare provider.
                """,
                category: .awareness,
                imageUrl: "leukemia_awareness",
                publishDate: now.addingTimeInterval(-86400 * 2),
                awardsBadge: true,
                relatedBadgeId: "badge_leukemia_awareness"
            ),
            HealthInfo(
                title: "Managing Type 2 Diabetes",
                summary: "Tips for effectively managing blood sugar levels",
                content: """
                Type 2 diabetes is a chronic condition that affects the way your body metabolizes sugar. With type 2 diabetes, your body either resists the effects of insulin — a hormone that regulates the movement of sugar into your cells — or doesn't produce enough insulin to maintain normal glucose levels.
                
                Here are some strategies for managing type 2 diabetes:
                
                1. Monitor your blood sugar regularly
                2. Take prescribed medications consistently
                3. Eat a balanced diet with controlled carbohydrate intake
                4. Exercise regularly - aim for at least 150 minutes per week
                5. Maintain a healthy weight
                6. Manage stress effectively
                7. Get regular check-ups with your healthcare providers
                
                Remember that lifestyle changes can significantly impact your blood sugar control. Small, consistent improvements to diet and physical activity can make a big difference in your overall health when living with diabetes.
                
                Always consult with your healthcare team before making major changes to your diabetes management plan.
                """,
                category: .condition,
                imageUrl: "diabetes_management",
                publishDate: now.addingTimeInterval(-86400 * 10),
                awardsBadge: true,
                relatedBadgeId: "badge_diabetes_knowledge"
            ),
            HealthInfo(
                title: "Understanding Your Blood Pressure Medication",
                summary: "Key information about common blood pressure medications",
                content: """
                High blood pressure (hypertension) is a common condition that can lead to serious health problems if left untreated. Medications are often prescribed to help manage blood pressure, along with lifestyle modifications.
                
                Common types of blood pressure medications include:
                
                - ACE inhibitors (e.g., lisinopril, enalapril)
                - Angiotensin II receptor blockers (ARBs) (e.g., losartan, valsartan)
                - Calcium channel blockers (e.g., amlodipine, diltiazem)
                - Diuretics (e.g., hydrochlorothiazide, furosemide)
                - Beta-blockers (e.g., metoprolol, atenolol)
                
                Each medication works differently to lower blood pressure. It's important to take your medication exactly as prescribed, even if you feel fine. Many people with high blood pressure don't have symptoms, but the condition can still damage your heart, blood vessels, and other organs.
                
                Side effects vary by medication type. Common side effects may include dizziness, fatigue, or changes in urination. Always discuss any side effects with your healthcare provider rather than stopping medication on your own.
                
                Remember to monitor your blood pressure regularly and keep all follow-up appointments with your healthcare provider to ensure your treatment plan is working effectively.
                """,
                category: .medication,
                imageUrl: "bp_medication",
                publishDate: now.addingTimeInterval(-86400 * 5),
                awardsBadge: false
            )
        ]
    }
}
