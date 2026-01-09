# 🔍 ANALISIS GAP BACKEND - Cangkang Sawit

## ✅ YANG SUDAH ADA DI BACKEND (Strong Foundation!)

### Authentication & User Management

- ✅ Register, Login, Logout
- ✅ Laravel Sanctum Token Authentication
- ✅ Role-based Access Control (admin, mitra, driver)
- ✅ User Model dengan relationships

### Products Management

- ✅ CRUD Products (Create, Read, Update, Delete)
- ✅ Image Upload dengan Storage
- ✅ Stock Management
- ✅ Category Support

### Orders Management

- ✅ Create Order dengan Multiple Items
- ✅ Order Status Flow (pending → confirmed → on_delivery → completed)
- ✅ Cancel Order
- ✅ Order Tracking
- ✅ Order Photos Upload

### Payment Integration

- ✅ Tripay Payment Gateway Integration
- ✅ Payment Callback Handler
- ✅ Multiple Payment Methods Support

### Delivery Management

- ✅ Delivery Orders Management
- ✅ Driver Assignment
- ✅ GPS Tracking (lat/lng recording)
- ✅ Delivery Status Updates
- ✅ Waybill Generation dengan PDF Export

### Admin Features

- ✅ Dashboard Summary dengan Statistics
- ✅ Order Approval
- ✅ Driver Assignment
- ✅ Waybill Management

### Maps & Distance

- ✅ Google Maps Distance API Integration
- ✅ Calculate Distance (Warehouse → Destination)
- ✅ Calculate Distance (Driver → Destination)

---

## ⚠️ YANG KURANG DI BACKEND (Perlu Ditambahkan)

### 🔴 CRITICAL (High Priority)

#### 1. **User Profile Management**

**Status**: ❌ Belum Ada

**Yang Dibutuhkan:**

```php
// routes/api.php
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/profile', [ProfileController::class, 'show']);
    Route::put('/profile', [ProfileController::class, 'update']);
    Route::put('/profile/password', [ProfileController::class, 'changePassword']);
    Route::post('/profile/photo', [ProfileController::class, 'uploadPhoto']);
});
```

**Fields yang bisa diupdate:**

- Name
- Email
- Phone
- Address
- Profile Photo
- Password

---

#### 2. **Pagination untuk Lists**

**Status**: ❌ Belum Ada

**Issue Saat Ini:**

```php
// ❌ Returns semua data tanpa pagination
public function index()
{
    $orders = Order::all(); // Bisa jadi ribuan records!
    return response()->json($orders);
}
```

**Solusi:**

```php
// ✅ Dengan pagination
public function index(Request $request)
{
    $perPage = $request->input('per_page', 15);
    $orders = Order::where('user_id', auth()->id())
        ->with(['orderItems.product', 'deliveryOrder', 'payment'])
        ->latest()
        ->paginate($perPage);

    return response()->json($orders);
}
```

**Endpoints yang perlu pagination:**

- `/api/products` - List semua products
- `/api/orders` - List orders user
- `/api/admin/orders` - List semua orders (admin)
- `/api/driver/orders` - List delivery orders driver

---

#### 3. **Search & Filter Functionality**

**Status**: ❌ Belum Ada

**Yang Dibutuhkan:**

**a) Search Products:**

```php
Route::get('/products/search', [ProductController::class, 'search']);

// Implementation
public function search(Request $request)
{
    $query = $request->input('q');
    $category = $request->input('category');

    $products = Product::query()
        ->when($query, function($q) use ($query) {
            $q->where('name', 'like', "%{$query}%")
              ->orWhere('description', 'like', "%{$query}%");
        })
        ->when($category, function($q) use ($category) {
            $q->where('category', $category);
        })
        ->paginate(15);

    return response()->json($products);
}
```

**b) Filter Orders:**

```php
Route::get('/orders', [OrderController::class, 'index']);

// Tambah filter: status, date_range
public function index(Request $request)
{
    $status = $request->input('status'); // pending, confirmed, etc
    $dateFrom = $request->input('date_from');
    $dateTo = $request->input('date_to');

    $orders = Order::where('user_id', auth()->id())
        ->when($status, fn($q) => $q->where('status', $status))
        ->when($dateFrom, fn($q) => $q->whereDate('created_at', '>=', $dateFrom))
        ->when($dateTo, fn($q) => $q->whereDate('created_at', '<=', $dateTo))
        ->with(['orderItems.product', 'deliveryOrder', 'payment'])
        ->latest()
        ->paginate(15);

    return response()->json($orders);
}
```

