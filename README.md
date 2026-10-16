# Care247 Customer Search (Flutter)

A small Flutter app to search customers, see the matching results and open
the full details of a customer. Data comes from the supplied `db.json`
served by JSON Server.

## Versions

- Flutter 3.41.0 (stable)
- Dart 3.11.0

## Dependencies

Only two packages are added on top of the Flutter SDK:

| Package | Why |
| --- | --- |
| `http` | REST calls to JSON Server. It also ships `MockClient`, which the tests use, so no mocking library is needed. |
| `flutter_bloc` | Cubit for state management and `BlocProvider` / `BlocBuilder` to connect it to the UI. |

`flutter_lints` is the default dev dependency for lint rules.

## Setup and run

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Start JSON Server

Put the supplied `db.json` in the project root (or anywhere, just point to it).

```bash
npm install -g json-server
json-server --watch db.json --port 3001
```

`npx json-server db.json --port 3001` also works without a global install.
JSON Server 1.x watches the file by default and prints a note that `--watch`
is not needed, that is fine.

Check it works: open http://localhost:3001/customers

### 3. Run the app

```bash
flutter run
```

### API base URL per environment

The base URL is kept in one place: `lib/config/api_config.dart`.

| Where the app runs | Base URL used |
| --- | --- |
| Android Emulator | `http://10.0.2.2:3001` (picked automatically on Android) |
| iOS Simulator | `http://localhost:3001` (default) |
| Physical device | pass your computer's local IP, see below |

To override it (physical device, other port, etc.):

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3001
```

The phone and the computer must be on the same Wi-Fi network.

Note: on a physical **Android** device the automatic `10.0.2.2` default does
not work, so always pass `API_BASE_URL` there.

### Other setup already done in the project

- Android: `INTERNET` permission and `usesCleartextTraffic="true"` in
  `android/app/src/main/AndroidManifest.xml`, because JSON Server is plain HTTP.
- iOS: `NSAllowsLocalNetworking` in `ios/Runner/Info.plist` so local HTTP is
  allowed by App Transport Security.

These are development settings for a mock API. A real backend should use HTTPS
and these settings should be removed.

## Project structure

```
lib/
  config/
    api_config.dart          base URL, path, timeout
    field_config.dart        FieldType enum, FieldConfig model, sort helper
    search_config.dart       the list of search fields
  models/
    customer.dart, address.dart, phone.dart, email.dart
    json_helpers.dart        safe readers used by fromJson
  data/
    api_exception.dart       error with a user friendly message
    customer_api.dart        HTTP call + JSON parsing
    customer_repository.dart caching, de-duplication and filtering
  state/
    customer_search_state.dart  sealed state classes
    customer_search_cubit.dart  search / refresh / retry / clear
  screens/
    customer_search_screen.dart
    customer_results_screen.dart
    customer_detail_screen.dart
  widgets/
    dynamic_search_form.dart  builds the form from config
    dynamic_field.dart        renders one field by its FieldType
    customer_list_item.dart   one result row
    detail_section.dart       section card, label/value row, primary badge
    message_view.dart         empty / error message with optional retry
  utils/
    date_utils.dart           yyyy-MM-dd and "15 Mar 1985" formatting
  main.dart
test/
  models/  config/  data/  state/  widgets/  app_flow_test.dart
