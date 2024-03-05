//
//  DataCollectionViewModel.swift
//  CS125
//
//  Created by zhe yuan on 2/21/24.
//

import FirebaseCore
import FirebaseFirestore

class UserDataCollectionViewModel: ObservableObject {
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
    public var food_cat: [String] = ["< 15 Mins", "< 30 Mins", "< 4 Hours", "< 60 Mins", "African", "Apple", "Apple Pie", "Artichoke", "Asian", "Australian", "Austrian", "Avocado", "Baking", "Bar Cookie", "Bass", "Bath/Beauty", "Bean Soup", "Beans", "Bear", "Beef Liver", "Beef Organ Meats", "Beginner Cook", "Belgian", "Berries", "Beverages", "Birthday", "Black Bean Soup", "Black Beans", "Brazilian", "Bread Machine", "Bread Pudding", "Breads", "Breakfast", "Breakfast Casseroles", "Breakfast Eggs", "Broccoli Soup", "Broil/Grill", "Brown Rice", "Brunch", "Buttermilk Biscuits", "Cajun", "Cambodian", "Camping", "Canadian", "Candy", "Canning", "Cantonese", "Caribbean", "Catfish", "Cauliflower", "Chard", "Cheese", "Cheesecake", "Cherries", "Chicken", "Chicken Breast", "Chicken Crock Pot", "Chicken Livers", "Chicken Thigh & Leg", "Chilean", "Chinese", "Chocolate Chip Cookies", "Chowders", "Christmas", "Chutneys", "Citrus", "Clear Soup", "Coconut", "Coconut Cream Pie", "Collard Greens", "Colombian", "Corn", "Costa Rican", "Crab", "Crawfish", "Creole", "Cuban", "Curries", "Czech", "Dairy Free Foods", "Danish", "Deep Fried", "Deer", "Dehydrator", "Dessert", "Desserts Fruit", "Drop Cookies", "Duck", "Duck Breasts", "Dutch", "Easy", "Ecuadorean", "Egg Free", "Egyptian", "Elk", "Ethiopian", "European", "Filipino", "Finnish", "Fish Salmon", "Fish Tuna", "For Large Groups", "Free Of...", "Freezer", "From Scratch", "Frozen Desserts", "Fruit", "Gelatin", "German", "Gluten Free Appetizers", "Goose", "Grains", "Grapes", "Greek", "Greens", "Gumbo", "Halibut", "Halloween", "Ham", "Ham And Bean Soup", "Hanukkah", "Hawaiian", "Healthy", "High Fiber", "High In...", "High Protein", "Homeopathy/Remedies", "Honduran", "Household Cleaner", "Hunan", "Hungarian", "Ice Cream", "Icelandic", "Indian", "Indonesian", "Inexpensive", "Iraqi", "Japanese", "Jellies", "Kid Friendly", "Kiwifruit", "Korean", "Kosher", "Labor Day", "Lactose Free", "Lamb/Sheep", "Lebanese", "Lemon", "Lemon Cake", "Lentil", "Lime", "Lobster", "Long Grain Rice", "Low Cholesterol", "Low Protein", "Lunch/Snacks", "Macaroni And Cheese", "Mahi Mahi", "Main Dish Casseroles", "Malaysian", "Mango", "Manicotti", "Margarita", "Mashed Potatoes", "Meat", "Meatballs", "Meatloaf", "Medium Grain Rice", "Melons", "Memorial Day", "Mexican", "Microwave", "Mixer", "Mongolian", "Moose", "Moroccan", "Mushroom Soup", "Mussels", "Native American", "Nepalese", "New Zealand", "Nigerian", "No Cook", "No Shell Fish", "Norwegian", "Nuts", "Oatmeal", "Octopus", "One Dish Meal", "Onions", "Orange Roughy", "Oranges", "Oven", "Oysters", "Pakistani", "Palestinian", "Papaya", "Pasta Shells", "Peanut Butter", "Peanut Butter Pie", "Pears", "Penne", "Pennsylvania Dutch", "Peppers", "Perch", "Peruvian", "Pheasant", "Pie", "Pineapple", "Plums", "Polish", "Polynesian", "Pork", "Portuguese", "Pot Pie", "Pot Roast", "Potato", "Potato Soup", "Potluck", "Poultry", "Pressure Cooker", "Puerto Rican", "Pumpkin", "Punch Beverage", "Quail", "Quick Breads", "Rabbit", "Raspberries", "Refrigerator", "Rice", "Roast", "Roast Beef", "Roast Beef Crock Pot", "Russian", "Salad Dressings", "Sauces", "Savory", "Savory Pies", "Scandinavian", "Scones", "Scottish", "Shakes", "Short Grain Rice", "Small Appliance", "Smoothies", "Snacks Sweet", "Somalian", "Soups Crock Pot", "Sourdough Breads", "South African", "South American", "Southwest Asia (middle East)", "Southwestern U.S.", "Soy/Tofu", "Spaghetti", "Spaghetti Sauce", "Spanish", "Spicy", "Spinach", "Spreads", "Spring", "Squid", "Steak", "Steam", "Stew", "Stir Fry", "Stocks", "Stove Top", "Strawberry", "Sudanese", "Summer", "Summer Dip", "Swedish", "Sweet", "Swiss", "Szechuan", "Tarts", "Tempeh", "Tex Mex", "Thai", "Thanksgiving", "Tilapia", "Toddler Friendly", "Tropical Fruits", "Trout", "Tuna", "Turkey Breasts", "Turkey Gravy", "Turkish", "Veal", "Vegan", "Vegetable", "Venezuelan", "Very Low Carbs", "Vietnamese", "Weeknight", "Welsh", "Wheat Bread", "White Rice", "Whitefish", "Whole Chicken", "Whole Duck", "Whole Turkey", "Wild Game", "Winter", "Yam/Sweet Potato", "Yeast Breads", "fl_progressive"]
        
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
    
    func saveUserData(userName: String, email: String) async {
        do {
          let ref = try await db.collection("users").addDocument(data: [
            "name": userName,
            "age": age,
            "weight": weight,
            "targetWeight": targetWeight,
            "height": height,
            "allergies": foodAllergies,
            "foodCategories": foodCategories,
            "email": email,
            "sex": sex,
            "target Date": [targetYear, targetMonth, targetDay]
          ])
          print("Document added with ID: \(ref.documentID)")
        } catch {
          print("Error adding document: \(error)")
        }
    }
}