---

#### 4. **Push Notifications**

**Status**: ❌ Belum Ada

**Use Cases:**

- Mitra: Order approved, Driver assigned, Order delivered
- Driver: New delivery assigned, Order cancelled
- Admin: New order created, Payment received

**Implementation dengan Firebase Cloud Messaging (FCM):**

**Step 1: Install Package**

```bash
composer require kreait/firebase-php
```

**Step 2: Create Notification Service**

```php
// app/Services/NotificationService.php
class NotificationService
{
    public function sendToUser($userId, $title, $body, $data = [])
    {
        $user = User::find($userId);
        if (!$user || !$user->fcm_token) {
            return false;
        }

        // Send via FCM
        $messaging = app('firebase.messaging');
        $message = CloudMessage::withTarget('token', $user->fcm_token)
            ->withNotification(Notification::create($title, $body))
            ->withData($data);

        $messaging->send($message);
    }
}
```

**Step 3: Trigger Notifications**

```php
// Contoh: Ketika driver assigned
public function assignDriver(Order $order, Request $request)
{
    // ... assign driver logic

    // Send notification to mitra
    app(NotificationService::class)->sendToUser(
        $order->user_id,
        'Driver Ditugaskan',
        "Driver {$driver->name} telah ditugaskan untuk pesanan Anda",
        ['order_id' => $order->id, 'type' => 'driver_assigned']
    );

    // Send notification to driver
    app(NotificationService::class)->sendToUser(
        $driver->id,
        'Pengiriman Baru',
        "Anda mendapat tugas pengiriman pesanan {$order->order_code}",
        ['delivery_order_id' => $deliveryOrder->id, 'type' => 'new_delivery']
    );
}
```

**Step 4: Add FCM Token Endpoint**

```php
Route::post('/fcm-token', [UserController::class, 'updateFcmToken']);

public function updateFcmToken(Request $request)
{
    $request->validate(['fcm_token' => 'required|string']);

    auth()->user()->update(['fcm_token' => $request->fcm_token]);

    return response()->json(['message' => 'FCM token updated']);
}
```

**Migration:**

```php
Schema::table('users', function (Blueprint $table) {
    $table->string('fcm_token')->nullable()->after('password');
});
```

---

#### 5. **Driver Availability Status**

**Status**: ❌ Belum Ada

**Problem:** Admin tidak tahu driver mana yang available untuk assignment

**Solution:**

**Migration:**

```php
Schema::table('users', function (Blueprint $table) {
    $table->enum('availability_status', ['available', 'busy', 'offline'])
          ->default('offline')
          ->after('role');
});
```

**Endpoints:**

```php
// Driver update status
Route::post('/driver/availability', [DriverController::class, 'updateAvailability']);

public function updateAvailability(Request $request)
{
    $request->validate([
        'status' => 'required|in:available,busy,offline'
    ]);

    auth()->user()->update(['availability_status' => $request->status]);

    return response()->json(['message' => 'Status updated']);
}

// Admin get available drivers
Route::get('/admin/drivers/available', [AdminDriverController::class, 'available']);

public function available()
{
    $drivers = User::where('role', 'driver')
        ->where('availability_status', 'available')
        ->get();

    return response()->json($drivers);
}
```

---

#### 6. **Order Cancellation dengan Refund Logic**

**Status**: ⚠️ Parsial (Cancel ada, tapi refund logic belum)

**Yang Ada:**

```php
// Hanya update status
public function cancel(Order $order)
{
    $order->update(['status' => 'cancelled']);
    return response()->json(['message' => 'Order cancelled']);
}
```

**Yang Dibutuhkan:**

```php
public function cancel(Order $order)
{
    DB::transaction(function() use ($order) {
        // 1. Check if payment exists and paid
        $payment = $order->payment;

        if ($payment && $payment->status === 'paid') {
            // 2. Process refund via Tripay
            $refundResult = app(TripayService::class)->requestRefund($payment);

            if ($refundResult['success']) {
                $payment->update([
                    'status' => 'refunded',
                    'refunded_at' => now()
                ]);
            }
        }

        // 3. Return stock
        foreach ($order->orderItems as $item) {
            $product = $item->product;
            $product->increment('stock', $item->quantity);
        }

        // 4. Cancel delivery if exists
        if ($order->deliveryOrder) {
            $order->deliveryOrder->update(['status' => 'cancelled']);
        }

        // 5. Update order status
        $order->update(['status' => 'cancelled', 'cancelled_at' => now()]);
    });

    return response()->json(['message' => 'Order cancelled and refund processed']);
}
```

