# FAMA Mobile

Flutter app for the FAMA agricultural platform, consuming a token-based API
added to the existing `fama` Laravel/Livewire project (see
`../fama_api_additions/SETUP.md` for that half).

## Why this exists as two pieces

The website is Laravel + Livewire — Livewire renders and updates the page
server-side over its own protocol, which a mobile app can't speak. So there
are two deliverables:

1. **`fama_api_additions/`** — Sanctum token auth + REST endpoints added to
   your existing Laravel project, one per entity (products, outlets,
   services, service requests, worker profiles, tags, plans,
   subscriptions, ad requests, role upgrades).
2. **This Flutter project** — a real, separate app that talks to that API.

## Getting started

```bash
flutter pub get
cp .env.example .env   # then edit API_BASE_URL if needed
flutter run
```

By default `.env` points at `http://10.0.2.2:8000/api`, which is how the
Android emulator reaches your machine's `localhost:8000` where
`php artisan serve` runs. On a physical device, use your machine's LAN IP
instead (e.g. `http://192.168.1.20:8000/api`), and on iOS simulator you can
use `http://127.0.0.1:8000/api` directly.

Google Maps (`google_maps_flutter`, used in the Providers map view) needs an
API key added to `android/app/src/main/AndroidManifest.xml` and
`ios/Runner/AppDelegate.swift` — standard Flutter Google Maps setup, not
FAMA-specific.

### Location permissions (for distance-to-provider and map centering)

Android — add to `android/app/src/main/AndroidManifest.xml`, inside `<manifest>`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

iOS — add to `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>FAMA uses your location to show nearby providers and outlets.</string>
```

Without these, the Providers screen just skips showing distance — it
won't crash, but "X km away" won't appear.

### Google Sign-In setup

This is real, wired-up code — not a placeholder — but it needs credentials
only you can create:

1. In [Google Cloud Console](https://console.cloud.google.com), create an
   OAuth 2.0 **Web application** client ID (this is the one Flutter's
   `google_sign_in` calls `serverClientId` — it's the "audience" every
   platform's token gets issued against, regardless of whether sign-in
   happened on Android or iOS).
2. Also create an **Android** OAuth client ID, tied to your app's package
   name and its SHA-1 signing fingerprint (get it with
   `cd android && ./gradlew signingReport`).
3. Put the **Web** client ID in `fama_mobile/.env` as `GOOGLE_WEB_CLIENT_ID`.
4. Put the same Web client ID in your Laravel `.env` as `GOOGLE_CLIENT_ID`
   (see `fama_api_additions/SETUP.md` step 8).

Until you do this, tapping "Continue with Google" shows a clear error
telling you it isn't configured yet — it won't crash or silently fail.

## Design system

Marketplace, Services, and Providers screens now follow the Stitch
`fama_agricultural_design_system` export exactly (colors, type scale,
button/input shapes — see `lib/core/theme/fama_theme.dart`). A few
callouts on how real data maps onto those designs:

- **Marketplace** shows products only (never outlets or services mixed
  in), with category filter chips derived from whatever tags are actually
  attached to your real products — not a hardcoded Seeds/Tools/Fertilizer
  list, since your database's actual tags may differ.
- **Services** shows only `status: approved` services from real workers,
  rendered through Stitch's icon-row treatment (icon picked by keyword
  match against the service's name/tags, not a manual per-service lookup
  table).
- **Providers** distances are computed for real from device GPS + each
  provider's stored location — no fabricated ratings/reviews, since FAMA
  doesn't have a review system yet. If you add one later, the provider
  card is ready for a rating row.
- The promoted-ad banner (`featured_banner.dart`) is now a single
  Stitch-style banner shared by Marketplace and Services, instead of the
  earlier tall auto-scrolling carousel.

## Architecture

- **State management:** `provider` package. `AuthProvider` is the only
  app-wide provider; each feature screen manages its own local state via
  `FutureBuilder` + a plain service class (see `ProductListScreen` +
  `MarketplaceService` as the reference pair).
