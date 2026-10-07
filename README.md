# E-Commerce Mobile App (Flutter)

Laravel REST API (`https://job.sutainbuyant.com/api/v1`)-д суурилсан, Android болон iOS үйлдлийн системд зориулсан бүрэн ажиллагаатай, Production-ready цахим худалдааны мобайл аппликейшн.

---

## 📱 Онцлог боломжууд

1. **Splash & Хэрэглэгчийн баталгаажуулалт (Auth)**:
   - Апп нээгдэх үед `flutter_secure_storage`-д хадгалагдсан токеныг шалгаж (`GET /me`), нэвтэрсэн хэрэглэгчийг нүүр хуудас руу, нэвтрээгүй үед нэвтрэх дэлгэц рүү чиглүүлнэ.
   - Нэвтрэх (Login) болон Бүртгүүлэх (Register) дэлгэцүүд.
   - Зочноор үргэлжлүүлэн бүтээгдэхүүн үзэх боломжтой.

2. **Нүүр дэлгэц (Home)**:
   - Онцгой хямдрал, урамшууллын баннер.
   - Ангиллуудын хэвтээ гүйлгэх жагсаалт (зураг, гарчиг).
   - Шинэ бүтээгдэхүүнүүдийн grid жагсаалт.
   - Татаж шинэчлэх (Pull-to-refresh).

3. **Бүтээгдэхүүний жагсаалт (Products)**:
   - Түлхүүр үгээр хайлт хийх (500ms debounce саатуулагчтай).
   - Шүүлтүүр (Bottom sheet): Ангилал, таг, доод болон дээд үнийн хязгаараар шүүх.
   - Эрэмбэлэлт: Шинэ нь эхэндээ (`newest`), Үнэ өсөхөөр (`price_asc`), Үнэ буурахаар (`price_desc`), Нэрээр (`name`).
   - Хуудаслалт (Infinite scroll pagination): Доош гүйлгэхэд дараагийн хуудсыг автоматаар ачаална.

4. **Бүтээгдэхүүний дэлгэрэнгүй (Product Detail)**:
   - Зургийн carousel (`cached_network_image`, PageView indicator).
   - Үнэ, тайлбар, ангилал, тагууд.
   - Холбоотой бүтээгдэхүүнүүдийн жагсаалт.
   - Тоо ширхэг сонгож сагсанд нэмэх боломж.
   - Deep link дэмжилт: `/products/{id}` холбоосоор шууд нээгдэнэ.

5. **Сагс (Cart)**:
   - Тоо ширхэг нэмэх / хасах / устгах.
   - Нийт төлөх дүн болон барааны тоо.
   - **Offline persistence**: Апп бүрэн хаагдсан ч сагсан дахь бараанууд `Hive` өгөгдлийн санд хадгалагдан үлдэнэ.
   - Доод навигацийн цэс (Bottom navigation)-ийн сагс таб дээр барааны тоо badge-аар харагдана.

6. **Захиалга хийх (Checkout)**:
   - Хүлээн авагчийн нэр, утасны дугаар (8 орон), хаяг, нэмэлт тэмдэглэл оруулах форм.
   - Client-side validation болон серверийн 422 алдааг талбар тус бүрд нарийвчлан харуулах.
   - Захиалга амжилттай үүссэний дараа сагсыг автоматаар цэвэрлэж захиалгын дэлгэрэнгүй хуудас руу шилжинэ.

7. **Миний захиалгууд (Orders)**:
   - Захиалгуудын түүх, статус, огноо, нийт дүн.
   - Захиалгын дэлгэрэнгүй хуудас.
   - Хүлээгдэж буй (`pending`) захиалгыг цуцлах товч (Баталгаажуулах диалогтой).

8. **Профайл (Profile)**:
   - Хэрэглэгчийн мэдээлэл харах.
   - Мэдээлэл засах (`PUT /shop/profile` - нэр, и-мэйл).
   - Нууц үг солих (`PUT /shop/profile/password`).
   - Гэрэлтэй / Харанхуй горим (Light / Dark theme toggle).
   - Системээс гарах (Secure storage-оос токен бүрэн устгагдана).

9. **Алдаа болон Сүлжээний удирдлага**:
   - Сүлжээ тасарсан үед Offline төлөв болон «Дахин оролдох» (Retry) товч.
   - Loading, Empty, Error төлөв бүр дээр хэрэглэгчдэд ойлгомжтой UI төлөвүүд.

---

## 🛠 Технологийн стек

