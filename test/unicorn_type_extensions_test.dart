import 'package:test/test.dart';
import 'package:unicorn/unicorn.dart';

void main() {

  group('orFalse/orTrue',(){

    test('bool.orFalse', (){
      expect(true.orFalse, true);
      expect(false.orFalse, false);
    });
    test('bool.orTrue', (){
      expect(true.orTrue, true);
      expect(false.orTrue, false);
      });
    test('bool?', (){
      expect((null as bool?).orFalse, false);
      expect((null as bool?).orTrue, true);
      });
    test('String', (){
      expect(()=>"toto".orFalse, throwsArgumentError);
      expect(()=>"toto".orTrue, throwsArgumentError);
    });

  });

  group('trim/trimOrNull',(){
    test('String.t', (){
      final String? s = "  toto  ";
      final String s2 = "  tutu  ";
      expect(s.trim(), "toto");
      expect(s2.trim(), "tutu");
      expect(("  " as String?).trim(), "");
    });

    test('backward compatibility trim/trimOrNull', (){
      expect(("  toto  " as String?).trim(), "toto");
      expect("  ".trimOrNull, null);
    });
  });

}
