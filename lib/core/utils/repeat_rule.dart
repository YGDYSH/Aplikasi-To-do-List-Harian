import 'package:aplikasi_to_do_list/core/constants/app_strings.dart';

/// Kunci tugas berulang yang disimpan di kolom `repeatRule`
/// (Tahap 5). `null` pada kolom = tidak berulang.
enum RepeatRuleKey {
  daily,
  twoDays,
  weekly;
}

const kRepeatDaily = 'daily';
const kRepeatTwoDays = 'two_days';
const kRepeatWeekly = 'weekly';

String repeatRuleStorageValue(RepeatRuleKey key) {
  switch (key) {
    case RepeatRuleKey.daily:
      return kRepeatDaily;
    case RepeatRuleKey.twoDays:
      return kRepeatTwoDays;
    case RepeatRuleKey.weekly:
      return kRepeatWeekly;
  }
}

RepeatRuleKey? repeatRuleFromString(String? rule) {
  switch (rule) {
    case kRepeatDaily:
      return RepeatRuleKey.daily;
    case kRepeatTwoDays:
      return RepeatRuleKey.twoDays;
    case kRepeatWeekly:
      return RepeatRuleKey.weekly;
    default:
      return null;
  }
}

/// Selisih hari antar instance (daily=1, dua hari=2, mingguan=7).
int repeatDeltaDays(String? rule) {
  switch (rule) {
    case kRepeatDaily:
      return 1;
    case kRepeatTwoDays:
      return 2;
    case kRepeatWeekly:
      return 7;
    default:
      return 0;
  }
}

/// Keterangan kecil yang tampil di kartu tugas
/// (mis. "Setiap dua hari" — Bagian 3.4).
String repeatRuleLabel(String? rule) {
  switch (rule) {
    case kRepeatDaily:
      return AppStrings.repeatDaily;
    case kRepeatTwoDays:
      return AppStrings.repeatTwoDays;
    case kRepeatWeekly:
      return AppStrings.repeatWeekly;
    default:
      return AppStrings.repeatNone;
  }
}

bool isRepeatRuleValid(String? rule) {
  return rule == null || repeatRuleFromString(rule) != null;
}
