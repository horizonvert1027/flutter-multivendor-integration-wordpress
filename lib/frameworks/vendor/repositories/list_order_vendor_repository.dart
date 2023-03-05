import '../../../models/entities/paging_response.dart';
import '../../../models/index.dart';
import '../../../services/paging/paging_with_user_repository.dart';

class ListOrderVendorRepository extends PagingWithUserRepository<Order> {
  ListOrderVendorRepository({required User user}) : super(user);

  @override
  Future<PagingResponse<Order>>? Function({dynamic cursor, required User user})
      get requestApi => service.api.getVendorOrders;
}