**Migration:**

```php
Schema::table('orders', function (Blueprint $table) {
    $table->timestamp('cancelled_at')->nullable();
});

Schema::table('payments', function (Blueprint $table) {
    $table->timestamp('refunded_at')->nullable();
});
```

---

### 🟡 IMPORTANT (Medium Priority)

#### 7. **Real-time Updates dengan Broadcasting**

**Status**: ❌ Belum Ada

**Use Case:** Driver location updates, Order status changes real-time

**Implementation dengan Laravel Broadcasting + Pusher:**

**Step 1: Install & Config**

```bash
composer require pusher/pusher-php-server
```

```env
BROADCAST_DRIVER=pusher
PUSHER_APP_ID=your_app_id
PUSHER_APP_KEY=your_key
PUSHER_APP_SECRET=your_secret
PUSHER_APP_CLUSTER=ap1
```

**Step 2: Create Events**

```php
// app/Events/DriverLocationUpdated.php
class DriverLocationUpdated implements ShouldBroadcast
{
    public $deliveryOrderId;
    public $latitude;
    public $longitude;

    public function broadcastOn()
    {
        return new PrivateChannel('order.' . $this->deliveryOrderId);
    }
}

// Trigger event
public function track(DeliveryOrder $deliveryOrder, Request $request)
{
    // ... save tracking

    broadcast(new DriverLocationUpdated(
        $deliveryOrder->id,
        $request->lat,
        $request->lng
    ));
}
```

**Frontend Flutter:**

```dart
// Use pusher_client package
final pusher = PusherClient(
  'your_key',
  PusherOptions(cluster: 'ap1'),
);

final channel = pusher.subscribe('order.${orderId}');
channel.bind('DriverLocationUpdated', (event) {
  // Update map marker
  updateDriverLocation(event.data);
});
```

---

#### 8. **API Rate Limiting**

**Status**: ❌ Belum Ada

**Problem:** API bisa di-abuse tanpa rate limiting

**Solution:**

```php
// app/Http/Kernel.php
protected $middlewareGroups = [
    'api' => [
        \Illuminate\Routing\Middleware\ThrottleRequests::class.':api',
        // ...
    ],
];

// config/app.php - Customize limits
'throttle' => [
    'api' => [
        'limit' => 60,
        'decay' => 1, // per minute
    ],
    'uploads' => [
        'limit' => 10,
        'decay' => 1, // 10 uploads per minute
    ],
];

// routes/api.php - Apply to specific routes
Route::middleware(['throttle:uploads'])->group(function () {
    Route::post('/products', [ProductController::class, 'store']);
    Route::post('/orders/{order}/upload-photo', [OrderController::class, 'uploadPhoto']);
});
```

---

#### 9. **Logging & Monitoring**

**Status**: ⚠️ Basic Laravel Log Only

**Yang Dibutuhkan:**

**a) Activity Logging:**

```php
// app/Models/ActivityLog.php
class ActivityLog extends Model
{
    protected $fillable = ['user_id', 'action', 'model', 'model_id', 'details'];
}

// Usage
ActivityLog::create([
    'user_id' => auth()->id(),
    'action' => 'order.created',
    'model' => 'Order',
    'model_id' => $order->id,
    'details' => json_encode(['order_code' => $order->order_code])
]);
```

**b) Error Tracking dengan Sentry:**

```bash
composer require sentry/sentry-laravel
```

**c) Performance Monitoring:**

```php
// Log slow queries
DB::listen(function ($query) {
    if ($query->time > 1000) { // More than 1 second
        Log::warning('Slow Query', [
            'sql' => $query->sql,
            'time' => $query->time
        ]);
    }
});
```

---

#### 10. **Image Optimization**

**Status**: ❌ Belum Ada

**Problem:** Product images di-upload full size, membebani storage & bandwidth

**Solution dengan Intervention Image:**

```bash
composer require intervention/image
```

