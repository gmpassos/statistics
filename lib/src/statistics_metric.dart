/// Unit for lengths.
enum UnitLength {
  km,
  m,
  dm,
  cm,
  mm,
  mic,
  nm,
  inch,
  mi,
}

/// Extension for [UnitLength] enum.
extension UnitLengthExtension on UnitLength {
  /// Converts [value] from this [UnitLength] to [targetUnit].
  num convertTo(UnitLength targetUnit, num value) {
    if (this == targetUnit) return value;

    switch (this) {
      case UnitLength.km:
        {
          switch (targetUnit) {
            case UnitLength.m:
              return value * 1000;
            case UnitLength.dm:
              return value * 10000;
            case UnitLength.cm:
              return value * 100000;
            case UnitLength.mm:
              return value * 1000000;
            case UnitLength.mic:
              return value * 1e+9;
            case UnitLength.nm:
              return value * 1e+12;

            case UnitLength.inch:
              return value * 39370.1;
            case UnitLength.mi:
              return value * 0.62137119224;

            default:
              break;
          }
          break;
        }
      case UnitLength.m:
        {
          switch (targetUnit) {
            case UnitLength.km:
              return value * 0.001;
            case UnitLength.dm:
              return value * 10;
            case UnitLength.cm:
              return value * 100;
            case UnitLength.mm:
              return value * 1000;
            case UnitLength.mic:
              return value * 1000000;
            case UnitLength.nm:
              return value * 1e+9;

            case UnitLength.inch:
              return value * 39.3701;
            case UnitLength.mi:
              return value * 0.00062137119224;

            default:
              break;
          }
          break;
        }
      case UnitLength.dm:
        {
          switch (targetUnit) {
            case UnitLength.km:
              return value * 0.0001;
            case UnitLength.m:
              return value * 0.1;
            case UnitLength.cm:
              return value * 10;
            case UnitLength.mm:
              return value * 100;
            case UnitLength.mic:
              return value * 100000;
            case UnitLength.nm:
              return value * 1e+8;

            case UnitLength.inch:
              return value * 3.93701;
            case UnitLength.mi:
              return value * 6.21371e-5;

            default:
              break;
          }
          break;
        }
      case UnitLength.cm:
        {
          switch (targetUnit) {
            case UnitLength.km:
              return value * 1e-5;
            case UnitLength.m:
              return value * 0.01;
            case UnitLength.dm:
              return value * 0.1;
            case UnitLength.mm:
              return value * 10;
            case UnitLength.mic:
              return value * 10000;
            case UnitLength.nm:
              return value * 1e+7;

            case UnitLength.inch:
              return value * 0.393701;
            case UnitLength.mi:
              return value * 6.21371e-6;

            default:
              break;
          }
          break;
        }
      case UnitLength.mm:
        {
          switch (targetUnit) {
            case UnitLength.km:
              return value * 1e-6;
            case UnitLength.m:
              return value * 0.001;
            case UnitLength.dm:
              return value * 0.01;
            case UnitLength.cm:
              return value * 0.1;
            case UnitLength.mic:
              return value * 1000;
            case UnitLength.nm:
              return value * 1000000;

            case UnitLength.inch:
              return value * 0.0393701;
            case UnitLength.mi:
              return value * 6.21371e-7;

            default:
              break;
          }
          break;
        }
      case UnitLength.mic:
        {
          switch (targetUnit) {
            case UnitLength.km:
              return value * 1e-9;
            case UnitLength.m:
              return value * 1e-6;
            case UnitLength.dm:
              return value * 1e-5;
            case UnitLength.cm:
              return value * 1e-4;
            case UnitLength.mm:
              return value * 0.001;
            case UnitLength.nm:
              return value * 1000;

            case UnitLength.inch:
              return value * 3.93701e-5;
            case UnitLength.mi:
              return value * 6.21371e-10;

            default:
              break;
          }
          break;
        }
      case UnitLength.nm:
        {
          switch (targetUnit) {
            case UnitLength.km:
              return value * 1e-12;
            case UnitLength.m:
              return value * 1e-9;
            case UnitLength.dm:
              return value * 1e-8;
            case UnitLength.cm:
              return value * 1e-7;
            case UnitLength.mm:
              return value * 1e-6;
            case UnitLength.mic:
              return value * 0.001;

            case UnitLength.inch:
              return value * 3.93701e-8;
            case UnitLength.mi:
              return value * 6.21371e-13;

            default:
              break;
          }
          break;
        }

      case UnitLength.inch:
        {
          switch (targetUnit) {
            case UnitLength.km:
              return value * 2.54e-5;
            case UnitLength.m:
              return value * 0.0254;
            case UnitLength.dm:
              return value * 0.254;
            case UnitLength.cm:
              return value * 2.54;
            case UnitLength.mm:
              return value * 25.4;
            case UnitLength.mic:
              return value * 25400;
            case UnitLength.nm:
              return value * 2.54e+7;

            case UnitLength.mi:
              return value * 1.57828e-5;

            default:
              break;
          }
          break;
        }

      case UnitLength.mi:
        {
          switch (targetUnit) {
            case UnitLength.km:
              return value * 1.60934;
            case UnitLength.m:
              return value * 1609.34;
            case UnitLength.dm:
              return value * 16093.4;
            case UnitLength.cm:
              return value * 160934;
            case UnitLength.mm:
              return value * 1.609e+6;
            case UnitLength.mic:
              return value * 1.609e+9;
            case UnitLength.nm:
              return value * 1.609e+12;

            case UnitLength.inch:
              return value * 63360;

            default:
              break;
          }
          break;
        }
    }

    throw StateError('Unknown conversion: $this -> $targetUnit');
  }

  /// Returns `true` if this unit is a International System of Units (SI),
  /// commonly known as the Metric System.
  bool get isSI {
    switch (this) {
      case UnitLength.km:
      case UnitLength.m:
      case UnitLength.dm:
      case UnitLength.cm:
      case UnitLength.mm:
      case UnitLength.nm:
      case UnitLength.mic:
        return true;
      default:
        return false;
    }
  }

  /// Returns `true` if this unit is a Metric System Unit
  /// (officially called International System of Units - SI).
  ///
  /// - Same as [isSI]
  bool get isMetric => isSI;

  /// Returns `true` if this unit is a Imperial System of Units.
  bool get isImperial {
    switch (this) {
      case UnitLength.inch:
      case UnitLength.mi:
        return true;
      default:
        return false;
    }
  }

  /// Returns the name of this unit.
  String get name {
    switch (this) {
      case UnitLength.km:
        return 'kilometre';
      case UnitLength.m:
        return 'metre';
      case UnitLength.dm:
        return 'decimetre';
      case UnitLength.cm:
        return 'centimetre';
      case UnitLength.mm:
        return 'millimetre';
      case UnitLength.nm:
        return 'nanometre';
      case UnitLength.mic:
        return 'micrometre';
      case UnitLength.inch:
        return 'inch';
      case UnitLength.mi:
        return 'mile';
    }
  }

  /// Returns the abbreviation of this unit.
  String get unit {
    switch (this) {
      case UnitLength.km:
        return 'km';
      case UnitLength.m:
        return 'm';
      case UnitLength.dm:
        return 'dm';
      case UnitLength.cm:
        return 'cm';
      case UnitLength.mm:
        return 'mm';
      case UnitLength.nm:
        return 'nm';
      case UnitLength.mic:
        return 'μm';
      case UnitLength.inch:
        return 'in';
      case UnitLength.mi:
        return 'mi';
    }
  }
}
