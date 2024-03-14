//
//  UserProfileViewModel.swift
//  CS125
//
//  Created by zhe yuan on 2/22/24.
//

import FirebaseCore
import FirebaseFirestore

class UserProfileViewModel: ObservableObject {
    let db = Firestore.firestore()
    
    @Published var foodAllergies: [String] = []
    @Published var foodCategories: [String] = []
    @Published var age: Int = 18
    @Published var weight: Int = 120
    @Published var targetWeight: Int = 120
    @Published var height: Int = 180
    @Published var sex: String = "Male"
    @Published var targetYear: Int = 2024
    @Published var targetMonth: Int = 11
    @Published var targetDay: Int = 11
    @Published var activityLevel: String = "sedentary"
    public var food_cat: [String] = ["< 15 Mins", "< 30 Mins", "< 4 Hours", "< 60 Mins", "African", "Apple", "Apple Pie", "Artichoke", "Asian", "Australian", "Austrian", "Avocado", "Baking", "Bar Cookie", "Bass", "Bath/Beauty", "Bean Soup", "Beans", "Bear", "Beef Liver", "Beef Organ Meats", "Beginner Cook", "Belgian", "Berries", "Beverages", "Birthday", "Black Bean Soup", "Black Beans", "Brazilian", "Bread Machine", "Bread Pudding", "Breads", "Breakfast", "Breakfast Casseroles", "Breakfast Eggs", "Broccoli Soup", "Broil/Grill", "Brown Rice", "Brunch", "Buttermilk Biscuits", "Cajun", "Cambodian", "Camping", "Canadian", "Candy", "Canning", "Cantonese", "Caribbean", "Catfish", "Cauliflower", "Chard", "Cheese", "Cheesecake", "Cherries", "Chicken", "Chicken Breast", "Chicken Crock Pot", "Chicken Livers", "Chicken Thigh & Leg", "Chilean", "Chinese", "Chocolate Chip Cookies", "Chowders", "Christmas", "Chutneys", "Citrus", "Clear Soup", "Coconut", "Coconut Cream Pie", "Collard Greens", "Colombian", "Corn", "Costa Rican", "Crab", "Crawfish", "Creole", "Cuban", "Curries", "Czech", "Dairy Free Foods", "Danish", "Deep Fried", "Deer", "Dehydrator", "Dessert", "Desserts Fruit", "Drop Cookies", "Duck", "Duck Breasts", "Dutch", "Easy", "Ecuadorean", "Egg Free", "Egyptian", "Elk", "Ethiopian", "European", "Filipino", "Finnish", "Fish Salmon", "Fish Tuna", "For Large Groups", "Free Of...", "Freezer", "From Scratch", "Frozen Desserts", "Fruit", "Gelatin", "German", "Gluten Free Appetizers", "Goose", "Grains", "Grapes", "Greek", "Greens", "Gumbo", "Halibut", "Halloween", "Ham", "Ham And Bean Soup", "Hanukkah", "Hawaiian", "Healthy", "High Fiber", "High In...", "High Protein", "Homeopathy/Remedies", "Honduran", "Household Cleaner", "Hunan", "Hungarian", "Ice Cream", "Icelandic", "Indian", "Indonesian", "Inexpensive", "Iraqi", "Japanese", "Jellies", "Kid Friendly", "Kiwifruit", "Korean", "Kosher", "Labor Day", "Lactose Free", "Lamb/Sheep", "Lebanese", "Lemon", "Lemon Cake", "Lentil", "Lime", "Lobster", "Long Grain Rice", "Low Cholesterol", "Low Protein", "Lunch/Snacks", "Macaroni And Cheese", "Mahi Mahi", "Main Dish Casseroles", "Malaysian", "Mango", "Manicotti", "Margarita", "Mashed Potatoes", "Meat", "Meatballs", "Meatloaf", "Medium Grain Rice", "Melons", "Memorial Day", "Mexican", "Microwave", "Mixer", "Mongolian", "Moose", "Moroccan", "Mushroom Soup", "Mussels", "Native American", "Nepalese", "New Zealand", "Nigerian", "No Cook", "No Shell Fish", "Norwegian", "Nuts", "Oatmeal", "Octopus", "One Dish Meal", "Onions", "Orange Roughy", "Oranges", "Oven", "Oysters", "Pakistani", "Palestinian", "Papaya", "Pasta Shells", "Peanut Butter", "Peanut Butter Pie", "Pears", "Penne", "Pennsylvania Dutch", "Peppers", "Perch", "Peruvian", "Pheasant", "Pie", "Pineapple", "Plums", "Polish", "Polynesian", "Pork", "Portuguese", "Pot Pie", "Pot Roast", "Potato", "Potato Soup", "Potluck", "Poultry", "Pressure Cooker", "Puerto Rican", "Pumpkin", "Punch Beverage", "Quail", "Quick Breads", "Rabbit", "Raspberries", "Refrigerator", "Rice", "Roast", "Roast Beef", "Roast Beef Crock Pot", "Russian", "Salad Dressings", "Sauces", "Savory", "Savory Pies", "Scandinavian", "Scones", "Scottish", "Shakes", "Short Grain Rice", "Small Appliance", "Smoothies", "Snacks Sweet", "Somalian", "Soups Crock Pot", "Sourdough Breads", "South African", "South American", "Southwest Asia (middle East)", "Southwestern U.S.", "Soy/Tofu", "Spaghetti", "Spaghetti Sauce", "Spanish", "Spicy", "Spinach", "Spreads", "Spring", "Squid", "Steak", "Steam", "Stew", "Stir Fry", "Stocks", "Stove Top", "Strawberry", "Sudanese", "Summer", "Summer Dip", "Swedish", "Sweet", "Swiss", "Szechuan", "Tarts", "Tempeh", "Tex Mex", "Thai", "Thanksgiving", "Tilapia", "Toddler Friendly", "Tropical Fruits", "Trout", "Tuna", "Turkey Breasts", "Turkey Gravy", "Turkish", "Veal", "Vegan", "Vegetable", "Venezuelan", "Very Low Carbs", "Vietnamese", "Weeknight", "Welsh", "Wheat Bread", "White Rice", "Whitefish", "Whole Chicken", "Whole Duck", "Whole Turkey", "Wild Game", "Winter", "Yam/Sweet Potato", "Yeast Breads", "fl_progressive"]
    
