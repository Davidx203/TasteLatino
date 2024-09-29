//
//  ProfileView.swift
//  Final 24
//
//  Created by David Perez on 9/29/24.
//
import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationView {
            
            
            VStack(spacing: 0.1) {
                Rectangle()
                    .fill(Color.white.opacity(0.95))
                    .frame(width: 350, height: 280)
                    .cornerRadius(10)
                    .padding()
                    .shadow(radius: 8)
                    .offset(y:55)
                
                Text("Account")
                    .fontWeight(.heavy)
                    .multilineTextAlignment(.center)
                    .font(.largeTitle)
                    .padding()
                    .offset(y: -240)
                
                Image(systemName: "person")
                    .resizable() // Make the image resizable
                    .scaledToFit() // Maintain aspect ratio
                    .frame(width: 100, height: 100) //
                    .foregroundColor(.black)
                    .font(.title)
                    .offset(x: -90 , y: -215)
                
                Text("Username")
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
                    .padding()
                    .offset(x:60, y: -340)
                
                Text("First Last Name")
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
                    .padding()
                    .offset(x:60, y: -340)
    
                
               
                
                NavigationLink(destination: FavoritesView()) {
                    Text("Favorites")
                        .font(.title)
                        .fontWeight(.semibold)
                        .padding()
                        .frame(width: 350 , height:100)
                        .background(Color.black.opacity(0.35)) // Background with opacity
                        .cornerRadius(10) // Rounded corners
                        .shadow(radius: 5) // Shadow effect
                        .multilineTextAlignment(.center) // Center alignment for multiline text
                        .tint(.black)
                }
                .offset(y: -150)
                
                Image(systemName: "heart")
                    .resizable() // Make the image resizable
                    .scaledToFit() // Maintain aspect ratio
                    .frame(width: 38, height: 50)
                    .foregroundColor(.red)
                    .font(.title)
                    .offset(x: -130 , y: -220)
                
                NavigationLink(destination:
                    HistoryView()) {
                    Text("Scan History")
                        .font(.title)
                        .fontWeight(.semibold)
                        .padding()
                        .frame(width: 350 , height:100)
                        .background(Color.black.opacity(0.35))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .multilineTextAlignment(.center)
                        .tint(.black)
                }
                    .offset(y: -150)
                
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundColor(.black)
                    .font(.title)
                    .offset(x: -130 , y: -212)
                
        
            }
        
        }
    }
                            

    }


struct FavoritesView: View {
    var body: some View {
        VStack {
            Text("Your Favorites")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            // Add more content here for the Favorites screen
            
            
        }
        .navigationTitle("Favorites")// Title for the Favorites view
        
    }
}

struct HistoryView: View {
    var body: some View {
        VStack {
            Text("Your History")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            // Add more content here for the Favorites screen
        }
        .navigationTitle("History") // Title for the Favorites view
    }
}

#Preview {
    ProfileView()
}


