//
//  CustomMKAnnotationView.swift
//  GeoBus
//
//  Created by João on 18/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI
import MapKit

struct VehicleAnnotationView: View {
  
  let title: String
  
  var body: some View {
    Text(title.prefix(3))
      .font(.footnote)
      .fontWeight(.heavy)
      .foregroundColor(Color(.black))
      .padding(.horizontal, 7)
      .padding(.vertical, 2)
      .background( RoundedRectangle(cornerRadius: 10).foregroundColor(Color(.systemYellow)) )
      .padding(.trailing, 0)
  }
}






//struct CustomMKAnnotationView_Previews: PreviewProvider {
//  static var previews: some View {
//    CustomMKAnnotationView()
//  }
//}











// MARK: - Alternative Style
//


// LARGE LAYOUT

//var body: some View {
//  VStack(alignment: .leading) {
//    HStack {
//      Text("758")
//        .font(.footnote)
//        .fontWeight(.heavy)
//        .padding(.horizontal, 7)
//        .padding(.vertical, 2)
//        .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.yellow))
//
//      Text("to")
//        .font(.caption)
//        .fontWeight(.medium)
//        .foregroundColor(.white)
//    }
//    Text("Escola Padre Cruz EB 23 - Lado esquerdo")
//      .font(.footnote)
//      .fontWeight(.bold)
//      .allowsTightening(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
//      .foregroundColor(.white)
//  }
//  .frame(maxWidth: 150, maxHeight: 50)
//  .padding(.horizontal, 5)
//  .padding(.vertical, 0)
//  .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.green))
//}






// MEDIUM LAYOUT

//var body: some View {
//  HStack {
//    Text(annotation.title!.prefix(3))
//      .font(.footnote)
//      .fontWeight(.heavy)
//      .padding(.horizontal, 7)
//      .padding(.vertical, 2)
//      .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.yellow))
//      .padding(.trailing, 0)
//
//    Text( (annotation.subtitle!.count > 20) ? annotation.subtitle!.prefix(17) + "..." : annotation.subtitle! )
//      .font(.footnote)
//      .fontWeight(.bold)
//      .multilineTextAlignment(.leading)
//      .allowsTightening(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
//      .foregroundColor(.white)
//      .padding(.leading, -5)
//  }
//  .padding(.leading, 0)
//  .padding(.trailing, 8)
//  .padding(.vertical, 0)
//  .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.green))
//}
