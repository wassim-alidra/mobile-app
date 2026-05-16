// Base URL for the AgriGov Django backend
// Use '10.0.2.2' for Android Emulator to access host's localhost
// Use your local IP (e.g. 192.168.1.X) for physical devices
const String kBaseUrl = 'http://192.168.100.8:8000'; // For Physical Device
// const String kBaseUrl = 'http://10.0.2.2:8000'; // For Emulator

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

// Equipment Provider Endpoints
const String kEquipmentEndpoint = '/market/equipment/';
const String kEquipmentBookingsEndpoint = '/market/equipment-bookings/';
const String kMarkNotificationsReadEndpoint = '/market/notifications/mark_all_as_read/';

// Storage Keys
const String kTokenKey = 'auth_token';
const String kRefreshTokenKey = 'refresh_token';
const String kUserDataKey = 'user_data';

// Cloudinary (Photo Storage)
const String kCloudinaryCloudName = 'duoabslmx';
const String kCloudinaryApiKey = '793242198576965';
const String kCloudinaryApiSecret = 'W1seLruDxbbuMEGS-4eyZI9EJ4s';

// App Constants
const String kAppName = 'AgriGov Transporter';
const int kPollingIntervalSeconds = 30;
