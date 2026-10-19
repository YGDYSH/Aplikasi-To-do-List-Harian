import 'package:flutter_test/flutter_test.dart';

import 'package:aplikasi_to_do_list/core/constants/app_strings.dart';
import 'package:aplikasi_to_do_list/core/utils/repeat_rule.dart';

void main() {
  group('repeatRuleStorageValue', () {
    test('menghasilkan kunci penyimpanan yang valid', () {
      for (final key in RepeatRuleKey.values) {
        final value = repeatRuleStorageValue(key);
        expect(isRepeatRuleValid(value), isTrue);
        expect(repeatRuleFromString(value), key);
      }
    });
  });

  group('repeatDeltaDays', () {
    test('daily=1, dua hari=2, mingguan=7, lainnya=0', () {
      expect(repeatDeltaDays('daily'), 1);
      expect(repeatDeltaDays('two_days'), 2);
      expect(repeatDeltaDays('weekly'), 7);
      expect(repeatDeltaDays('x'), 0);
      expect(repeatDeltaDays(null), 0);
    });
  });

  group('repeatRuleLabel', () {
    test('label dengan bahasa Indonesia', () {
      expect(repeatRuleLabel('daily'), AppStrings.repeatDaily);
      expect(repeatRuleLabel('two_days'), AppStrings.repeatTwoDays);
      expect(repeatRuleLabel('weekly'), AppStrings.repeatWeekly);
      expect(repeatRuleLabel(null), AppStrings.repeatNone);
      expect(repeatRuleLabel('tidak-ada'), AppStrings.repeatNone);
    });
  });

  group('repeatRuleFromString', () {
    test('kunci tidak dikenal menjadi null', () {
      expect(repeatRuleFromString('bulanan'), isNull);
      expect(repeatRuleFromString(''), isNull);
    });
  });
}
