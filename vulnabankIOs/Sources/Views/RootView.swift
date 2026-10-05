import SwiftUI

struct RootView: View {
    @State private var model: AppModel
    @Environment(\.scenePhase) private var scenePhase

    @MainActor
    init(model: AppModel = AppRepository.makeAppModel()) {
        _model = State(initialValue: model)
    }

    var body: some View {
        @Bindable var model = model

        NavigationStack {
            TransactionsView(model: model)
        }
        .task {
            model.start()
        }
        .onChange(of: scenePhase) { _, phase in
            model.handleScenePhase(phase)
        }
        .fullScreenCover(item: $model.authScreen) { screen in
            switch screen {
            case .login:
                LoginView(model: model)
            case .registration:
                RegistrationView(model: model)
            }
        }
        .alert(
            "Error",
            isPresented: Binding(
                get: { model.errorMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        model.clearError()
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                model.clearError()
            }
        } message: {
            Text(model.errorMessage ?? "")
        }
        .onOpenURL { url in
            Task {
                await model.handle(url: url)
            }
        }
    }
}
