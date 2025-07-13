// Firestore data model definitions for Lost & Found app
// TODO: Integrate these models with Firestore collections when Firebase is set up

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // user, finder, partner, admin
  // Add more fields as needed

  UserModel({required this.id, required this.name, required this.email, required this.role});
}

class CenterModel {
  final String id;
  final String name;
  final String location;
  final String partnerUserId;
  final double adRevenue;
  final double profitShare;
  // Add more fields as needed

  CenterModel({
    required this.id,
    required this.name,
    required this.location,
    required this.partnerUserId,
    required this.adRevenue,
    required this.profitShare,
  });
}

class LostItemModel {
  final String id;
  final String photo;
  final String name;
  final String identity;
  final String description;
  final String location;
  final String category;
  final bool isClaimed;
  final DateTime? claimedAt;
  final String itemType; // 'lost' or 'found'
  final DateTime createdAt;
  final DateTime expiresAt;
  final String ownerUserId;
  final String centerId;

  LostItemModel({
    required this.id,
    required this.photo,
    required this.name,
    required this.identity,
    required this.description,
    required this.location,
    required this.category,
    required this.isClaimed,
    this.claimedAt,
    required this.itemType,
    required this.createdAt,
    required this.expiresAt,
    required this.ownerUserId,
    required this.centerId,
  });
}

class TransactionModel {
  final String id;
  final String type; // 'listing' or 'unlock'
  final double amount;
  final String fromUserId;
  final String? toUserId; // only for unlock
  final String centerId;
  final DateTime timestamp;
  final Map<String, double> split; // {'app': 0.50, 'finder': 0.50}
  final String itemId;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.fromUserId,
    this.toUserId,
    required this.centerId,
    required this.timestamp,
    required this.split,
    required this.itemId,
  });
}

class AdStatsModel {
  final String centerId;
  final int impressions;
  final int clicks;
  final double revenue;
  final String period; // e.g. '2024-06'

  AdStatsModel({
    required this.centerId,
    required this.impressions,
    required this.clicks,
    required this.revenue,
    required this.period,
  });
}

class ReportModel {
  final String reportId;
  final String itemId;
  final String reporterUserId;
  final String reason;
  final DateTime timestamp;
  final String status; // 'pending', 'reviewed', 'action_taken'
  final String? adminNotes;

  ReportModel({
    required this.reportId,
    required this.itemId,
    required this.reporterUserId,
    required this.reason,
    required this.timestamp,
    required this.status,
    this.adminNotes,
  });
}

// Example usage (mock data):
// final user = UserModel(id: 'user123', name: 'Alice', email: 'alice@email.com', role: 'user');
// final center = CenterModel(id: 'center456', name: 'Central Mall', location: 'Main St', partnerUserId: 'user789', adRevenue: 12.5, profitShare: 6.25);
// final lostItem = LostItemModel(id: 'item789', photo: 'url', name: 'Wallet', identity: 'ID123', description: 'Black wallet', location: 'Main St', category: 'Wallet', isClaimed: false, claimedAt: null, itemType: 'lost', createdAt: DateTime.now(), expiresAt: DateTime.now().add(Duration(days: 31)), ownerUserId: 'user123', centerId: 'center456');
// final txn = TransactionModel(id: 'txn001', type: 'unlock', amount: 1.0, fromUserId: 'user123', toUserId: 'user456', centerId: 'center456', timestamp: DateTime.now(), split: {'app': 0.5, 'finder': 0.5}, itemId: 'item789');
// final adStats = AdStatsModel(centerId: 'center456', impressions: 1000, clicks: 50, revenue: 12.5, period: '2024-06');
// final report = ReportModel(reportId: 'rep001', itemId: 'item789', reporterUserId: 'user123', reason: 'Suspicious item', timestamp: DateTime.now(), status: 'pending', adminNotes: null);
// TODO: Integrate with Firestore 'reports' collection 