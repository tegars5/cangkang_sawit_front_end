# **🚀 CANGKANG SAWIT FRONTEND - MASTER PLAN LENGKAP**[1]

**Backend 100% ready → Frontend MVP dalam 3 hari!**

***

## **📂 STRUKTUR FOLDER FINAL (Production Ready)**

```
lib/
├── main.dart                          # Entry + routing
├── app.dart                           # App wrapper + theme
├── services/
│   └── api_client.dart                # ✅ EXISTING - tambah 5 method
├── models/
│   ├── product.dart                   # ✅ EXISTING
│   ├── order.dart
│   ├── user.dart
│   └── driver_order.dart
├── theme/
│   └── app_theme.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home/
│   │   └── home_screen.dart           # BottomNav wrapper
│   ├── products/
│   │   ├── product_list_screen.dart
│   │   └── product_detail_screen.dart
│   ├── orders/
│   │   ├── order_list_screen.dart
│   │   └── order_proof_screen.dart
│   ├── admin/
│   │   ├── admin_dashboard_screen.dart
│   │   └── admin_products_screen.dart
│   └── driver/
│       └── driver_orders_screen.dart
└── widgets/
    ├── product_card.dart
    ├── order_card.dart
    └── loading_overlay.dart
```

***

## **📋 IMPLEMENTATION ROADMAP (3 HARI)**

### **HARI 1: Foundation + Auth + Products (3 jam)**
```
1. [30m] ApiClient: tambah 5 method missing
2. [30m] theme/app_theme.dart (hijau sawit)
3. [45m] screens/auth/login_screen.dart
4. [30m] screens/home/home_screen.dart (BottomNav)
5. [45m] screens/products/product_list_screen.dart + widgets/product_card.dart
6. [30m] main.dart + routing dasar
```

### **HARI 2: Orders + Admin (4 jam)**
```
7. [45m] screens/orders/order_list_screen.dart
8. [45m] screens/orders/order_proof_screen.dart (foto upload)
9. [45m] screens/admin/admin_dashboard_screen.dart
10.[45m] screens/admin/admin_products_screen.dart
11.[30m] screens/products/product_detail_screen.dart
```

### **HARI 3: Driver + Polish + Test (3 jam)**
```
12.[45m] screens/driver/driver_orders_screen.dart
13.[30m] Navigation role-based final
14.[30m] Error handling + loading states
15.[30m] Testing + screenshots
16.[30m] README + demo video
```

***

## **🔧 PROMPT REFTRACTOR SEMUA CODE (Copy-paste ke Claude/GPT)**

