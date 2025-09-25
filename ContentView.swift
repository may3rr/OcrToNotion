import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.viewfinder")
                .font(.largeTitle)
                .foregroundColor(.blue)
            
            Text("OCR to Notion")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("在快捷指令中使用此应用来自动识别截图中的待办事项并同步到 Notion")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("使用步骤:")
                    .font(.headline)
                
                Text("1. 在快捷指令 app 中搜索 'OCR 截图并同步到 Notion'")
                Text("2. 添加到您的快捷指令流程中")
                Text("3. 提供截图文件和当前日期参数")
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            
            Text("注意：需要先在钥匙串中配置 GPT 和 Notion API 凭据")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}