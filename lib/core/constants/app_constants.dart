// Base URL for the AgriGov Django backend
// Change this to your local network IP when testing on a physical device
// e.g. 'http://192.168.1.100:8000'
const String kBaseUrl = 'http://192.168.1.17:8000'; // Physical device on LAN
// const String kBaseUrl = 'http://192.168.X.X:8000'; // Physical device on LAN

const String kApiUrl = '$kBaseUrl/api';
const String kTokenUrl = '$kApiUrl/token/';
const String kTokenRefreshUrl = '$kApiUrl/token/refresh/';
const String kUsersUrl = '$kApiUrl/users';
const String kMarketUrl = '$kApiUrl/market';

// Endpoints
const String kLoginEndpoint = '/token/';
const String kRefreshEndpoint = '/token/refresh/';
const String kCurrentUserEndpoint = '/users/me/';
const String kDeliveriesEndpoint = '/market/deliveries/';
const String kAvailableOrdersEndpoint = '/market/deliveries/available_orders/';
const String kOrdersEndpoint = '/market/orders/';
const String kNotificationsEndpoint = '/market/notifications/';
const String kRoutingEndpoint = '/routing/calculate/';

// Storage Keys
const String kTokenKey = 'auth_token';
const String kRefreshTokenKey = 'refresh_token';
const String kUserDataKey = 'user_data';

// App Constants
const String kAppName = 'AgriGov Transporter';
const int kPollingIntervalSeconds = 30;