```
**🔧 REFRACTOR CANGKANG SAWIT FRONTEND - PRODUCTION READY!**

📂 REPO: https://github.com/tegars5/cangkang_sawit_front_end
✅ Backend routes: 29 endpoints COMPLETE
✅ ApiClient: auth + uploadProduct ✅

**🎯 GOAL: Clean architecture + Material 3 + responsive**
```
1. Folder structure exactly seperti di atas
2. Theme hijau sawit (#4CAF50)
3. Role-based navigation (admin/driver/user)
4. Error handling + loading states everywhere
5. Cached images + pull-to-refresh
```

**📋 FILES YANG UDAH ADA (PRESERVE & ENHANCE):**
```
lib/services/api_client.dart → tambah 5 method:
- login(email, password)
- getMyOrders()
- getDriverOrders()
- trackDriverDelivery(id, lat, lng) 
- getProductDetail(id)

lib/models/product.dart → keep as-is
```

**📁 GENERATE IN ORDER (Prioritas tinggi → rendah):**

```
PHASE 1 - FOUNDATION (Hari 1)
1. theme/app_theme.dart
2. services/api_client.dart (tambah 5 methods)
3. screens/auth/login_screen.dart
4. screens/home/home_screen.dart (BottomNav)
5. main.dart (complete routing)

PHASE 2 - USER FLOW (Hari 2)
6. widgets/product_card.dart
7. screens/products/product_list_screen.dart
8. screens/products/product_detail_screen.dart
9. screens/orders/order_list_screen.dart
10. screens/orders/order_proof_screen.dart

PHASE 3 - ADMIN/DRIVER (Hari 3)
11. screens/admin/admin_dashboard_screen.dart
12. screens/admin/admin_products_screen.dart
13. screens/driver/driver_orders_screen.dart
```

**⚙️ TECHNICAL REQUIREMENTS:**
```
✅ ApiClient integration (semua method dipakai)
✅ Material 3 + responsive GridView (2col mobile)
✅ CachedNetworkImage(product.primaryImage)
✅ ImagePicker + upload foto (progress indicator)
✅ Role check: ApiClient.getRole()
✅ BottomNav: 4 tabs role-based
✅ Pull-to-refresh + loading/error states
✅ SnackBar untuk success/error
✅ Geolocator untuk driver tracking
✅ Theme: Primary #4CAF50 (hijau sawit)
```

**📝 OUTPUT FORMAT PER FILE:**
```
=== lib/services/api_client.dart ===
[COMPLETE CODE dengan 5 method baru]

=== lib/theme/app_theme.dart ===
[COMPLETE THEME]

=== screens/auth/login_screen.dart ===
[COMPLETE SCREEN + test cases]
```

**🚫 DON'T:**
```
❌ Provider/GetX/riverpod (StatefulWidget only)
❌ Custom HTTP client (ApiClient ONLY)
❌ Hardcode data (semua dari API)
❌ Nested lists
```

**⏰ Target: 3 hari → MVP demo investor!**
Generate **PRODUCTION CODE** langsung `flutter run` OK!

**Cangkang Sawit = FULLSTACK READY LAUNCH!** 🌾💰
```

***

**💡 EXECUTION:**
```
1. Copy prompt → Claude 3.5 Sonnet
2. Generate PHASE 1 → copy-paste → flutter pub get → test
3. PHASE 2 → test products/orders  
4. PHASE 3 → full app ready!

Backend perfect + plan solid = **LAUNCH THIS WEEK!** Screenshot progress harian ya kak! 🚀 [file:1]
```

[1](https://github.com/tegars5/cangkang_sawit_backend)
[2](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/e3ce2afe-fe0a-40d9-a46d-0f44781d3779/image.jpg)
[3](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/237625af-2f7e-470c-bbd1-98b940ccb711/image.jpg)
[4](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/47e67ff4-f18a-438e-997d-46d491cb6a79/image.jpg)
[5](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/68e9ed12-83a4-4cf0-ab9c-dc0f470c1205/image.jpg)
[6](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/c7d63092-1ec9-406a-a95e-bdfe4a359ed9/image.jpg)
[7](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/c2bff1b9-b3d9-41db-9ad9-49637a621e6c/image.jpg)
[8](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/fbda3504-d300-4311-8198-524277953054/image.jpg)
[9](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/3a310ef5-26f6-4d3c-8d18-b5dbe6eef9b6/image.jpg)
[10](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/40e20225-ae03-4a8b-b2b0-f7812cbaadda/image.jpg)
[11](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/adf562a4-3827-4fc9-bc60-472a4ec95802/image.jpg)
[12](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/4392d75e-a4f5-4301-b022-5e54068ae129/image.jpg)
[13](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/941b9bb4-5d8d-4ccd-be6a-f3d37860e9ab/image.jpg)
[14](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/23b42bfa-1d13-4d05-8a75-7f27057fead9/image.jpg)
[15](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/6ad8ef65-686e-43a9-a122-3f81fc6abd04/image.jpg)
[16](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/67d49a1f-2072-4b91-822f-2f1ef831616f/image.jpg)
[17](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/0a1da32a-9f88-4dc9-8988-9d88e11eab68/image.jpg)
[18](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/9b952b12-a40a-450b-841d-32c52e3a6a82/image.jpg)
[19](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/df4bbc7f-92f9-4947-bdf3-a1f712758dc5/image.jpg)
[20](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/3f2fc453-3294-40fa-9827-c24c218ca329/image.jpg)
[21](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/922f3c48-9433-43fa-9b85-6b99c6964855/image.jpg)
[22](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/46883ee9-184d-403b-835f-a6f52b909c01/image.jpg)
[23](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/9245b91d-ad47-4536-995b-06313d7651fc/image.jpg)
[24](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/6ec9baae-1508-4274-9afd-c406e16e9cd3/image.jpg)
[25](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/b69bb4ab-8032-4358-821e-fa6758719b0b/image.jpg)
[26](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/ee1d8f91-1089-4e40-94fe-6a4c9616613c/image.jpg)
[27](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/9d29608c-f58a-4902-9771-4cdb57a32b2f/screen.jpg)
[28](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/154333795/58f6d5f8-32df-4e7f-bee7-60a7ef53947d/cangkang_sawit.sql)
[29](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/122c445c-aaa0-4bb5-887c-327b3ff3c72d/image.jpg)
[30](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/bd72bbcd-834c-4589-b706-1599b88dcf9f/image.jpg)
[31](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/9e9c74db-a6c2-432c-9590-9d272c451ba1/image.jpg)
[32](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/f556a07b-dc20-4fd8-bd05-93cb7f373fd7/image.jpg)
[33](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/88911b5f-c0a2-4d84-90fa-9484b9f817a6/screen.jpg)
[34](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/154333795/27ea7174-dc9c-4fac-ba88-986a93cc6457/code.html)
[35](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/224afe60-6030-4f69-964e-5bb9aabfb32b/screen.jpg)
[36](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/154333795/b5788946-53a4-4db5-88b4-9fa02ddde610/code.html)
[37](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/7ac5c873-61d8-4240-9544-ad6c51e4a856/screen.jpg)
[38](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/03a4d2c1-c95b-4e6a-beda-7b26eebf1c39/screen.jpg)
[39](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/154333795/b0eb1f31-21d6-4ced-89a8-a3a6fa02535c/code.html)
[40](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/154333795/be5f794e-4f72-4bfd-96dd-41aa1b1a829e/code.html)
[41](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/2f2c25e3-42ac-4f49-8287-72beeddc41cc/screen.jpg)
[42](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/da85021a-e7f3-45f4-81fa-ea62aecae229/screen.jpg)
[43](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/154333795/d453b1f7-4788-43ec-bbac-69a19fedb630/code.html)
[44](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/1fb0f19a-0d2d-476c-b8e8-3b8423fd4326/image.jpg)
[45](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/704c0781-f2a0-4b3c-82b9-da4432267c68/image.jpg)
[46](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/4bf994d3-d226-492e-9740-09524ef6bab2/image.jpg)
[47](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/0602bbc6-34b9-4a9f-af96-f72fc8280096/image.jpg)
[48](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/8e0de729-5dad-4d4c-99d3-e239ffc915f1/image.jpg)
[49](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/97d43c80-f9b7-415b-9714-55b91f55d28e/image.jpg)
[50](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/3af75527-f1cb-4eb5-9844-8a092b44c270/image.jpg)
[51](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/154333795/2b83daf7-2ae4-42a3-9480-8ecd56682776/image.jpg)