    private var docID: String = ""
    
    func addAllergy(_ allergy: String) {
        DispatchQueue.main.async {
            self.foodAllergies.append(allergy)
        }
    }
    
    func removeAllergy(at offsets: IndexSet) {
        DispatchQueue.main.async {
            self.foodAllergies.remove(atOffsets: offsets)
        }
    }
    
    func addCat(_ cat: String) {
        DispatchQueue.main.async {
            self.foodCategories.append(cat)
        }
    }
    
    func removeCat(at offsets: IndexSet) {
        DispatchQueue.main.async {
            self.foodCategories.remove(atOffsets: offsets)
        }
    }
    
    func updateUserData() {
        let documentRef = db.collection("users").document(docID)
        let data = [
            "age": age,
            "weight": weight,
            "targetWeight": targetWeight,
            "height": height,
            "allergies": foodAllergies,
            "foodCategories": foodCategories,
            "sex": sex,
            "activityLevel": activityLevel,
            "target Date": [targetYear, targetMonth, targetDay]
        ] as [String : Any]
        
        documentRef.setData(data, merge: true) { error in
            if let error = error {
                print("Error updating document: \(error.localizedDescription)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    //
    func getUserData(email: String) async {
        do {
            let querySnapshot = try await db.collection("users").whereField("email", isEqualTo: email).getDocuments()
            
            guard let user = querySnapshot.documents.first else {
                print("No matching documents found for email: \(email)")
                return
            }
            
            let userData = user.data()
            
            DispatchQueue.main.async {
                self.docID = user.documentID
                
                self.age = userData["age"] as? Int ?? 0
                self.weight = userData["weight"] as? Int ?? 0
                self.targetWeight = userData["targetWeight"] as? Int ?? 0
                self.height = userData["height"] as? Int ?? 0
                self.foodAllergies = userData["allergies"] as? [String] ?? []
                self.foodCategories = userData["foodCategories"] as? [String] ?? []
                self.sex = userData["sex"] as? String ?? "Unknown"
                self.activityLevel = userData["activityLevel"] as? String ?? "Unknown"
                
                if let date = userData["target Date"] as? [Int], date.count == 3 {
                    self.targetYear = date[0]
                    self.targetMonth = date[1]
                    self.targetDay = date[2]
                } else {
                    print("Date is missing or not in the expected format.")
                }
            }
        } catch {
            print("Error getting documents: \(error)")
        }
    }
}