```

## Architecture

There are three layers and each one only talks to the one below it:

1. **Presentation** (`screens/`, `widgets/`) builds the UI and forwards user
   actions to the cubit. No HTTP or filtering code lives here.
2. **State** (`state/`) is `CustomerSearchCubit`. It owns the current
   search criteria and turns repository results into UI states.
3. **Data** (`data/`) has `CustomerApi`, which only does the HTTP request and
   parsing, and `CustomerRepository`, which caches the data and filters it.

Widgets get typed `Customer` objects, never raw JSON maps.

### State management: Cubit (flutter_bloc)

I picked Cubit because this app has one main flow (search, results, details)
with a few clear states. Cubit gives a clean separation between UI and logic
without the extra boilerplate of full Bloc events. It is also easy to test
because it is a plain Dart class.

States are a Dart 3 `sealed` class, so the results screen uses an exhaustive
`switch`:

| State | Meaning |
| --- | --- |
| `SearchInitial` | nothing searched yet, or after Clear |
| `SearchLoading` | request in progress |
| `SearchSuccess(customers)` | at least one match |
| `SearchEmpty` | request worked but nothing matched |
| `SearchError(message)` | something failed, message is user friendly |

The cubit is provided once above `MaterialApp`, so both the search and the
results screens use the same instance. `BlocProvider` closes it when the app
goes away.

### Navigation

Plain `Navigator.push` with `MaterialPageRoute`, which gives the platform's
normal page transitions and back button / swipe back. With only three screens
a routing package would be overkill. The selected `Customer` object is passed
to the detail screen through its constructor.

Flow: the search screen waits for the search to finish. On success or empty
it opens the results screen. On error it stays on the search screen and shows
an error card with Retry above the form, so the user can fix the problem
without going back.

## Configuration-driven search form

Flow: `searchConfig` -> `DynamicSearchForm` -> `DynamicField` -> values
`Map<String, String>` -> cubit -> repository filter -> results.

- `searchConfig` (`lib/config/search_config.dart`) is a list of `FieldConfig`
  (key, type, label, placeholder, renderOrder).
- `DynamicSearchForm` sorts the list by `renderOrder` (once, in `initState`,
  not in `build`). It creates one `TextEditingController` and one `FocusNode`
  per field key, and renders a `DynamicField` for each.
- `DynamicField` only switches on `FieldType` (`text` -> text field,
  `date` -> read-only field that opens `showDatePicker`). It never checks
  for a specific field like "firstName".
- On Search the form collects the non-empty values into a map keyed by the
  field key, e.g. `{'firstName': 'John', 'dateOfBirth': '1985-03-15'}`.
- The repository filter is generic too: the key is matched against the
  property with the same name in the customer JSON (`customer.toJson()`).

### Adding a new field (example: Marital Status)

Add one entry to `searchConfig`:

```dart
FieldConfig(
  key: 'maritalStatus',
  type: FieldType.text,
  label: 'Marital Status',
  placeholder: 'Enter marital status',
  renderOrder: 4,
),
```

That's all. The field is rendered in the right place, its value is collected
and the search filters on it.

| Needs to change | Does not need to change |
| --- | --- |
| `search_config.dart` (the new entry) | `DynamicSearchForm`, `DynamicField` |
| | Search screen, cubit, repository, API |

You only need to change code in two cases: when the field uses a new input
type (e.g. a dropdown), add a `FieldType` value and one `case` in
`DynamicField`. When the key is not a property of `Customer`, add it to the
model first.

There is a widget test that adds Marital Status to the config and checks it is
rendered and submitted (`test/widgets/dynamic_search_form_test.dart`).

## Flutter decisions

### Async handling

- The API uses `async`/`await` with a 10 second timeout, so the UI is never
  blocked. While loading, a spinner with "Loading..." is shown above the form
  and the Search / Clear buttons are disabled.
- Retry keeps the spinner on screen for at least 300 ms, so the user can see
  that something happened even when the local server answers instantly.
- `CustomerApi` turns every failure (no connection, timeout, non-200 status,
  invalid JSON, JSON that is not a list) into an `ApiException` with a plain
  English message. The cubit also catches any other error, so a failed
  request never crashes the app.
- Single broken records in the response are skipped. Missing or wrong-typed
  fields fall back to empty values (see `json_helpers.dart`).

### Avoiding duplicate requests

- JSON Server data is fetched once and kept in memory. New searches filter
  that list, so typing a new search does not hit the network again.
- Pull-to-refresh and Retry pass `forceRefresh: true` to get fresh data.
- If two calls happen at the same time, the repository reuses the request
  that is already running.
- The cubit ignores `search` / `retry` / `refresh` while a request is loading.

### Lifecycle safety

- The cubit checks `isClosed` before every `emit` after an `await`.
- Each request gets an id. If Clear (or a newer request) happened while it
  was running, the old result is dropped instead of overwriting the screen.
- The search screen checks `mounted` after awaiting the search, before
  navigating.
- `DynamicSearchForm` owns its controllers and focus nodes and disposes them
  in `dispose()`. They are rebuilt in `didUpdateWidget` if the field list
  changes.

### Rebuilds and performance

- The form sits inside a `BlocSelector` that only rebuilds when "is loading"
  changes, not on every state change. The loading spinner and the error card
  have their own small `BlocBuilder` above the form.
- The app bar on the results screen is outside the `BlocBuilder`.
- Results use `ListView.builder`, so only visible rows are built. Rows have a
  `ValueKey(customer.id)`.
- Sorting the config happens in `initState`, not in `build`. The detail
  screen data is passed in, so it makes no API call.
- `const` constructors are used wherever possible.

### Keyboard and mobile UX

- Text fields use `TextInputAction.next` to move to the next field. The last
  field uses `search`, which submits the form.
- Tapping outside a field, dragging the list, pressing Search or Clear all
  hide the keyboard.
- The form is in a scrollable `ListView`, so the focused field is not hidden
  behind the keyboard on small phones.
- Date of Birth uses the Material date picker (no typing). Future dates can't
  be picked.
- Buttons are at least 48dp high. Content is limited to 600dp wide so it
  doesn't stretch on large screens.
- The result rows have semantic labels like "Primary phone: +1-415-...".
  Section titles are marked as headers.
- Pull-to-refresh works on the list and also on the empty / error views.

## Search behaviour and assumptions

- Text fields: case-insensitive, partial match ("jo" finds "John").
- Date of Birth: the picker gives a full `yyyy-MM-dd` date, so it matches
  only that exact day.
- All filled fields must match (AND).
- Searching with every field empty returns all customers. I think that is
  more useful than showing a validation error for a 15-record dataset.
- The primary phone / email in the list is the one with `isPrimary: true`.
  If none is marked, the first one is shown.

## Trade-offs and simplifications

- **Client-side filtering instead of JSON Server query params.** JSON
  Server 0.x and 1.x have different filter syntax (`firstName_like` was
  removed in 1.x). Exact-match params like `?firstName=John` would not allow
  partial or case-insensitive search. With 15 customers, fetching the list
  once and filtering locally is simple and fast. For a real backend with many
  records, the repository would send the criteria as query params instead,
  and nothing above the repository would change.
- **The cache lives in memory** for the app session only, and refreshes on
  pull-to-refresh or retry. The assignment did not ask for a saved file.
- The date is shown as `yyyy-MM-dd` inside the search field (same as the
  API), and as "15 Mar 1985" in results and details. The `intl` package was
  not added just for this.
- Only `text` and `date` field types exist because that is what the
  assignment needs. Marital Status works as a text field without new code.
- Cleartext HTTP is enabled for the mock server only (see setup).
- `db.json` is not changed. It is used only as the server data.

## Tests

Run all tests:

```bash
flutter test
```

Tests run offline. HTTP is faked with `MockClient` from the `http`
package, so no JSON Server is needed.

The assignment asks for meaningful tests, not full coverage, so there are two
small tests for each important part:

| File | What it covers |
| --- | --- |
| `test/models/customer_test.dart` | Customer JSON parsing: a full record, and missing / wrong-typed fields |
| `test/config/search_config_test.dart` | Search config: field render order, date of birth uses the date type |
| `test/data/customer_repository_test.dart` | Filter: partial case-insensitive match, all criteria must match |
| `test/state/customer_search_cubit_test.dart` | State: loading -> success, error -> retry -> success |
| `test/widgets/dynamic_search_form_test.dart` | Reusable widget: collects only filled values, a new config field (Marital Status) works without code changes |

Static analysis:

```bash
flutter analyze
```