- **Networking:** one shared `Dio` instance (`ApiClient`) auto-attaches the
  Sanctum bearer token and clears it on 401.
- **Auth:** token stored in `flutter_secure_storage`, never in
  `SharedPreferences` — tokens are credentials, not preferences.

## Roadmap: Livewire component → API endpoint → Flutter screen

Everything below is scaffolded (routes + controllers exist); screens marked
✅ are fully wired end-to-end, screens marked 🔲 are stub screens with the
exact endpoint + pattern to copy noted in a code comment.

| Web (Livewire)                          | API endpoint(s)                                     | Flutter                                | Status |
|---|---|---|---|
| `Forms/LoginForm.php`                   | `POST /login`                                       | `login_screen.dart`                    | ✅ |
| *(registration, web has none explicit)* | `POST /register`                                    | `register_screen.dart`                 | ✅ |
| `Actions/Logout.php`                    | `POST /logout`                                      | `AuthProvider.logout()`                | ✅ |
| `ProductForm.php`                       | `GET/POST /products`, `PUT/DELETE /products/{id}`   | `product_list_screen.dart`             | ✅ (list) / 🔲 (create/edit form) |
| `OutletForm.php`                        | `GET/POST /outlets`, `PUT/DELETE /outlets/{id}`      | —                                       | 🔲 |
| `EcommerceCategoryToggle.php`           | `GET /tags?category=`                               | —                                       | 🔲 |
| `WorkerServiceForm.php`                 | `GET/POST /services`, `PUT/DELETE /services/{id}`   | `services_screen.dart`                 | 🔲 |
| `SearchProviders.php`                   | `GET /providers`                                    | `providers_screen.dart`                | 🔲 |
| `ProviderMapDiscovery.php`              | `GET /providers?lat=&lng=`                          | `providers_screen.dart`                | 🔲 |
| `LocationSelector.php`                  | *(client-side geolocation only, `geolocator` pkg)*  | `providers_screen.dart`                | 🔲 |
| `ServiceRequestForm.php`                | `POST /service-requests`                            | `service_requests_screen.dart`         | 🔲 |
| `MyServiceRequests.php`                 | `GET /service-requests/mine`                        | `service_requests_screen.dart` (tab 1) | 🔲 |
| `IncomingServiceRequests.php`           | `GET /service-requests/incoming`, `PATCH .../respond`| `service_requests_screen.dart` (tab 2) | 🔲 |
| `TagSelector.php`                       | `GET /tags`                                         | *(shared widget, not yet built)*       | 🔲 |
| `RoleUpgradeRequestForm.php` + Farmer/Dealer/WorkerUpgradeRequestForm.php | `POST /role-upgrade-requests`, `GET .../mine` | `role_upgrade_screen.dart` | 🔲 |
| Subscription/Plan checkout (no dedicated Livewire, part of payment flow) | `GET /plans`, `POST/GET /subscriptions` | `subscriptions_screen.dart`            | 🔲 |
| `AdCarousel.php` / `Carousel.php`       | `GET /ads`                                          | *(home screen carousel, not yet built)*| 🔲 |
| `AdRequestForm.php`                    | `POST /ads`                                         | *(not yet built)*                      | 🔲 |
| `StatCounter.php`                      | *(add a `/stats` endpoint if you want this on mobile)* | —                                    | 🔲 not started |
| `Admin/ExtensionServiceManager.php`, `Admin/SpecializationManager.php`, `AdminNotification.php` | — | — | **Intentionally skipped** — admin/back-office tools, kept web-only |

## Suggested build order

1. Get `fama_api_additions` merged and `POST /login` returning a token
   (test with curl first, before touching Flutter).
2. Confirm `flutter run` boots to the login screen and logs in
   successfully against your local Laravel server.
3. Then go endpoint-by-endpoint down the table above, same shape as
   `ProductListScreen` + `MarketplaceService` each time: model → service →
   screen → wire into `HomeShell` or push a new route.

Happy to build out any specific row next — just say which one.
