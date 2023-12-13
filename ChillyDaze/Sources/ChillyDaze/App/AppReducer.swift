import AuthClient
import AuthenticationServices
import ComposableArchitecture
import FirebaseAuth
import LocationManager
import SignIn

@Reducer
public struct AppReducer {
    // MARK: - State
    public enum State: Equatable {
        case launch
        case signIn(SignInReducer.State)
        case main(MainReducer.State)

        public init() {
            self = .launch
        }
    }

    // MARK: - Action
    public enum Action {
        case onAppear
        case getCurrentUserResult(Result<User, Error>)
        case signIn(SignInReducer.Action)
        case main(MainReducer.Action)
    }

    // MARK: - Dependencies
    @Dependency(\.authClient)
    private var authClient
    @Dependency(\.locationManager)
    private var locationManager

    public init() {}

    // MARK: - Reducer
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    await send(.getCurrentUserResult(Result {
                        try await self.authClient.getCurrentUser()
                    }))
                }

            case .getCurrentUserResult(.success(_)):
                state = .main(.init())
                return .none

            case .getCurrentUserResult(.failure(_)):
                state = .signIn(.init())
                return .none

            case .signIn(.registerUserResult(.success(_))):
                state = .main(.init())
                return .none

            case .main(.achievement(.settings(.presented(.onSignOutButtonTapped)))):
                state = .signIn(.init())
                return .none

            case .signIn:
                return .none

            case .main:
                return .none
            }
        }
        .ifCaseLet(/State.signIn, action: /Action.signIn) {
            SignInReducer()
        }
        .ifCaseLet(/State.main, action: /Action.main) {
            MainReducer()
        }
    }
}
