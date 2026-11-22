import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';
import '../services/category_service.dart';
import '../services/order_service.dart';
import '../services/product_service.dart';
import '../services/profile_service.dart';
import '../services/storage_service.dart';

final supabaseClientProvider =
    Provider<SupabaseClient>((ref) => Supabase.instance.client);

final authServiceProvider =
    Provider((ref) => AuthService(ref.watch(supabaseClientProvider)));
final profileServiceProvider =
    Provider((ref) => ProfileService(ref.watch(supabaseClientProvider)));
final categoryServiceProvider =
    Provider((ref) => CategoryService(ref.watch(supabaseClientProvider)));
final productServiceProvider =
    Provider((ref) => ProductService(ref.watch(supabaseClientProvider)));
final storageServiceProvider =
    Provider((ref) => StorageService(ref.watch(supabaseClientProvider)));
final orderServiceProvider =
    Provider((ref) => OrderService(ref.watch(supabaseClientProvider)));
