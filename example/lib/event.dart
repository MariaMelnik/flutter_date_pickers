class Event {
  final DateTime date;
  final String dis;

  Event(this.date, this.dis)
      : assert(date != null),
        assert(dis != null);
}
