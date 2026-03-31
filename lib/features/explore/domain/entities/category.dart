class Category {
  final String id;
  final String name;
  final String? iconName;
  final String? color;

  const Category({
    required this.id,
    required this.name,
    this.iconName,
    this.color,
  });
}
