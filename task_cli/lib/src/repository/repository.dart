abstract class Repository<T> {
  List<T> getAll();

  T? getById(String id);

  void add(T item);

  void delete(String id);
}
