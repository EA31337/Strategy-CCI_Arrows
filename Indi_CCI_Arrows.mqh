/**
 * @file
 * Implements indicator class.
 */

// Includes.
#include <EA31337-classes/Indicator.mqh>

// Properties.
#property tester_indicator "Indi_CCI_Arrows.mq5"

// Enums.
// Indicator mode identifiers used in CCI Arrows indicator.
enum ENUM_CCI_ARROWS { CCI_ARROWS_UP = 0, CCI_ARROWS_DOWN = 1, FINAL_CCI_ARROWS_ENTRY };

// Structs.
struct CCI_Arrows_Params : IndicatorParams {
  unsigned int period;
  int shift;
  ENUM_APPLIED_PRICE applied_price;
  // Struct constructor.
  void CCI_Arrows_Params(unsigned int _period, ENUM_APPLIED_PRICE _applied_price, int _shift = 0)
      : period(_period), applied_price(_applied_price), shift(_shift) {
    itype = INDI_CCI;
    max_modes = FINAL_CCI_ARROWS_ENTRY;
    custom_indi_name = "Indi_CCI_Arrows";
    SetDataSourceType(IDATA_ICUSTOM);
    SetDataValueType(TYPE_DOUBLE);
  };
};

/**
 * Indicator class.
 */
class Indi_CCI_Arrows : public Indicator {
 protected:
  CCI_Arrows_Params params;

 public:
  /**
   * Class constructor.
   */
  Indi_CCI_Arrows(CCI_Arrows_Params &_p)
      : params(_p.period, _p.applied_price, _p.shift), Indicator((IndicatorParams)_p) {
    params = _p;
  }
  Indi_CCI_Arrows(CCI_Arrows_Params &_p, ENUM_TIMEFRAMES _tf)
      : params(_p.period, _p.applied_price, _p.shift), Indicator(INDI_CCI, _tf) {
    params = _p;
  }

  /**
   * Returns value for the indicator.
   */
  static double GetValue(string _symbol, ENUM_TIMEFRAMES _tf, int _period, int _ap, ENUM_CCI_ARROWS _mode = 0,
                         int _shift = 0, Indicator *_obj = NULL) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, "Indi_CCI_Arrows", _period, _ap, _mode, _shift);
#else  // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.GetState().GetHandle() : NULL;
    double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      // @fixme: Load indicator from the current folder?
      if ((_handle = ::iCustom(_symbol, _tf, "Indi_CCI_Arrows", _period, _ap)) == INVALID_HANDLE) {
        SetUserError(ERR_USER_INVALID_HANDLE);
        return EMPTY_VALUE;
      } else if (Object::IsValid(_obj)) {
        _obj.SetHandle(_handle);
      }
    }
    int _bars_calc = BarsCalculated(_handle);
    if (GetLastError() > 0) {
      return EMPTY_VALUE;
    } else if (_bars_calc <= 2) {
      SetUserError(ERR_USER_INVALID_BUFF_NUM);
      return EMPTY_VALUE;
    }
    if (CopyBuffer(_handle, _mode, _shift, 1, _res) < 0) {
      return EMPTY_VALUE;
    }
    return _res[0];
#endif
  }

  /**
   * Returns the indicator's value.
   */
  double GetValue(ENUM_CCI_ARROWS _mode, int _shift = 0) {
    ResetLastError();
    double _value = EMPTY_VALUE;
    switch (params.idstype) {
      case IDATA_BUILTIN:
        break;
      case IDATA_ICUSTOM:
        istate.handle = istate.is_changed ? INVALID_HANDLE : istate.handle;
        _value = Indi_CCI_Arrows::GetValue(GetSymbol(), GetTf(), GetPeriod(), GetAppliedPrice(), _mode, _shift,
                                           GetPointer(this));
        break;
      case IDATA_INDICATOR:
        // @todo: Add custom calculation.
        break;
    }
    istate.is_ready = _value != EMPTY_VALUE && _LastError == ERR_NO_ERROR;
    istate.is_changed = false;
    return _value;
  }

  /**
   * Returns the indicator's struct value.
   */
  IndicatorDataEntry GetEntry(int _shift = 0) {
    long _bar_time = GetBarTime(_shift);
    unsigned int _position;
    IndicatorDataEntry _entry;
    if (idata.KeyExists(_bar_time, _position)) {
      _entry = idata.GetByPos(_position);
    } else {
      _entry.timestamp = GetBarTime(_shift);
      _entry.value.SetValue(params.idvtype, GetValue(CCI_ARROWS_UP, _shift), CCI_ARROWS_UP);
      _entry.value.SetValue(params.idvtype, GetValue(CCI_ARROWS_DOWN, _shift), CCI_ARROWS_DOWN);
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, !_entry.value.HasValue(params.idvtype, EMPTY_VALUE));
      if (_entry.IsValid()) idata.Add(_entry, _bar_time);
    }
    return _entry;
  }

  /**
   * Returns the indicator's entry value.
   */
  MqlParam GetEntryValue(int _shift = 0, int _mode = 0) {
    MqlParam _param = {TYPE_DOUBLE};
    _param.double_value = GetEntry(_shift).value.GetValueDbl(params.idvtype, _mode);
    return _param;
  }

  /* Getters */

  /**
   * Get period value.
   */
  unsigned int GetPeriod() { return params.period; }

  /**
   * Get applied price value.
   */
  ENUM_APPLIED_PRICE GetAppliedPrice() { return params.applied_price; }

  /* Setters */

  /**
   * Set period value.
   */
  void SetPeriod(unsigned int _period) {
    istate.is_changed = true;
    params.period = _period;
  }

  /**
   * Set applied price value.
   */
  void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
    istate.is_changed = true;
    params.applied_price = _applied_price;
  }

  /* Printer methods */

  /**
   * Returns the indicator's value in plain format.
   */
  string ToString(int _shift = 0) { return GetEntry(_shift).value.ToString(params.idvtype); }
};