```php
use Intervention\Image\Facades\Image;

public function store(Request $request)
{
    $request->validate([
        'image_file' => 'nullable|image|mimes:jpeg,png,jpg|max:5120', // Max 5MB
    ]);

    if ($request->hasFile('image_file')) {
        $image = $request->file('image_file');
        $filename = time() . '_' . $image->getClientOriginalName();

        // Resize to max width 800px, maintain aspect ratio
        $img = Image::make($image->getRealPath());
        $img->resize(800, null, function ($constraint) {
            $constraint->aspectRatio();
            $constraint->upsize();
        });

        // Compress to 75% quality
        $img->encode('jpg', 75);

        // Save
        $path = 'products/' . $filename;
        Storage::disk('public')->put($path, (string) $img);

        $data['images'] = $path;
    }

    // ... rest of code
}
```

---

#### 11. **Email Notifications**

**Status**: ❌ Belum Ada

**Use Cases:**

- Order confirmation email
- Payment receipt
- Delivery notification
- Password reset

**Implementation:**

```php
// app/Mail/OrderConfirmation.php
class OrderConfirmation extends Mailable
{
    public $order;

    public function build()
    {
        return $this->subject('Konfirmasi Pesanan ' . $this->order->order_code)
                    ->view('emails.order-confirmation');
    }
}

// Send email
Mail::to($order->user->email)->send(new OrderConfirmation($order));

// Queue for better performance
Mail::to($order->user->email)->queue(new OrderConfirmation($order));
```

**Setup Queue:**

```bash
php artisan queue:table
php artisan migrate

# .env
QUEUE_CONNECTION=database

# Run worker
php artisan queue:work
```

---

### 🟢 NICE TO HAVE (Low Priority)

#### 12. **API Documentation (Swagger/OpenAPI)**

**Status**: ❌ Belum Ada

**Solution:**

```bash
composer require darkaonline/l5-swagger
php artisan vendor:publish --provider="L5Swagger\L5SwaggerServiceProvider"
```

```php
/**
 * @OA\Post(
 *     path="/api/login",
 *     tags={"Authentication"},
 *     summary="User login",
 *     @OA\RequestBody(
 *         required=true,
 *         @OA\JsonContent(
 *             required={"email","password"},
 *             @OA\Property(property="email", type="string", format="email"),
 *             @OA\Property(property="password", type="string", format="password")
 *         )
 *     ),
 *     @OA\Response(response=200, description="Login successful")
 * )
 */
public function login(Request $request) { }
```

Generate docs: `php artisan l5-swagger:generate`
Access: `http://localhost:8000/api/documentation`

---

#### 13. **Automated Testing**

**Status**: ❌ Belum Ada

**Feature Tests:**

```php
// tests/Feature/OrderTest.php
class OrderTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_create_order()
    {
        $user = User::factory()->create(['role' => 'mitra']);
        $product = Product::factory()->create(['stock' => 100]);

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/orders', [
                'destination_address' => 'Test Address',
                'items' => [
                    ['product_id' => $product->id, 'quantity' => 10]
                ]
            ]);

        $response->assertStatus(201);
        $this->assertDatabaseHas('orders', [
            'user_id' => $user->id,
        ]);
    }
}
```

Run tests: `php artisan test`

---

#### 14. **Database Backup Automation**

**Status**: ❌ Belum Ada

**Solution:**

```bash
composer require spatie/laravel-backup
php artisan vendor:publish --provider="Spatie\Backup\BackupServiceProvider"
```

**Config:**

```php
// config/backup.php
'backup' => [
    'destination' => [
        'disks' => ['local', 's3'],
    ],
],

// Schedule
// app/Console/Kernel.php
protected function schedule(Schedule $schedule)
{
    $schedule->command('backup:clean')->daily()->at('01:00');
    $schedule->command('backup:run')->daily()->at('02:00');
}
```

---

#### 15. **Multi-language Support (i18n)**

**Status**: ❌ Belum Ada

**Implementation:**

```php
// resources/lang/id/messages.php
return [
    'order.created' => 'Pesanan berhasil dibuat',
    'payment.success' => 'Pembayaran berhasil',
];

// resources/lang/en/messages.php
return [
    'order.created' => 'Order created successfully',
    'payment.success' => 'Payment successful',
];

// Usage
return response()->json([
    'message' => __('messages.order.created')
]);

// Set locale from header
Route::middleware('auth:sanctum')->group(function () {
    app()->setLocale(request()->header('Accept-Language', 'id'));
});
```

