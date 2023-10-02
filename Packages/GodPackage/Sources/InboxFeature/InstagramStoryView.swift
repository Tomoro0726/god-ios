import Colors
import SwiftUI
import God

struct InstagramStoryView: View {
  let question: String
  let color: Color
  let icon: ImageResource
  let gender: String
  let grade: String?

  var body: some View {
    let mockChoices = ["Nozomi Isshiki", "Anette Escobedo", "Satoya Hatanaka", "Ava Griego"]
    let mockSelectedUser = "Nozomi Isshiki"
    VStack(spacing: 12) {
      HStack(spacing: 8) {
        Image(icon)
          .resizable()
          .frame(width: 40, height: 40)

        Group {
          if let grade {
            Text("From \(gender)\nin \(grade)", bundle: .module)
          } else {
            Text("From a \(gender)", bundle: .module)
          }
        }
          .font(.callout)
          .bold()
          .lineLimit(2)
          .foregroundColor(.white)
          .frame(maxWidth: .infinity, alignment: .leading)

        Text(verbatim: "LBHS")
          .font(.body)
          .bold()
          .foregroundColor(.godWhite)
          .frame(height: 32)
          .padding(.horizontal, 8)
          .background(Color.godGray)
          .cornerRadius(20)
      }
      VStack(spacing: 8) {
        Text(question)
          .font(.callout)
          .bold()
          .foregroundColor(.godWhite)
          .lineLimit(2)
          .frame(height: 80, alignment: .center)

        LazyVGrid(
          columns: Array(repeating: GridItem(spacing: 16), count: 2),
          spacing: 16
        ) {
          ForEach(mockChoices, id: \.self) { choice in
            let isSelectedUser: Bool = choice == mockSelectedUser
            Text(verbatim: choice)
              .font(.callout)
              .bold()
              .lineLimit(2)
              .multilineTextAlignment(.leading)
              .padding(.horizontal, 16)
              .frame(height: 64)
              .frame(maxWidth: .infinity, alignment: .leading)
              .foregroundStyle(color)
              .background(
                Color.godWhite
              )
              .cornerRadius(8)
              .opacity(isSelectedUser ? 1 : 0.6)
              .overlay(alignment: .topTrailing) {
                if isSelectedUser {
                  Image(ImageResource.fingerIcon)
                    .resizable()
                    .frame(width: 48, height: 48)
                    .rotationEffect(.degrees(-30))
                    .shadow(color: color, radius: 8)
                    .offset(x: 20, y: -20)
                }
              }
          }
        }

        Image(ImageResource.godIconWhite)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(height: 24)
          .foregroundStyle(Color.godWhite)
          .padding(.top, 10)
          .padding(.bottom, 4)

        Text(verbatim: "godapp.jp")
          .font(.callout)
          .bold()
          .foregroundColor(.godWhite)
      }
      .padding(.horizontal, 16)
      .padding(.bottom, 16)
      .background(color)
      .cornerRadius(8)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding(.horizontal, 44)
    .background(Color.black)
  }
}

#Preview {
  InstagramStoryView(
    question: "Always doing the most and I like it",
    color: Color.godBlue,
    icon: ImageResource.boy,
    gender: "boy",
    grade: "11th"
  )
}
