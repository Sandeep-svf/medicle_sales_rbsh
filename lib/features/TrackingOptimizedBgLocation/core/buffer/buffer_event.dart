enum BufferEntityType {
  location,
  stop,
  trip,
}

class BufferEvent {
  final BufferEntityType type;
  final String entityId;
  final String payload; // JSON
  final DateTime createdAtUtc;

  BufferEvent({
    required this.type,
    required this.entityId,
    required this.payload,
    required this.createdAtUtc,
  });
}