---

#### 16. **Admin Analytics & Reports**

**Status**: ⚠️ Basic Dashboard Only

**Yang Bisa Ditambahkan:**

**a) Sales Report:**

```php
Route::get('/admin/reports/sales', [ReportController::class, 'sales']);

public function sales(Request $request)
{
    $startDate = $request->input('start_date', now()->startOfMonth());
    $endDate = $request->input('end_date', now());

    $report = Order::whereBetween('created_at', [$startDate, $endDate])
        ->where('status', 'completed')
        ->selectRaw('DATE(created_at) as date')
        ->selectRaw('COUNT(*) as total_orders')
        ->selectRaw('SUM(total_amount) as total_sales')
        ->groupBy('date')
        ->get();

    return response()->json($report);
}
```

**b) Driver Performance:**

```php
Route::get('/admin/reports/driver-performance', [ReportController::class, 'driverPerformance']);

public function driverPerformance()
{
    $drivers = User::where('role', 'driver')
        ->withCount([
            'deliveryOrders',
            'deliveryOrders as completed_deliveries' => function($q) {
                $q->where('status', 'completed');
            }
        ])
        ->get();

    return response()->json($drivers);
}
```

**c) Product Performance:**

```php
Route::get('/admin/reports/top-products', [ReportController::class, 'topProducts']);

public function topProducts(Request $request)
{
    $limit = $request->input('limit', 10);

    $products = Product::withSum('orderItems as total_sold', 'quantity')
        ->withSum('orderItems as total_revenue', DB::raw('quantity * price'))
        ->orderByDesc('total_sold')
        ->limit($limit)
        ->get();

    return response()->json($products);
}
```

---

#### 17. **Order Review & Rating System**

**Status**: ❌ Belum Ada

**Migration:**

```php
Schema::create('reviews', function (Blueprint $table) {
    $table->id();
    $table->foreignId('order_id')->constrained()->onDelete('cascade');
    $table->foreignId('user_id')->constrained()->onDelete('cascade');
    $table->integer('rating'); // 1-5
    $table->text('comment')->nullable();
    $table->timestamps();
});
```

**Endpoints:**

```php
Route::post('/orders/{order}/review', [ReviewController::class, 'store']);
Route::get('/products/{product}/reviews', [ReviewController::class, 'productReviews']);
```

---

## 📊 SUMMARY PRIORITAS

### 🔴 URGENT - Implement Segera (1-2 Minggu)

1. ✅ User Profile Management
2. ✅ Pagination untuk semua lists
3. ✅ Search & Filter functionality
4. ✅ Push Notifications (FCM)
5. ✅ Driver Availability Status
6. ✅ Order Cancellation dengan Refund

### 🟡 IMPORTANT - Implement Soon (2-4 Minggu)

7. ✅ Real-time Updates (Broadcasting)
8. ✅ API Rate Limiting
9. ✅ Logging & Monitoring (Sentry)
10. ✅ Image Optimization
11. ✅ Email Notifications

### 🟢 NICE TO HAVE - Implement Later (1-2 Bulan)

12. ⭕ API Documentation (Swagger)
13. ⭕ Automated Testing
14. ⭕ Database Backup Automation
15. ⭕ Multi-language Support
16. ⭕ Advanced Analytics & Reports
17. ⭕ Review & Rating System

---

## 🎯 REKOMENDASI IMPLEMENTASI

### Week 1-2: Core Improvements

- Profile management
- Pagination
- Search & filters
- Push notifications setup

### Week 3-4: Performance & Security

- Real-time updates
- Rate limiting
- Image optimization
- Logging setup

### Week 5-6: Advanced Features

- Email notifications
- Analytics
- Testing
- Documentation

---

## 📝 KESIMPULAN

**Backend Anda sudah SANGAT SOLID untuk MVP!** 💪

Yang benar-benar **CRITICAL** dan perlu segera:

1. **Pagination** - Agar tidak load semua data sekaligus
2. **Push Notifications** - Untuk real-time updates ke user
3. **Profile Management** - User perlu bisa update data mereka

Yang lainnya bisa ditambahkan bertahap sesuai kebutuhan.

**Estimasi Total:**

- Core Improvements: **2-3 minggu**
- Full Production Ready: **1-2 bulan**

Backend Anda sudah **70% production ready**! Tinggal tambah fitur-fitur enhancement di atas! 🚀
