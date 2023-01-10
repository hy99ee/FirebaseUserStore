import SwiftUI

struct SearchBar: View {
    @Binding var searchQuery: String

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color(.quaternaryLabel))
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search...", text: $searchQuery)
                    .foregroundColor(.secondary)
                
                if !searchQuery.isEmpty {
                    Button {
                        searchQuery = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 5)
                }
            }
            .foregroundColor(.gray)
            .padding(.leading, 13)
        }
        .frame(height: 40)
        .cornerRadius(13)
        .padding()
    }
}

struct SearchBar_Preview: PreviewProvider {
    @State static var testSearchQuery = "Hellow"
    static var previews: some View {
        SearchBar(searchQuery: $testSearchQuery)
    }
}