- **Framework**: Flutter 3.x (Dart 3.x, null-safety)
- **State Management**: [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) 3.x (Notifier / AsyncNotifier)
- **HTTP Client**: [dio](https://pub.dev/packages/dio) 5.x
  - `AuthInterceptor`: Bearer токен нэмэх, 401 алдаа гарахад автомат logout хийх, 422 алдааг бүтэцчлэн задлах.
- **Токен хадгалалт**: [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) (Keystore / Keychain ашиглан найдвартай шифрлэсэн)
- **Offline өгөгдлийн сан**: [hive_flutter](https://pub.dev/packages/hive_flutter)
- **Routing & Navigation**: [go_router](https://pub.dev/packages/go_router) (StatefulShellRoute бүхий bottom navigation, deep linking)
- **Image Caching**: [cached_network_image](https://pub.dev/packages/cached_network_image)
- **Огноо, валютын формат**: [intl](https://pub.dev/packages/intl)
- **Тест**: flutter_test, mocktail

---

## 🏛 Архитектур (Clean Architecture)

Төслийн код дараах 3 үндсэн давхаргад хуваагдсан:

```text
lib/
├── core/                           # Ерөнхий тохиргоо, туслах сангууд
│   ├── config/                     # AppConfig (Environment variables)
│   ├── constants/                  # Colors, Typography, Light/Dark Theme
│   ├── errors/                     # Exceptions & Domain Failures
│   ├── network/                    # ApiService (Dio) & AuthInterceptor
│   ├── storage/                    # SecureStorageService & CartStorageService (Hive)
│   ├── utils/                      # Debouncer, Formatters, Validator
│   └── widgets/                    # Loading, EmptyView, ErrorView, CustomButton, CustomTextField
├── data/                           # Өгөгдлийн давхарга
│   ├── models/                     # User, Category, Tag, Product, CartItem, Order, Pagination
│   └── repositories/               # AuthRepository, ProductRepository, CartRepository, OrderRepository
├── presentation/                   # UI болон Төлөв удирдлагын давхарга
│   ├── providers/                  # Riverpod Notifiers (Auth, Home, ProductList, Cart, Checkout, Orders)
│   ├── routing/                    # GoRouter тохиргоо болон MainLayout
│   └── screens/
│       ├── splash/                 # Splash дэлгэц
│       ├── auth/                   # Login & Register дэлгэцүүд
│       ├── home/                   # Нүүр дэлгэц
│       ├── products/               # Бүтээгдэхүүний жагсаалт, шүүлтүүр, дэлгэрэнгүй
│       ├── cart/                   # Сагсны дэлгэц
│       ├── checkout/               # Захиалга баталгаажуулах дэлгэц
│       ├── orders/                 # Захиалгын жагсаалт болон дэлгэрэнгүй
│       └── profile/                # Хэрэглэгчийн профайл, мэдээлэл засах, нууц үг солих
└── main.dart                       # Аппликейшны эхлэл цэг
```

---

## 🚀 Ажиллуулах заавар

### 1. Шаардлага
- Flutter SDK (≥ 3.13.0)
- Android SDK (Android 6.0 / API 23+)
- Xcode (iOS 12+)

### 2. Сангуудыг татах
```bash
flutter pub get
```

### 3. Статик шалгалт (Analyze) & Тест ажиллуулах
```bash
flutter analyze
flutter test
```

### 4. Аппликейшныг Debug горимд ажиллуулах
API URL-ийг `--dart-define`-ээр дамжуулна:
```bash
flutter run --dart-define=API_URL=https://job.sutainbuyant.com/api/v1
```

---

## 📦 Production Release APK үүсгэх

Release APK файлыг R8/Proguard оновчлолтойгоор дараах тушаалаар үүсгэнэ:

```bash
flutter build apk --release --dart-define=API_URL=https://job.sutainbuyant.com/api/v1
```

Үүссэн APK файл байрлах зам:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 🔗 Deep Link дэмжилт

Аппликейшн нь `/products/{id}` холбоосоор бүтээгдэхүүний дэлгэрэнгүй хуудсыг шууд нээх боломжтой:
- Custom scheme: `ecommerce://products/36`
- Web domain: `https://job.sutainbuyant.com/products/36`

---

## 🤖 CI / CD (GitHub Actions)

`.github/workflows/ci.yml` файлд дараах автоматжуулалтыг тохируулсан:
1. Кодын формат ба `flutter analyze`
2. Unit & Widget тестүүдийг ажиллуулах (`flutter test`)
3. Android Release APK бүтээх (`flutter build apk --release`)
4. Бүтээсэн APK файлыг GitHub Artifacts-д байршуулах

---

## 🔑 Аюулгүй байдал

- Хэрэглэгчийн Sanctum Bearer токен нь `SharedPreferences`-д хадгалагдахгүй бөгөөд зөвхөн Android KeyStore болон iOS Keychain ашиглан `flutter_secure_storage`-д хадгалагдана.
- Хэрэглэгч системээс гарах эсвэл 401 Unauthorized хариу ирэхэд токен автоматаар бүрэн цэвэрлэгдэнэ.
- Нууц үг, токен зэрэг эмзэг өгөгдлийг эх кодонд хатуу бичээгүй (hardcode хийгээгүй).
