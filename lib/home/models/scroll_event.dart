/// Sent as part of a [ScrollEventCallback] to track progress of swipe events
/// [FORWARD] is emitted when the user swipes up (ie the index of the array increases),
/// [BACKWARDS] is emitted when scrolled in the opposite direction.
enum ScrollDirection { FORWARD, BACKWARDS }

/// Sent as part of a [ScrollEventCallback] to track progress of swipe events
/// [SUCCESS] is emitted for a successful swipe events, [FAILED_THRESHOLD_NOT_REACHED]
/// is emitted when a drag event doesn't meet the translation of velocity requirements
/// of a swipe event. Finally, [FAILED_END_OF_LIST] is emitted when a user tries
/// to go beyond the bounds of the array (either start or end) of the list.
enum ScrollSuccess {
  SUCCESS,
  FAILED_THRESHOLD_NOT_REACHED,
  FAILED_END_OF_LIST,
}

class ScrollEvent {
  ScrollDirection direction;
  ScrollSuccess success;
  int? pageNo;

  ScrollEvent(this.direction, this.success, this.pageNo);

  @override
  toString() {
    return "ScrollEvent: Direction: $direction, Success: $success, Page: ${pageNo ?? "Not given"}";
  }

  @override
  bool operator ==(Object other) {
    if (other is! ScrollEvent) {
      return false;
    }
    return this.direction == other.direction &&
        this.success == other.success &&
        this.pageNo == other.pageNo;
  }

  @override
  int get hashCode => super.hashCode;
}
