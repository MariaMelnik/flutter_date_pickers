class DatePickerUtils {

// returns if two objects have same year, month and day
// time doesn't matter
  static bool sameDate (DateTime dateTimeOne, DateTime dateTimeTwo) {
    return dateTimeOne.year == dateTimeTwo.year
        && dateTimeOne.month == dateTimeTwo.month
        && dateTimeOne.day == dateTimeTwo.day;
  }

// returns if two objects have same year and month
// day and time don't matter
  static bool sameMonth (DateTime dateTimeOne, DateTime dateTimeTwo) {
    return dateTimeOne.year == dateTimeTwo.year
        && dateTimeOne.month == dateTimeTwo.month;
  }
}