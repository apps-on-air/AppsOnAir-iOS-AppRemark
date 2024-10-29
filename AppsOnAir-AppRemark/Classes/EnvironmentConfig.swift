
struct EnvironmentConfig{
    
// MARK: - Development Config:
    static let serverBaseURl = "https://server.feature.appsonair.com"
    
    
// MARK: - Production Config:
//    static let serverBaseURl = "https://server.appsonair.com/"
    
    
// MARK: - API URL:
    static let serverURL = serverBaseURl + "/feedback"
    static let getSignInURL = serverBaseURl + "/signed-url"
}
