//
//  test.swift
//  elgranjero
//
//  Created by Abel Thomas on 9/28/24.
//

import SwiftUI

struct RecipeOfTheDayView: View {
    var recipe: String = "Tacos al Pastor"
    @State private var isImageExpanded = false

    var body: some View {
        ScrollView {
            VStack {
                Text("Recipe of the Day")
                    .font(.largeTitle)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .multilineTextAlignment(.center)

                // Add the image here
                Image("tacos_al_pastor")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding()
                    .onTapGesture {
                        isImageExpanded.toggle()
                    }
                    .sheet(isPresented: $isImageExpanded) {
                        VStack {
                            Spacer()
                            Image("tacos_al_pastor")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.black)
                                .onTapGesture {
                                    isImageExpanded.toggle()
                                }
                            Spacer()
                        }
                        .background(Color.black.edgesIgnoringSafeArea(.all))
                    }

                Text(recipe)
                    .font(.title)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .multilineTextAlignment(.center)

                VStack(alignment: .leading) {
                    Text("Ingredients:")
                        .font(.headline)
                        .padding(.top)
                    Text("Pork, Pineapple, Onions, Cilantro, Lime, Tortillas")
                        .padding(.bottom)
                        .cornerRadius(10)
                        .shadow(radius: 5)

                    Text("Instructions:")
                        .font(.headline)
                        .padding(.top)
                    Text("Marinate the pork, grill with pineapple, and serve on tortillas with onions, cilantro, and lime.")
                        .padding(.bottom)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding()
            }
            .padding()
        }
    }
}

struct RecipeOfTheDayView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeOfTheDayView()
    }
}
