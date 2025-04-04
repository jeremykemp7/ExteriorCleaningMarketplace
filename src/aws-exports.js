const awsmobile = {
    "aws_project_region": "us-east-1",
    "aws_cognito_region": "us-east-1",
    "aws_user_pools_id": "us-east-1_vXY5M1mBA",
    "aws_user_pools_web_client_id": "71ofcmje6dt6k96a1le0upsv4g",
    "oauth": {
        "domain": "your-domain.auth.us-east-1.amazoncognito.com",
        "scope": [
            "phone",
            "email",
            "openid",
            "profile",
            "aws.cognito.signin.user.admin"
        ],
        "redirectSignIn": "http://localhost:3000/",
        "redirectSignOut": "http://localhost:3000/",
        "responseType": "code"
    },
    "federationTarget": "COGNITO_USER_POOLS",
    "aws_appsync_graphqlEndpoint": "https://dbqslwqkdzahfodruoev634rki.appsync-api.us-east-1.amazonaws.com/graphql",
    "aws_appsync_region": "us-east-1",
    "aws_appsync_authenticationType": "AMAZON_COGNITO_USER_POOLS",
    "aws_appsync_apiKey": "da2-cfbv6tn3ezh67jicofcahj3jdq"
};

export default awsmobile; 