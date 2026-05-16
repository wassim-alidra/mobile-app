class EquipmentProviderStats {
  final int totalEquipment;
  final int totalBookings;
  final int pendingBookings;
  final int activeBookings;
  final int completedBookings;
  final double totalRevenue;
  final int availableFleet;

  const EquipmentProviderStats({
    required this.totalEquipment,
    required this.totalBookings,
    required this.pendingBookings,
    required this.activeBookings,
    required this.completedBookings,
    required this.totalRevenue,
    required this.availableFleet,
  });

  factory EquipmentProviderStats.empty() => const EquipmentProviderStats(
        totalEquipment: 0,
        totalBookings: 0,
        pendingBookings: 0,
        activeBookings: 0,
        completedBookings: 0,
        totalRevenue: 0.0,
        availableFleet: 0,
      );
}
