//
//  ContentView.swift
//  elgranjero
//
//  Created by David Perez on 9/28/24.
//
import SwiftUI
// A SwiftUI wrapper for the UIVisualEffectView to apply a blur effect


// ContentView with a TabView and custom background
struct ContentView: View {
    init() {
        UITabBar.appearance().backgroundColor = UIColor.black
        UITabBar.appearance().barTintColor = UIColor.white
    }
    
    @State var capturedImage: UIImage? = nil
    @State private var takePhoto: Bool = false
    @State var selectedTab = TabItem.home
    @State var generatedRecipe: String = ""
    @State var isNewScreen = false
    @State var recognizedItem = ""
    
    var body: some View {
        TabView {
            RecipeOfTheDayView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(TabItem.home)
                .onAppear {
                    capturedImage = nil
                    generatedRecipe = ""
                    isNewScreen = false
                    recognizedItem = ""
                }
                
            CameraSearchView(capturedImage: $capturedImage, recognizedItem: $recognizedItem, generatedRecipe: $generatedRecipe, isNewScreen: $isNewScreen)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
             
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .onAppear {
                    capturedImage = nil
                    generatedRecipe = ""
                    isNewScreen = false
                    recognizedItem = ""
                }
        }

    }
}

enum TabItem: Equatable {
    case home
    case camera
}

#Preview {
    ContentView()
}
