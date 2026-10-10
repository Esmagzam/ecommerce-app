import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/api_service.dart';
import '../models/category_model.dart';
import '../models/pagination_model.dart';
import '../models/product_model.dart';
import '../models/tag_model.dart';

class ProductDetailResult {
  final ProductModel product;
  final List<ProductModel> related;

  const ProductDetailResult({required this.product, required this.related});
}

class ProductRepository {
  final ApiService apiService;

  ProductRepository({required this.apiService});

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await apiService.get('/shop/categories');
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        return (data['data'] as List)
            .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message, statusCode: e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  Future<List<TagModel>> getTags() async {
    try {
      final response = await apiService.get('/shop/tags');
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        return (data['data'] as List)
            .map((e) => TagModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message, statusCode: e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  Future<PaginationModel<ProductModel>> getProducts({
    String? search,
    int? categoryId,
    int? tagId,
    num? minPrice,
    num? maxPrice,
    String? sort,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'per_page': perPage};

      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }
      if (categoryId != null && categoryId > 0) {
        queryParams['category_id'] = categoryId;
      }
      if (tagId != null && tagId > 0) {
        queryParams['tag_id'] = tagId;
      }
      if (minPrice != null && minPrice > 0) {
        queryParams['min_price'] = minPrice;
      }
      if (maxPrice != null && maxPrice > 0) {
        queryParams['max_price'] = maxPrice;
      }
      if (sort != null && sort.isNotEmpty) {
        queryParams['sort'] = sort;
      }

      final response = await apiService.get(
        '/shop/products',
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return PaginationModel<ProductModel>.fromJson(
          data,
          (itemJson) => ProductModel.fromJson(itemJson),
        );
      }
      return PaginationModel<ProductModel>(
        data: [],
        currentPage: page,
        lastPage: page,
        total: 0,
        perPage: perPage,
      );
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message, statusCode: e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  Future<ProductDetailResult> getProductDetail(int id) async {
    try {
      final response = await apiService.get('/shop/products/$id');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final productMap = data['data'] as Map<String, dynamic>?;
        if (productMap == null) {
          throw const ServerFailure(message: 'Бүтээгдэхүүн олдсонгүй.');
        }

        final product = ProductModel.fromJson(productMap);
        final relatedList = <ProductModel>[];

        if (data['related'] is List) {
          for (final rel in data['related'] as List) {
            if (rel is Map<String, dynamic>) {
              relatedList.add(ProductModel.fromJson(rel));
            }
          }
        }

        return ProductDetailResult(product: product, related: relatedList);
      }
      throw const ServerFailure(message: 'Бүтээгдэхүүний мэдээлэл олдсонгүй.');
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message, statusCode: e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }
}
